module EventsHelper
  def display_date_span(event)
    number_of_days = (event.end_date - event.start_date).to_i + 1
    out = "#{pluralize(number_of_days, "Day")}: "
    
    if number_of_days == 1
      out << event.start_date.to_time.to_s(:default_date)
    else event.start_date == event.end_date
      out << event.start_date.strftime("%m/%d")
      out << " - #{event.end_date.to_time.to_s(:default_date)}"
    end
    
    out
  end
end
