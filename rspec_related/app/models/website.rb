class Website < ContactMethod
  WEBSITE_CATEGORIES = %w( work personal other )
  
  def self.categories
    WEBSITE_CATEGORIES
  end
  
  def to_s
    data.to_s rescue ""
  end
  
  def to_url
    data.starts_with?('http') ? data.to_s : "http://#{data.to_s}"
  end
end