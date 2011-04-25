class AffiliateMailer < ActionMailer::Base
  def welcome(affiliate)
    setup(affiliate)
    @subject << "Access the Innovative Investors Event Registration System"
  end
  
  def setup(affiliate)
    @recipients       = "#{affiliate.email}"
    @from             = 'affiliates@theinnovativeinvestors.com'
    @subject          = "[Innovative Investors] "
    @sent_on          = Time.now
    @body[:affiliate] = affiliate
    @content_type     = 'text/html'
  end
end
