class InvitationMailer < ActionMailer::Base
  def attendee_invitation(invitation)
    setup(invitation)
    @subject = "You're almost there...Act Fast to Reserve Your Spot!"
  end
  
  def setup(invitation)
    @recipients        = "#{invitation.email}"
    @from              = '"Jasmine Noble - Personal Assistant" <admin@theinnovativeinvestors.com>'
    @sent_on           = Time.now.strftime("%B #{Time.now.day.ordinalize}, %Y")
    @body[:invitation] = invitation
    @content_type      = 'text/html'
  end
end
