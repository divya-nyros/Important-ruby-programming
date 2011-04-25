xml = Builder::XmlMarkup.new
xml.instruct!
xml.event do
  xml.id current_object.id
  xml.name current_object.name
  xml.start_date current_object.start_date.to_s;
  xml.start_time current_object.start_time.strftime('%H:%M')
  xml.end_date current_object.end_date.to_s
  xml.end_time current_object.end_time.strftime('%H:%M')
  xml.location current_object.location
  xml.private current_object.private
  xml.description current_object.description
  xml.instructions current_object.instructions
  xml.street current_object.addresses.first.street rescue ""
  xml.unit current_object.addresses.first.unit rescue ""
  xml.city current_object.addresses.first.city rescue ""
  xml.state current_object.addresses.first.state rescue ""
  xml.zip current_object.addresses.first.zip rescue ""
  xml.website current_object.websites.first rescue ""
  xml.phone current_object.phone_numbers.first rescue ""
end
