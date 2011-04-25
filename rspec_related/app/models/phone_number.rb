class PhoneNumber < ContactMethod
  PHONE_CATEGORIES = %w( work mobile fax pager home skype other ).freeze
  
  def self.categories
    PHONE_CATEGORIES
  end
end