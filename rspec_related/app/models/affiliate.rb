class Affiliate < User
  acts_as_tree :foreign_key => :parent_id
  
  attr_accessible :email, :password, :password_confirmation, :parent_id, 
    :phone_numbers_attributes, :websites_attributes, :addresses_attributes
  
  validates_presence_of :first_name, :last_name
  before_validation_on_create :set_temporary_password

  belongs_to :parent
  has_many :attendees

  # named scopes
  # ====================================
  named_scope :master_affiliates, 
    :conditions => "id in (select distinct parent_id from users)",
    :order => "first_name, last_name"
  
  
  # TODO: replace with counter_cache
  def lead_count
    self.attendees.count
  end
  
  def master?
    children.any?
  end  
  
  # search
  # ===============================
  def self.search(search, options)
    # merge search params
    conditions = []
    params = {}
    
    # NOTE: we're using postgres' ILIKE for case-insensitive searches

    unless search[:affiliate_id].blank?
      conditions << "(cast(id as varchar) ilike :affiliate_id or affiliate_code ilike :affiliate_id)"
      params[:affiliate_id] = "%#{search[:affiliate_id]}%"
    end
    
    unless search[:name].blank?
      conditions << "(first_name ilike :name or last_name ilike :name or (first_name || ' ' || last_name) ilike :name)"
      params[:name] = "%#{search[:name]}%"
    end
    
    # if search[:phone]
    #   conditions << "()"
    # end
    
    unless search[:email].blank?
      conditions << "(email ilike :email)"
      params[:email] = "%#{search[:email]}%"
    end
    
    # unless search[:parent_id].blank?
    #   conditions << "parent_id = :parent_id"
    #   params[:parent_id] = search[:parent_id]
    # end
    
    options[:conditions] = [conditions.join(' and '), params]
    logger.debug options.to_yaml
    paginate(options)
  end
  
  private
  
    def set_temporary_password
      if self.password.blank?
        chars = (('a'..'z').to_a + ('0'..'9').to_a + %w( - \ [ ] { } < > / ? + )) - %w(i o 0 1 l 0)
        self.password = self.password_confirmation = (1..7).collect{|a| chars[rand(chars.size)] }.join
      end
    end
end
