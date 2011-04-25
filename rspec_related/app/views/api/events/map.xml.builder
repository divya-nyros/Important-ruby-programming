states = [["Washington", 1, "WA"],
          ["Idaho", 2, "ID"],
          ["Montana", 3, "MT"],
          ["North Dakota", 4, "ND"],
          ["Minnesota", 5, "MN"],
          ["Wisconsin", 6, "WI"],
          ["Michigan", 7, "MI"],
          ["Oregon", 8, "OR"],
          ["Wyoming", 9, "WY"],
          ["South Dakota", 10, "SD"],
          ["Iowa", 11, "IA"],
          ["Illinois", 12, "IL"],
          ["Indiana", 13, "IN"],
          ["Ohio", 14, "OH"],
          ["California", 15, "CA"],
          ["Nevada", 16, "NV"],
          ["Utah", 17, "UT"],
          ["Colorado", 18, "CO"],
          ["Nebraska", 19, "NE"],
          ["Kansas", 20, "KS"],
          ["Missouri", 21, "MO"],
          ["Kentucky", 22, "KY"],
          ["Arizona", 23, "AZ"],
          ["New Mexico", 24, "NM"],
          ["Texas", 25, "TX"],
          ["Oklahoma", 26, "OK"],
          ["Arkansas", 27, "AR"],
          ["Louisiana", 28, "LA"],
          ["Mississippi", 29, "MS"],
          ["Tennessee", 30, "TN"],
          ["Alabama", 31, "AL"],
          ["Georgia", 32, "GA"],
          ["Florida", 33, "FL"],
          ["West Virginia", 34, "WV"],
          ["Maryland", 35, "MD"],
          ["Pennsylvania", 36, "PA"],
          ["New York", 37, "NY"],
          ["Vermont", 38, "VT"],
          ["New Hampshire", 39, "NH"],
          ["Maine", 40, "ME"],
          ["Massachusetts", 41, "MA"],
          ["Rhode Island", 42, "RI"],
          ["Connecticut", 43, "CT"],
          ["New Jersey", 44, "NJ"],
          ["Delaware", 45, "DE"],
          ["Virginia", 46, "VA"],
          ["North Carolina", 47, "NC"],
          ["South Carolina", 48, "SC"],
          ["Alaska", 49, "AK"],
          ["Hawaii", 50, "HI"],
          ["District Of Columbia", 51, "DC"]
]
xml = Builder::XmlMarkup.new
xml.usa_map_locator do
  xml.config do
    xml.color_state_name 0xffffff
    xml.color_state_name_over 0xffffff
    xml.type_of_gradient 1
    xml.background_color 0xF3F5F4
    xml.show_links 0
    xml.light_effect 1
    xml.border_color 0xF3F5F4
    xml.sound 'on'
  end

  xml.map_data do
    states.each do |state|
      event_count = Event.upcoming.published.in_state(state[2]).count
      if event_count > 0
        xml.state do
          xml.id state[1]
          xml.name state[0]
          xml.link "javascript:window.location.href = window.location.href.substr(0, window.location.href.indexOf('?')) + '?state=#{state[2].downcase}'"
          xml.comment "#{event_count} upcoming events in #{state[0]} "
          xml.color_map 0x7798BA
          xml.color_map_over 0x0054A6
        end
      else
        xml.state do
          xml.id state[1]
          xml.name state[0]
          xml.link "javascript:window.location.href = window.location.href.substr(0, window.location.href.indexOf('?')) + '?state=#{state[2].downcase}'"
          xml.comment "No currently scheduled events in #{state[0]}"
          xml.color_map 0xCCCCCC
          xml.color_map_over 0x8E8E8E
        end
      end
    end
  end
end