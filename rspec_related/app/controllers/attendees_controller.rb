class AttendeesController < ApplicationController
  before_filter :redirect_if_not_owner, :except => [:search, :index, :new, :create]
  
  make_resourceful do
    actions :all #:new, :edit, :update, :show, :index, :destroy
		before :new, :edit do
      current_object.phone_numbers.build if current_object.phone_numbers.empty?

      if params[:event_id]
        event_registration = current_object.event_registrations.find(:first, :conditions => ["event_id = ?", params[:event_id]])
      else
        event_registration = current_object.event_registrations.find(:first, :order => "created_at DESC")
      end

      if !event_registration.nil?
        event = event_registration.event

        if event.end_date >= Date.today
          @event = event
        end
      end
    end

    before :update do
      # TODO: why are we overriding the affiliate here?
      if current_user.type == "Affiliate"
        # @attendee.affiliate_id = current_user.id
        # only if it wasn't already set... (not sure about this)
        @attendee.affiliate ||= current_user
      end

      if params[:event]
        begin
          event = Event.find(params[:event][:id])
          guest_id = nil
          
          unless @attendee.events.include?(event)
            unless params[:event][:old_id].blank?
              registration = @attendee.event_registrations.find_by_event_id(params[:event][:old_id])
              old_event = registration.event

              if @attendee.events.include?(old_event)
                old_registration = @attendee.event_registrations.for_event(old_event).first rescue nil

                unless old_registration.nil?
                  if old_registration.guest
                    guest = Attendee.find(old_registration.guest) rescue nil

                    unless guest.nil?
                      if guest.events && guest.events.include?(old_event)
                        guest.events.delete(old_event)
                      end

                      guest.events << event
                      guest_new_registration = guest.event_registrations.for_event(event).first
                      guest_new_registration.guest_of = @attendee.id
                      guest_new_registration.save
                      guest_id = guest.id
                    end
                  end
                end

                @attendee.events.delete(old_event)
              end
            end

            @attendee.events << event
            new_registration = @attendee.event_registrations.for_event(event).first
            new_registration.guest = guest_id
            new_registration.source_id = params[:source][:id] if params[:source]
            new_registration.save
          else
            if params[:event][:id] != params[:event][:old_id] # attempting to reschedule
              flash[:notice] = "The attendee is already registered for the #{event.display_name} event."
            end
          end
        rescue Exception => e
          flash[:error] = "Oops! #{e.message}"
        end
      end
    end
	end
  
  def create
    @attendee = Attendee.find_by_email(normalize_email(params[:attendee][:email]))
    begin
      @event = Event.find(params[:event][:id])
    rescue ActiveRecord::RecordNotFound
      @attendee ||= Attendee.new(params[:attendee])
      flash[:error] = "An Event is required."
      render :action => :new      
      return
    end
    
    registered = @attendee && @attendee.events.include?(@event)

    if registered
      flash[:notice] = "The attendee is already registered for the #{@event.display_name} event, please confirm!"
      redirect_to :action => :edit, :id => @attendee, :event_id => @event
    else
      @attendee ||= Attendee.new(params[:attendee])
      @attendee.affiliate ||= current_user if current_user.type == "Affiliate"

      if @attendee.save
        @attendee.events << @event unless @attendee.events.include?(@event)      
        if registration = @attendee.event_registrations.for_event(@event).first
          registration.update_attribute(:source_id, params[:source][:id])
        end
        redirect_to attendee_path(@attendee)
      else
        flash[:error] = "Unable to save Attendee."
        render :action => :new
      end
    end
  end

	def search
    if current_objects.empty?
      flash.now[:warning] = "No Attendee matched your search."
    end

    @default_value = params[:search]
    render :action => :index
  end
  
  protected
  
    def current_objects
      options = { 
        :page     => params[:page] || 1,
        :per_page => 25,
        :order    => params[:sort].blank? ? "first_name, last_name" : params[:sort] 
      }
      options[:order] << " desc" if options[:order].to_s == 'created_at'
      options[:include] = [:affiliate]
      
      params[:search] ||= {}
      # enforce affiliate filter
      params[:search][:affiliate_id] = current_user.id if current_user.is_a?(Affiliate)
      
      @current_objects ||= unless params[:search].empty?
        if params[:search][:event_id].blank?
          current_model.search(params[:search], options)
        else
          event = Event.find(params[:search][:event_id])
          event.attendees.search(params[:search], options)
        end
      else
        current_model.paginate(options)
      end
    end

    def redirect_if_not_owner
      if current_user.type == "Affiliate"
        if !Attendee.exists?(["id = ? AND affiliate_id = ?", params[:id], current_user.id])
          redirect_to :action => :index
        end
      end
    end
end

