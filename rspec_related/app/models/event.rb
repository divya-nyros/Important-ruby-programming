class Event < ActiveRecord::Base
  has_many :event_registrations
  has_many :attendees, :through => :event_registrations
  has_many :lists
  belongs_to :event_type, :foreign_key => :type_id
  
  has_one :address, :as => :addressable
  has_many :addresses, :as => :addressable
  with_options :as => :contactable do |event|
    event.has_many :contact_methods, :dependent => :destroy
    event.has_many :phone_numbers
    event.has_many :email_addresses
    event.has_many :websites
  end
  
  accepts_nested_attributes_for :addresses, :allow_destroy => true, 
    :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  accepts_nested_attributes_for :phone_numbers, :allow_destroy => true,
    :reject_if => proc { |attrs| attrs[:data].blank? }
  accepts_nested_attributes_for :email_addresses, :allow_destroy => true,
    :reject_if => proc { |attrs| attrs[:data].blank? }
  accepts_nested_attributes_for :websites, :allow_destroy => true,
    :reject_if => proc { |attrs| attrs[:data].blank? }

  validates_presence_of :start_date, :start_time, :end_date, :end_time

  def display_name
    "#{name} on #{start_date.to_time.to_s(:default_date)}"
  end
  
  def starts_at
    Time.local(start_date.year, start_date.month, start_date.day, start_time.hour, start_time.min)
  end
  
  def ends_at
    Time.local(end_date.year, end_date.month, end_date.day, end_time.hour, end_time.min)
  end
  
  def started?
    Time.now >= starts_at && !ended?
  end
  
  def ended?
    Time.now > ends_at
  end
  
  def public?
    !self.private?
  end
    
  include AASM
  aasm_column :state # had to specify to avoid NoMethodError 'aasm_state'
  aasm_initial_state :unpublished
  aasm_state :unpublished
  aasm_state :published
  aasm_state :expired
  aasm_state :closed
  
  aasm_event :publish do
    transitions :to => :published, :from => [:unpublished, :expired]
  end
  
  aasm_event :unpublish do
    transitions :to => :published, :from => [:unpublished, :expired]
  end
  
  aasm_event :expire do
    transitions :to => :expired, :from => [:unpublished, :published]
  end
  
  aasm_event :close do
    transitions :to => :closed, :from => [:expired]
  end

  # named_scopes
  # ===============================
  self.aasm_states.map(&:name).each do |state|
    # create named scopes
    named_scope state, :conditions => { :state => state.to_s }
  end
  
  named_scope :upcoming, lambda {
    {
      :conditions => ["end_date >= :today", { :today => Date.today }],
      :order      => "start_date, start_time, end_date, end_time"
    }
  }
  
  named_scope :in_state, lambda { |state|
    {
      :joins => [ :addresses ],
      :conditions => [ "lower(addresses.state) = lower(:state)", { :state => state } ]
    }
  }

  named_scope :in_country, lambda { |country_id|
    {
      :joins => [ :addresses ],
      :conditions => [ "lower(addresses.country_id) = lower(:country_id)", { :country_id => country_id } ]
    }
  }
  
  named_scope :expirable, lambda {
    date = Time.now.advance(:days => -1).to_date
    
    {
      :conditions => ["end_date <= :end_date AND state = :state", { :end_date => date, :state => "published" }]
    }
  }

  named_scope :type, lambda { |event_type_id|
    {
      :conditions => {:type_id => event_type_id}
    }
  }

  named_scope :public, lambda {
    {
      :conditions => {:private => false}
    }
  }
    
  # search
  # ===============================
	def self.search(search, options)
    # merge search params
    conditions = []
    params = {}

    # NOTE: we're using postgres' ILIKE for case-insensitive searches

    unless search[:state].blank?
      conditions << "state = :state"
      params[:state] = "published"
    end

    unless search[:event_id].blank?
      conditions << "(cast(id as varchar) ilike :event_id or event_code ilike :event_id)"
      params[:event_id] = "%#{search[:event_id]}%"
    end

    unless search[:name].blank?
      conditions << "(name ilike :name )"
      params[:name] = "%#{search[:name]}%"
    end

    unless search[:location].blank?
      conditions << "(location ILIKE :location )"
      params[:location] = "%#{search[:location]}%"
    end

    if !search[:start_date].blank? && !search[:end_date].blank?
      conditions << "start_date >= :start_date AND end_date <= :end_date"
      params[:start_date] = search[:start_date]
      params[:end_date] = search[:end_date]
    elsif !search[:start_date].blank? && search[:end_date].blank?
      conditions << "start_date >= :start_date"
      params[:start_date] = search[:start_date]
    elsif search[:start_date].blank? && !search[:end_date].blank?
      conditions << "end_date <= :end_date"
      params[:end_date] = search[:end_date]
    end

    unless search[:city].blank? && search[:state_address].blank?
      address_conditions = []
      address_params = []

      unless search[:city].blank?
        address_conditions << "city ILIKE ?"
        address_params << "%" + search[:city] + "%"
      end

      unless search[:state_address].blank?
        address_conditions << "state ILIKE ?"
        address_params << "%" + search[:state_address] + "%"
      end

      addresses = Address.search(address_params.insert(0, address_conditions.join(" AND ")))
      addressable_id_array = []

      addresses.each do |address|
        addressable_id_array << address.addressable_id
      end

      # adding -1 to ensure at least one value for valid SQL... but we could return [] here if no addresses match
      addressable_ids = "(-1" + addressable_id_array.join(", ") + ")"
      conditions << "id IN " + addressable_ids
    end

    options[:conditions] = [conditions.join(' and '), params]
    logger.debug options.to_yaml
    paginate(options)
  end

  def self.export(search)
    unless search.nil?
      # merge search params
      conditions = []
      params = []

      # NOTE: we're using postgres' ILIKE for case-insensitive searches

      unless search[:state].blank?
        conditions << "state = ? OR state = ?"
        params << "published"
        params << "expired"
      end

      unless search[:event_id].blank?
        conditions << "(cast(id as varchar) ilike ? or event_code ilike ?)"
        params << "%#{search[:event_id]}%"
      end

      unless search[:name].blank?
        conditions << "(name ilike ? )"
        params << "%#{search[:name]}%"
      end

      unless search[:location].blank?
        conditions << "(location ILIKE ? )"
        params << "%#{search[:location]}%"
      end

      if !search[:start_date].blank? && !search[:end_date].blank?
        conditions << "start_date >= ? AND end_date <= ?"
        params << search[:start_date]
        params << search[:end_date]
      elsif !search[:start_date].blank? && search[:end_date].blank?
        conditions << "start_date >= ?"
        params << search[:start_date]
      elsif search[:start_date].blank? && !search[:end_date].blank?
        conditions << "end_date <= ?"
        params << search[:end_date]
      end

      unless search[:city].blank? && search[:state_address].blank?
        address_conditions = []
        address_params = []

        unless search[:city].blank?
          address_conditions << "city ILIKE ?"
          address_params << "%" + search[:city] + "%"
        end

        unless search[:state_address].blank?
          address_conditions << "state ILIKE ?"
          address_params << "%" + search[:state_address] + "%"
        end

        addresses = Address.search(address_params.insert(0, address_conditions.join(" AND ")))
        addressable_id_array = []

        addresses.each do |address|
          addressable_id_array << address.addressable_id
        end

        addressable_ids = "(" + addressable_id_array.join(", ") + ")"
        conditions << "id IN " + addressable_ids
      end

      conditions_symbol = params.insert(0, conditions.join(" AND "))
      find(:all, :include => [:phone_numbers, :websites, :addresses], :conditions => conditions_symbol)
    else
      find(:all, :include => [:phone_numbers, :websites, :addresses])
    end
  end

  def self.stats(id, current_user)
    statistics = {}
    event = self.find(id)

    if current_user.type == "User"
      registered  = event.attendees.count
      confirmed   = EventRegistration.for_event(event).count(:conditions => ["confirmed_at is not null"])
      attended    = EventRegistration.checked_in.for_event(event).count
      no_shows    = event.attendees.no_showed.count
      subdnb      = event.attendees.attended.count
      otf         = event.attendees.undecided.count
      bought      = event.attendees.purchased.count
    else
      registered  = event.attendees.count(:conditions => ["affiliate_id = ?", current_user.id])

      if registered > 0
        confirmed   = EventRegistration.for_affiliate(current_user.id).for_event(event).count(:conditions => ["confirmed_at is not null"])
        attended    = EventRegistration.for_affiliate(current_user.id).for_event(event).checked_in.count
        no_shows    = event.attendees.no_showed.count(:conditions => ["affiliate_id = ?", current_user.id])
        subdnb      = event.attendees.attended.count(:conditions => ["affiliate_id = ?", current_user.id])
        otf         = event.attendees.undecided.count(:conditions => ["affiliate_id = ?", current_user.id])
        bought      = event.attendees.purchased.count(:conditions => ["affiliate_id = ?", current_user.id])
      else
        confirmed   = 0
        attended    = 0
        no_shows    = 0
        subdnb      = 0
        otf         = 0
        bought      = 0
      end
    end

    statistics[:registered] = registered
    statistics[:confirmed] = confirmed
    statistics[:attended] = attended
    statistics[:no_showed] = no_shows
    statistics[:subdnb] = subdnb
    statistics[:otf] = otf
    statistics[:bought] = bought
    
    return statistics
  end
end
