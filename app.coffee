Nimbus.Auth.setup("Dropbox", "lejn01o1njs1elo", "2f02rqbnn08u8at", "diary_app") #switch this with your own app key (please!!!!)

Entry = Nimbus.Model.setup("Entry", ["text", "create_time", "tags"])

#function to add a new entry
window.create_new_entry = ()->
  console.log("create new entry called")
  
  content = $("#writearea").val()
  if content isnt ""
    hashtags = twttr.txt.extractHashtags(content)
    console.log("hashtags", hashtags)
    x = Entry.create(text: content, create_time: (new Date()).toString(), tags: hashtags )
    
    $("#writearea").val("") #clear the div afterwards
    
    template = render_entry(x)
    $(".holder").prepend(template)

window.filter_entry = (e) ->
  console.log("filter entries", e)
  $(".feed").hide()
  $(".#{e}").show()
  $("#filter").val("#"+e)
  $("#x_button").show()

window.render_entry = (x, newday) ->
  d = new Date(x.create_time)
  timeago = jQuery.timeago(d);
  
  n = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  
  processed_text = x.text
  tag_string = ""
  
  newday = "" if not newday?
  
  if x.tags?
    for t in x.tags
      tag_string = tag_string + t + " "
      processed_text = processed_text.replace("#"+t, "<a onclick='filter_entry(\"#{ t }\");return false;'>##{ t }</a>")
  
  """<div class='feed #{ tag_string } #{ newday }' id='#{x.id}'><div class='feed_content'>
  <header>
      <div class="date avatar"><p>#{ d.getDate() }<span>#{ n[d.getMonth()] }</span></p></div>
      <p class="diary_text" id="#{ x.id }" contenteditable>#{ processed_text }</p>
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

window.clear_tags = ()->
  $("#filter").val("")
  $(".feed").show()
  $("#x_button").hide()

window.datesort = (a, b) ->
  (if (a.create_time < b.create_time) then -1 else 1)
    
#initialization
jQuery ($) ->
  $("#x_button").hide()
  current_day = null
  
  for x in Entry.all().sort(datesort)  
    d = new Date(x.create_time)
    d_str = d.getDate().toString() + d.getMonth().toString() + d.getFullYear().toString()
          
    if current_day is null or current_day isnt d_str
      template = render_entry(x, "newday")
      current_day = d_str
    else
      template = render_entry(x)
    $(".holder").prepend(template)

  for x in $(".diary_text")
    $(x).blur( (x)-> 
      e = Entry.find(x.target.id)
      e.text = x.target.innerHTML
      hashtags = twttr.txt.extractHashtags(x.target.innerHTML)
      console.log("hashtags", hashtags)
      e.tags = hashtags
      
      rendered = render_entry(e)
      $("#"+e.id).replaceWith( rendered )
      
      e.save()
    )
  
  #bind the filter section
  $("#filter").keyup( ()->
    if $("#filter").val() isnt "" and $( "."+ $("#filter").val().replace("#", ""))
      window.filter_entry( $("#filter").val().replace("#", "") )
      $("#x_button").show()
    if $("#filter").val() is ""
      clear_tags()
  )

exports = this #this is needed to get around the coffeescript namespace wrap
exports.Entry = Entry