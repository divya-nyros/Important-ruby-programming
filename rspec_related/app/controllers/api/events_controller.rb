class Api::EventsController < Api::ApiController
  # TODO: secure this with API keys or something
  skip_before_filter :authenticate_user!
  
  make_resourceful do
    actions :index, :show

    response_for :index do |format|
      format.xml { render :xml => current_objects.to_xml }
      format.json { render :json => current_objects.to_json }
      format.html { }
    end

    response_for :show do |format|
      format.xml { 
        event_xml = current_object.to_xml do |xml|
          current_object.addresses.first.to_xml(:builder => xml, :skip_instruct => true)
        end
        
        render :xml => event_xml
      }
      format.json { render :json => current_object.to_json(:methods => :address) }
      format.html { }
    end
  end

  def registration_events
    events = []
    
    unless params[:invite_code].blank?
      invite = Invitation.find(:first, :conditions => ["code = ? AND accepted = ?", params[:invite_code], false])

      unless invite.nil?
        events = Event.type(invite.event_type_id).published.upcoming
      end
    end

    respond_to do |format|
      format.xml { render :xml => events.to_xml(:include => :address) }
      format.json { render :json => events.to_json }
      format.html
    end
  end
  
  def map
    respond_to do |format|
      format.xml { }
    end
  end

  def available_countries
    countries = []
    Address.all(:select => "DISTINCT(country_id) AS country_id", :order => 'country_id').each do |address|
      unless address.country_id.nil? || address.country_id.upcase == "US"
        event_count = Event.published.in_country(address.country_id).upcoming.length
        country_name = Carmen::country_name(address.country_id)
        countries << {:name => country_name, :count => event_count}
      end
    end

    respond_to do |format|
      format.xml { render :xml => countries.to_xml }
      format.json { render :json => countries.to_json }
      format.html {render :text => countries.inspect}
    end
  end
  
  def in
    respond_to do |format|
      format.xml { render :xml => current_objects.to_xml(:include => :address) }
      format.json { render :json => current_objects.to_json }
      format.html
    end
  end
  
  def current_objects
    if params[:state].blank?
      if params[:event_type_id].blank?
        @current_objects ||= current_model.published.upcoming
      else
        @current_objects ||= current_model.type(params[:event_type_id]).published.upcoming
      end
    else
      if params[:event_type_id].blank?
        @current_objects ||= current_model.published.in_state(params[:state]).upcoming

        if @current_objects.nil? || @current_objects.empty?
          @current_objects = current_model.published.in_country(Carmen::country_code(params[:state])).upcoming
        end
      else
        @current_objects ||= current_model.type(params[:event_type_id]).published.in_state(params[:state]).upcoming

        if @current_objects.nil? || @current_objects.empty?
          @current_objects = current_model.type(params[:event_type_id]).published.in_country(Carmen::country_code(params[:state])).upcoming
        end
      end
    end

    @current_objects
  end
end
