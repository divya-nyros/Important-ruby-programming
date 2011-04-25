require 'curb'

class EventsController < ApplicationController
  before_filter :redirect_affiliate_user, :only => [:publish, :expire, :new, :edit, :destroy, :create, :update, :duplicate, :set_visible,:change_state_option]
  
  make_resourceful do
    actions :all
    
    before :new, :edit do
      # build empty associations for the form
      current_object.phone_numbers.build if current_object.phone_numbers.empty?
      current_object.websites.build if current_object.websites.empty?
      current_object.addresses.build if current_object.addresses.empty?
    end

  end
  
# Method for updating the  country sate option sart
def update_state_select
  @country_id= params[:val]
  @country_id = @country_id.upcase unless @country_id.nil?

  if !(@country_id == Carmen::country_code("Canada").upcase || @country_id == Carmen::country_code("Germany").upcase ||
        @country_id == Carmen::country_code("United States").upcase || @country_id == Carmen::country_code("Sweden").upcase)
    @country_id = ""
  end

  render :partial => "change_state_option", :locals => { :country_id => @country_id,:state=>nil }
end
# Method for updating the  country sate option end



  def closed
    render :action => :index
  end
  
  def all
    render :action => :index
  end
	
	def search
    if current_objects.empty?
      flash.now[:warning] = "No Event matched your search."
    end

    if request.request_uri.index("?").nil?
      @export_url = "/events/export/all"
    else
      @export_url = "/events/export/all?" + request.request_uri[request.request_uri.index("?") + 1, request.request_uri.length]
    end

    @default_value = params[:search]
    render :action => :index
  end

  def publish
    event = Event.find(params[:id])
    event.update_attribute("state", "published");

    render :text => "Published"
  end

  def unpublish
    event = Event.find(params[:id]);
    event.update_attribute("state", "unpublished");

    render :text => "Unpublished"
  end

  def expire
    event = Event.find(params[:id])
    event.update_attribute("state", "expired");

    render :text => "Expired"
  end

  def checkin
    options = {
      :page     => params[:page] || 1,
      :per_page => 25,
      :order    => params[:sort].blank? ? "first_name, last_name" : params[:sort]
    }
    
    params[:search] ||= {}
    params[:search][:affiliate_id] = current_user.id if current_user.type == "Affiliate"
      
    if params[:search].empty?
      @attendees = current_object.attendees.paginate(options)
    else
      @attendees = current_object.attendees.search(params[:search], options)
      @filter_name = params[:search][:name] unless params[:search][:name].nil?
    end
  end

  # TODO: refactor these methods to a checkin_controller or event_registration_controller
  def do_confirm
    if current_user.type == "User" || current_attendee.affiliate == current_user
      if registration = current_attendee.event_registrations.for_event(current_object).first
        registration.confirm!
        # log confirmation activity
        log_checkin_activity("Confirmed for '#{current_object.display_name}'")
        
        @attendee_id = current_attendee.id
        @event_id = params[:id]
      end
    end

    render :text => "Confirmed"
  end
  
  def do_cancel
    if current_user.type == "User" || current_attendee.affiliate == current_user
      if registration = current_attendee.event_registrations.for_event(current_object).first
        registration.cancel! unless registration.canceled?
        # log cancelation activity
        log_checkin_activity("Canceled for '#{current_object.display_name}'")
        
        @attendee_id = current_attendee.id
        @event_id = params[:id]
      end
    end

    render :text => "Canceled"
  end
  
	def do_checkin
    if current_user.type == "User" || current_attendee.affiliate == current_user
      if registration = current_attendee.event_registrations.for_event(current_object).first
        registration.check_in! unless registration.checked_in?
        current_attendee.check_in! unless current_attendee.attended?
        # log check in activity
        log_checkin_activity("Checked-In for '#{current_object.display_name}'")
        
        @attendee_id = current_attendee.id
        @event_id = params[:id]
      end
    end

    render :text => "Attended"
	end
	
	def reschedule
	  
  end

  def do_noshow
    if current_user.type == "User" || current_attendee.affiliate == current_user
      if registration = current_attendee.event_registrations.for_event(current_object).first
        current_attendee.no_show! unless current_attendee.no_showed?
        # log no-show activity
        log_checkin_activity("No-Showed for '#{current_object.display_name}'")
        
        @attendee_id = current_attendee.id
        @event_id = params[:id]
      end
    end

    render :text => "No showed"
  end
  
  def do_otf
    if current_user.type == "User" || current_attendee.affiliate == current_user
      if registration = current_attendee.event_registrations.for_event(current_object).first
        current_attendee.on_the_fence! unless current_attendee.undecided?
        # log undecided activity
        log_checkin_activity("Undecided for '#{current_object.display_name}'")
        
        @attendee_id = current_attendee.id
        @event_id = params[:id]
      end
    end

    render :text => "Undecided"
  end

  def do_purchase
    if current_user.type == "User" || current_attendee.affiliate == current_user
      if registration = current_attendee.event_registrations.for_event(current_object).first
        current_attendee.purchase! unless current_attendee.purchased?
        # log purchase activity
        log_checkin_activity("Purchased at '#{current_object.display_name}'")
        
        @attendee_id = current_attendee.id
        @event_id = params[:id]
      end
    end

    render :text => "Purchased"
  end

  def duplicate
    # TODO: refactor to the Event model
    event = Event.find(params[:id])
    @event = Event.new
    @event.name = "Copy of #{event.name}"
    @event.description = event.description
    @event.instructions = event.instructions
    @event.location = event.location
    @event.start_date = event.start_date
    @event.start_time = event.start_time
    @event.end_date = event.end_date
    @event.end_time = event.end_time
    @event.save

    redirect_to :action => :edit, :id => @event.id
  end

  def export
    filename = ""
    if params[:id] == "all"
      if request.request_uri.index("?").nil?
        filename = "all"
      else
        filename = "all-results"
      end

      export_objects = current_model.export(params[:search])
    else
      export_objects = []

      if current_model.exists?(params[:id])
        export_object = current_model.find(params[:id])
        filename = export_object.display_name.downcase.gsub(/\W/, '-')
        
        if current_user.type == "Affiliate" && !export_object.published?
          flash[:notice] = "Permission denied!"
          redirect_to :action => :index

          return
        end
      else
        flash[:notice] = "The event does not exist!"
        redirect_to :action => :index

        return
      end

      export_objects << export_object
    end

    csv_string = FasterCSV.generate do |csv|
      # data rows
      unless export_objects.nil?
        # Events list.
        csv << ["Events list"]
        columns = ["Name", "ID", "Phone", "Website", "Street", "City", "State address", "Description", "Instructions", "Date", "Time", "State", "# Attendees", "Confirmed", "No-Shows", "Attended", "SUBDNB", "OTF", "Bought"]

        Source.all.each do |source|
          columns << source.name + " source"
        end

        columns << "Unkown source"
        csv << columns
        no_events = true

        export_objects.each do |event|
          phone = event.phone_numbers.first rescue ""
          website = event.websites.first rescue ""
          street = event.addresses.first.street rescue ""
          city = event.addresses.first.city rescue ""
          state = event.addresses.first.state rescue ""
          stats = Event.stats(event.id, current_user)
          registered = stats[:registered]
          
          if current_user.type == "User" || registered > 0
            confirmed   = stats[:confirmed]
            attended    = stats[:attended]
            no_shows    = stats[:no_showed]
            subdnb      = stats[:subdnb]
            otf         = stats[:otf]
            bought      = stats[:bought]
            source_counts = Source.statistics(event, current_user)
            
            values = [event.name,
                    event.id.to_s,
                    phone.to_s,
                    website.to_s,
                    street,
                    city,
                    state,
                    (event.description.nil? ? "" : event.description),
                    (event.instructions.nil? ? "" : event.instructions),
                    @template.display_date_span(event),
                    event.end_time.to_s(:default_time) + " - " + event.start_time.to_s(:default_time),
                    (event.state.nil? ? "" : event.state),
                    registered.to_s,
                    confirmed.to_s,
                    no_shows.to_s,
                    attended.to_s,
                    subdnb.to_s,
                    otf.to_s,
                    bought.to_s]
            total_sources = 0

            source_counts.each do |name, count|
              values << [count.to_s]
              total_sources += count
            end

            values << [(registered - total_sources).to_s]
            csv << values
            no_events = false
          end
        end

        if no_events
          csv << ["No events found"]
        end

        # Attendees
        no_attendees = true
        csv << [""]
        csv << ["Attendees list"]
        csv << ["Event Name", "ID", "Email", "Phone Number", "First Name", "Last Name", "Status", "Registration status", "Affiliate"]
        
        export_objects.each do |event|
          if current_user.type == "User"
            attendees = event.attendees.all(:include => [:phone_numbers])
          else
            attendees = event.attendees.all(:include => [:phone_numbers], :conditions => ["affiliate_id = ?", current_user.id])
          end

          unless attendees.nil? || attendees.empty?
            no_attendees = false

            attendees.each do |attendee|
              phone_number = attendee.phone_numbers.first rescue ""
              registration_state = attendee.event_registrations.for_event(event).first.state rescue ""
              csv << [event.name, attendee.id, attendee.email, phone_number, attendee.first_name, attendee.last_name, (attendee.state.nil? ? "" : attendee.state), registration_state, (attendee.affiliate.name rescue '')]
            end
          end
        end

        if no_attendees
          csv << ["No attendees found"]
        end
      else
        render :text => "No events found!"
        
        return
      end
    end

    send_data csv_string, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=#{filename}-attendees.csv"
  end

  def set_visible
    if params[:value] == "public"
      current_object.update_attribute("private", false)
      render :text => "Public"
    else
      current_object.update_attribute("private", true)
      render :text => "Private"
    end
  end

  protected
  
	def current_objects
		options = {
			:page     => params[:page] || 1,
			:per_page => 25,
			:order    => params[:sort].blank? ? "start_date, start_time, end_date, end_time" : params[:sort]
		}
		options[:order] << " desc" if options[:order].to_s == 'start_date'

		@current_objects ||= if params[:search]
			current_model.search(params[:search], options)
		else
		  case action_name
  	    when 'index' then current_model.upcoming.paginate(options)
        else Event.send(action_name.to_sym).paginate(options)
      end
		end
	end
	
	def current_attendee
	  @attendee ||= Attendee.find(params[:attendee_id])
  end
  
  def log_checkin_activity(data)
    current_attendee.activities.create(
      :actor    => current_user,
      :category => 'comment',
      :data     => data
    )
  end
end
