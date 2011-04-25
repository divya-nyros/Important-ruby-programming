class InvitationObserver < ActiveRecord::Observer
  def after_create(invitation)
    deliver_attendee_invitation(invitation)
  end
  
  def after_update(invitation)
    # resend if necessary
    if invitation.code_changed? || invitation.email_changed?
      deliver_attendee_invitation(invitation)
    end
  end
  
  private
  
    def deliver_attendee_invitation(invitation)
      # send invitation email
      InvitationMailer.deliver_attendee_invitation(invitation)
    end
end
