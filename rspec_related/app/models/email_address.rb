class EmailAddress < ContactMethod
  EMAIL_CATEGORIES = %w( work home other ).freeze
  
  before_validation :normalize
  
  def self.categories
    EMAIL_CATEGORIES
  end
  
  def normalize
    self.data = normalize_email(self.data)
  end
end