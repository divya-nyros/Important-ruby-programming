# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def site_title(text)
    content_for :title do
      text
    end
  end
  
  # Outputs the corresponding flash message if any are set
  def flash_messages
    messages = []
    %w(notice warning error).each do |msg|
      messages << content_tag(:div, html_escape(flash[msg.to_sym]), :class => "flash-#{msg}") unless flash[msg.to_sym].blank?
    end
    messages
  end
  
  def icon_image_tag(icon, model=nil, alt=nil)
    # returns a img tag based on the icon and model if provided
    image_tag("icons/#{icon}.png", :alt => alt || icon, :title => "#{alt || icon} #{model.class.name.humanize.downcase unless model.nil?}")
  end
  
  def search_string(search_params)
    # search_params[name]
    # search_params[email]
    params = []
    search_params.each do |k,v|
      unless v.blank?
        params << "#{k.to_s.humanize} = #{v.to_s}"
      end
    end
    
    return params.join(' and ')
  end
end
