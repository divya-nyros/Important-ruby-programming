class Api::AttendeesController < Api::ApiController
  skip_before_filter :authenticate_user!, :only => [ :create ]
  
  def create
    if params[:attendee].blank? || params[:event].blank?
      render_oops "Unable to process your registration"
      return false
    end

    if params[:invitation] && params[:invitation][:code]
      if @invitation = Invitation.find_by_code(params[:invitation][:code])
        if @invitation.accepted?
          render_oops "Invitation code has already been used"
          return false
        end
      else
        render_oops "Invitation code is not valid"
        return false
      end
    end

    @attendee = Attendee.find_by_email(normalize_email(params[:attendee][:email]))
    @event    = Event.upcoming.published.find(params[:event][:id]) rescue nil
    
    if @event && (@event.public? || @invitation)
      @attendee ||= Attendee.new(params[:attendee])
      @attendee.events << @event unless @attendee.events.include?(@event)

      if params[:questions]
        questionnaire = {}
        params[:questions].each do |key, val|
          questionnaire[val] = params[:answers][key]
        end

        @attendee.questionnaire = questionnaire
        @attendee.questionnaire_sent = false
      end

      if @attendee.save
        @invitation.accept! if @invitation
        if registration = @attendee.event_registrations.for_event(@event).first
          if params[:source] && params[:source][:id]
            registration.update_attribute(:source_id, params[:source][:id])
          end
        end

        if params[:guest] && @invitation.allow_guest
          @guest = Attendee.find_by_email(normalize_email(params[:guest][:email]))
          @guest = Attendee.new(params[:guest]) if @guest.nil?
          #@guest.guest_of = @attendee.id
          @guest.events << @event unless @guest.events.include?(@event)

          if @guest.save
            registration.update_attribute(:guest, @guest.id)
            guest_registration = @guest.event_registrations.for_event(@event).first
            guest_registration.update_attribute(:guest_of, @attendee.id)
          end
        end
      else
        render_oops "Unable to process your registration"
        return false
      end
    else
      render_oops "The event you have requested is not available or is not open to the public"
      return false
    end

    if params[:redirect_url]
      redirect_to params[:redirect_url]
    else
      redirect_to :back
    end
  end
  
  def render_oops(message)
    flash[:error] = message
    render :action => :oops
  end
end