class Invitation < ActiveRecord::Base
  belongs_to :affiliate # optional
  belongs_to :event_type
  
  validates_presence_of :code, :email
  validates_length_of :code, :maximum => 15, :allow_blank => true
  validates_length_of :email, :maximum => 256, :allow_blank => true
  validates_uniqueness_of :code, :allow_blank => true
  validates_inclusion_of :accepted, :in => [true, false], :allow_blank => true
  
  before_validation :generate_unique_code

  named_scope :type, lambda { |event_type_id|
    {
      :conditions => {:event_type_id => event_type_id}
    }
  }

  def name
    "#{first_name} #{last_name}".strip
  end
  
  def accept!
    self.update_attributes!(:accepted => true)
  end
  
  private
  
    def generate_unique_code
      if self.code.blank?
        begin
          self.code = UUIDTools::UUID.random_create.to_s.gsub(/\W/, '')[0..14]
        end until Invitation.find_by_code(self.code).nil?
      end
    end
end
