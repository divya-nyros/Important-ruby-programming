require "common"

class Attendee < ActiveRecord::Base
  has_many :event_registrations, :dependent => :destroy do
    def descending
      find(:all, :order => "events.start_date desc, events.start_time desc", :joins => :event)
    end
  end
  has_many :events, :through => :event_registrations
  has_many :activities, :as => :actionable, :dependent => :destroy, :order => "created_at desc"
  
  belongs_to :affiliate
  
  with_options :as => :contactable do |attendee|
    attendee.has_many :contact_methods, :dependent => :destroy
    attendee.has_many :phone_numbers
    attendee.has_many :email_addresses
    attendee.has_many :websites
  end

	accepts_nested_attributes_for :phone_numbers, :allow_destroy => true,
    :reject_if => proc { |attrs| attrs[:data].blank? }
  accepts_nested_attributes_for :events , :allow_destroy => true,
	:reject_if => proc { |attrs| attrs[:data].blank? }
	
	# store the questionnaire as a simple hash of question => answer
	serialize :questionnaire
	
	validates_presence_of :first_name, :last_name, :email
	validates_uniqueness_of :email, :case_sensitive => false
  validates_format_of :email,     :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :allow_blank => true
  validates_length_of :questionnaire, :maximum => 8192, :allow_blank => true

  before_validation :normalize

  def name
    "#{first_name} #{last_name}"
  end
  
  def source
    
  end
    
  include AASM
  aasm_column :state # had to specify to avoid NoMethodError 'aasm_state'
  aasm_initial_state :registered
  aasm_state :registered
  aasm_state :no_showed
  aasm_state :attended, :enter => :set_attended_at
  aasm_state :undecided
  aasm_state :purchased, :enter => :set_purchased_at

  aasm_event :check_in do
    transitions :to => :attended, :from => [:registered, :no_showed, :undecided, :purchased]
  end
  
  aasm_event :no_show do
    transitions :to => :no_showed, :from => [:registered, :attended, :undecided, :purchased]
  end
  
  aasm_event :on_the_fence do
    transitions :to => :undecided, :from => [:registered, :no_showed, :attended, :purchased]
  end
  
  aasm_event :purchase do
    transitions :to => :purchased, :from => [:registered, :no_showed, :attended, :undecided]
  end
  
  # named_scopes
  # ===============================
  self.aasm_states.map(&:name).each do |state|
    # create named scopes
    named_scope state, :conditions => { :state => state.to_s }
  end

  def self.options_for_states
    aasm_states.map(&:name).inject({}) { |vals, key| vals[key.to_s.humanize.split(/\s+/).each{ |word| word.capitalize! }.join(' ')] = key.to_s; vals }
  end
  
  # search
  # ===============================
	def self.search(search, options)
    # merge search params
    conditions = []
    params = {}

    # NOTE: we're using postgres' ILIKE for case-insensitive searches

    unless search[:affiliate_id].blank?
      conditions << "affiliate_id = :affiliate_id"
      params[:affiliate_id] = search[:affiliate_id]
    end

    unless search[:attendee_id].blank?
      conditions << "(cast(id as varchar) ilike :attendee_id or attendee_code ilike :attendee_id)"
      params[:attendee_id] = "%#{search[:attendee_id]}%"
    end

    unless search[:name].blank?
      conditions << "(first_name ilike :name or last_name ilike :name or (first_name || ' ' || last_name) ilike :name)"
      params[:name] = "%#{search[:name]}%"
    end

    unless search[:email].blank?
      conditions << "(email ilike :email)"
      params[:email] = "%#{search[:email]}%"
    end

    unless search[:phone].blank?
      contact_method_conditions = []
      contact_method_params = []

      contact_method_conditions << "data ILIKE ?"
      contact_method_params << "%" + search[:phone] + "%"
      contact_method_conditions << "type = ?"
      contact_method_params << "PhoneNumber"
      contact_method_conditions << "contactable_type = ?"
      contact_method_params << "Attendee"

      contactable_methods = ContactMethod.find(:all, :conditions => contact_method_params.insert(0, contact_method_conditions.join(" AND ")))
      contactable_id_array = []

      contactable_methods.each do |contactable_method|
        contactable_id_array << contactable_method.contactable_id
      end
      
      # Add -1 into the list so that if no phone numbers found, it will not cause the error.
      contactable_id_array << -1
      attendee_ids = "(" + contactable_id_array.join(", ") + ")"
      conditions << "attendees.id IN " + attendee_ids
    end
		
		unless search[:state].blank?
		  conditions << "(attendees.state = :state or event_registrations.state = :state)"
		  params[:state] = search[:state].to_s.downcase
    end
    
    options[:conditions] = [conditions.join(' and '), params]
    if search[:event_id].blank?
      options[:joins] = [ :event_registrations ] unless search[:state].blank?
    end
    logger.debug options.to_yaml
    paginate(options)
  end

  private
    
    def set_timestamp(attribute)
      eval("self.#{attribute.to_s} = Time.now")
    end
    
    def set_attended_at
      set_timestamp(:attended_at)
    end
    
    def set_purchased_at
      set_timestamp(:purchased_at)
    end

    def normalize
      self.email = normalize_email(self.email)
    end
end
