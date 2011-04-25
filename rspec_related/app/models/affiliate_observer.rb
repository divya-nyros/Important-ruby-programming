class AffiliateObserver < ActiveRecord::Observer
  def after_create(affiliate)    
    # send auto-gen password to affiliate
    unless affiliate.skip_notifications?
      AffiliateMailer.deliver_welcome(affiliate)
    end
  end  
end
