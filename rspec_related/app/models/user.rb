require "common"

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :http_authenticatable, :token_authenticatable, :confirmable, :lockable, :timeoutable and :activatable
  devise :database_authenticatable, :recoverable,
         :rememberable, :trackable, :validatable, :lockable
  
  acts_as_paranoid
  
  before_validation :normalize
  before_destroy :release_email
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :first_name, :last_name, :user_type,
    :phone_numbers_attributes, :websites_attributes, :addresses_attributes
  attr_accessor :skip_notifications
  validates_length_of :password, :within => 6..20, :on => :create
  validates_uniqueness_of :email, :case_sensitive => false
  
  has_many :addresses, :as => :addressable, :dependent => :destroy
  with_options :as => :contactable do |user|
    user.has_many :contact_methods, :dependent => :destroy
    user.has_many :phone_numbers
    user.has_many :email_addresses
    user.has_many :websites
  end

  accepts_nested_attributes_for :phone_numbers, :allow_destroy => true,
    :reject_if => proc { |attrs| attrs[:data].blank? }
  accepts_nested_attributes_for :websites, :allow_destroy => true,
    :reject_if => proc { |attrs| attrs[:data].blank? }
  accepts_nested_attributes_for :addresses, :allow_destroy => true,
    :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }
  
  def name
    "#{first_name} #{last_name}"
  end
  
  def skip_notifications?
    self.skip_notifications
  end
  
  def skip_notifications!
    self.skip_notifications = true
  end
  
  def undelete!
    self.deleted_at = nil
    self.save!
  end

  # make devise/warden case insensitive
  def self.find_for_authentication(conditions)
    conditions[:email] = normalize_email(conditions[:email])
    super(conditions) 
  end

    # search
  # ===============================
  def self.search(search, options)
    # merge search params
    conditions = []
    params = {}

    # NOTE: we're using postgres' ILIKE for case-insensitive searches

    unless search[:type].blank?
      conditions << "(type = :type)"
      params[:type] = search[:type]
    end

    unless search[:name].blank?
      conditions << "(first_name ilike :name or last_name ilike :name or (first_name || ' ' || last_name) ilike :name)"
      params[:name] = "%#{search[:name]}%"
    end

    unless search[:email].blank?
      conditions << "(email ilike :email)"
      params[:email] = "%#{search[:email]}%"
    end

    options[:conditions] = [conditions.join(' and '), params]
    logger.debug options.to_yaml
    paginate(options)
  end

  protected

  def normalize
    self.email = normalize_email(self.email)
  end

  private #===============================
  
    def release_email
      email = self.email
      self.update_attribute(:email, "deleted-#{email}")
    end
end
