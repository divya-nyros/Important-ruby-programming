class AttendeeMailer < ActionMailer::Base
  def registration_confirmation(attendee, event)
    setup(attendee)
    @subject      = "It was a pleasure speaking with you..."
    @body[:event] = event
  end
  
  def registration_reminder(attendee, event)
    setup(attendee)
    @subject      = "Event Reminder"
    @body[:event] = event
  end

  def wm_reminder(attendee, event)
    setup(attendee)
    @subject      = "This is just a reminder about tomorrow..."
    @body[:event] = event
  end

  def threedm_second_reminder(attendee, event)
    setup(attendee)
    @subject      = "We're just two weeks away..."
    @body[:event] = event
  end

  def threedm_third_reminder(attendee, event)
    setup(attendee)
    @subject      = "Just 7 Days until your life changes..."
    @body[:event] = event
  end

  def questionnaire(attendee, event)
    unless attendee.questionnaire.empty?
      @recipients      = "#{event.event_type.email}"
      @from = "Agi-backoffice <noreply@theinnovativeinvestors.com>"
      @subject      = "Darius, someone was registered"
      @body[:attendee] = attendee
      @body[:event] = event
      @content_type    = 'text/html'
    end
  end

  def threedm_fourth_reminder(attendee, event)
    setup(attendee)
    @subject      = "In just 48 hours you will..."
    @body[:event] = event
  end
  
  def setup(attendee)
    @recipients      = "#{attendee.email}"
    @from            = '"Jasmine Noble - Personal Assistant" <admin@theinnovativeinvestors.com>'
    @sent_on         = Time.now.strftime("%B #{Time.now.day.ordinalize}, %Y")
    @body[:attendee] = attendee
    @content_type    = 'text/html'
  end
end
