Factory.define :activity do |a|
  a.actionable_type "Attendee"
  a.actionable_id "1"
  a.actor_id 	"1"
  a.category "comment"
  a.data "Confirmed for 'New event on 03/03/2011'"
end