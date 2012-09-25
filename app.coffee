Nimbus.Auth.setup("Dropbox", "lejn01o1njs1elo", "2f02rqbnn08u8at", "diary_app") #switch this with your own app key (please!!!!)

Entry = Nimbus.Model.setup("Entry", ["text", "time"])

#function to add a new entry
window.create_new_entry = ()->
  console.log("create new entry called")
  
  content = $("#writearea").val()
  if content isnt ""
    x = Entry.create(text: content, time: (new Date()).toString() )
    $("#writearea").val("") #clear the div afterwards
    
    template = render_entry(x)
    $(".holder").prepend(template)

window.render_entry = (x) ->
  d = new Date(x.time)
  timeago = jQuery.timeago(d);
  
  n = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  
  """<div class='feed' id='#{x.id}'><div class='feed_content'>
  <header>
      <div class="date avatar"><p>#{ d.getDate() }<span>#{ n[d.getMonth()] }</span></p></div>
      <p class="diary_text" id="#{ x.id }" contenteditable>#{ x.text }</p>
      <div class="timeago">#{ timeago }</div>
      <div class='actions'>
        <a onclick='delete_entry("#{ x.id }")'>delete</a>
      </div>
  </header>
  </div></div>"""

window.delete_entry = (id) ->
  x = Entry.find(id)
  $(".feed#"+id).remove()
  x.destroy()

window.onTestChange = () ->
    key = window.event.keyCode

    if key is 13 
        window.create_new_entry();
        return true
    else
        return true

#initialization
jQuery ($) ->
  for x in Entry.all()
    template = render_entry(x)
    $(".holder").prepend(template)

  for x in $(".diary_text")
    $(x).blur( (x)-> 
      e = Entry.find(x.target.id)
      e.text = x.target.innerHTML
      e.save()
    )

exports = this #this is needed to get around the coffeescript namespace wrap
exports.Entry = Entry