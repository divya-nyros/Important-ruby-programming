require 'common'

class EventRegistrationObserver < ActiveRecord::Observer
  def after_create(event_registration)    
    # send registration confirmation to attendee
    attendee = event_registration.attendee
    event    = event_registration.event

    deliver_registration_confirmation(attendee, event)

    unless attendee.questionnaire_sent || event.event_type.nil? || event.event_type.email.nil? || attendee.questionnaire.nil? || attendee.questionnaire.empty?
      AttendeeMailer.deliver_questionnaire(attendee, event)
      attendee.update_attribute(:questionnaire_sent, true)
    end
  end
  
  def after_update(event_registration)
    if event_registration.event_id_changed?
      attendee = event_registration.attendee
      event    = event_registration.event

      begin
        # log reschedule activity
        attendee.activities.create(
          :actor    => attendee.affiliate,
          :category => 'comment',
          :data     => "Rescheduled for '#{event.display_name}'"
        )      
      rescue Exception => e
        logger.error e
      end
      
      # send registration confirmation if rescheduled
      deliver_registration_confirmation(attendee, event)
    end 
  end
  
  private
  
    def deliver_registration_confirmation(attendee, event)
      begin
        # send confirmation email
        AttendeeMailer.deliver_registration_confirmation(attendee, event)
        # log activity on the attendee
        attendee.activities.create(
          :actor    => attendee.affiliate,
          :category => 'email',
          :data     => "Sent registration confirmation for '#{event.display_name}'",
          :system   => true
        )

        submit_attendee_to_icontact(attendee, event)
      rescue Exception => e
        logger.error e
        # log failed activity on the attendee
        attendee.activities.create(
          :category => 'comment',
          :data     => "Unable to send registration confirmation for '#{event.display_name}'\n#{e.message}",
          :system   => true
        )
      end
    end
end
