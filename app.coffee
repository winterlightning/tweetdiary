#function called after authroization
Nimbus.Auth.authorized_callback = ()->
  console.log("tweetdiary authorized callback done")
  
  if Nimbus.Auth.authorized()
    $("#loading").fadeOut()


#create a model for each entry
Entry = Nimbus.Model.setup("Entry", ["text", "create_time", "tags"])

#The order sort which sorts each entry by creation time
Entry.ordersort = (a, b) ->
  x = new Date(a.create_time)
  y = new Date(b.create_time)
  (if (x < y) then -1 else 1)

#Nimbus.Auth.authorized_callback is called when your app finish the authorization procedure. In this case, it fades out the loading div and then sync all the entries for the cloud.

###
Nimbus.Auth.authorized_callback = ()->

  console.log("tweetdiary authorized callback done")

  if Nimbus.Auth.authorized()
    $("#loading").fadeOut()
    
    Entry.sync_all( ()->
      render_entries()
    )
###

#Function to add a new entry
window.create_new_entry = ()->
  console.log("create new entry called")
  
  content = $("#writearea").val()
  if content isnt ""
    hashtags = twttr.txt.extractHashtags(content)
    #The crud procedure calling create on a entry
    x = Entry.create(text: content, create_time: (new Date()).toString(), tags: hashtags )
    
    $("#writearea").val("") #clear the div afterwards
    
    template = render_entry(x)
    $(".holder").prepend(template)
    
  

#Function to delete a entry
window.delete_entry = (id) ->
  x = Entry.find(id)
  $(".feed#"+id).remove()
  x.destroy()

#UI function to filter entries by tags
window.filter_entry = (e) ->
  console.log("filter entries", e)
  $(".feed").hide()
  $(".#{e}").show()
  $("#filter").val("#"+e)
  $("#x_button").show()

#UI function to clear of tags
window.clear_tags = ()->
  $("#filter").val("")
  $(".feed").show()
  $("#x_button").hide()

#function to render a single entry
window.render_entry = (x) ->
  d = new Date(x.create_time)
  timeago = jQuery.timeago(d);
  
  n = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  
  processed_text = x.text
  tag_string = ""
  
  if x.tags?
    for t in x.tags
      tag_string = tag_string + t + " "
      processed_text = processed_text.replace("#"+t, "<a onclick='filter_entry(\"#{ t }\");return false;'>##{ t }</a>")
  
  """<div class='feed #{ tag_string }' id='#{x.id}'><div class='feed_content'>
  <header>
      <div class="date avatar"><p>#{ d.getDate() }<span>#{ n[d.getMonth()] }</span></p></div>
      <p class="diary_text" id="#{ x.id }" contenteditable>#{ processed_text }</p>
      <div class="timeago">#{ timeago }</div>
      <div class='actions'>
        <a onclick='delete_entry("#{ x.id }")'>delete</a>
      </div>
  </header>
  </div></div>"""

window.blur_trigger= (x) ->
  $(x).blur( (x)-> 
    console.log("blur called")
    e = Entry.find(x.target.id)
    e.text = x.target.innerHTML
    hashtags = twttr.txt.extractHashtags(x.target.innerHTML)
    e.tags = hashtags
    
    rendered = render_entry(e)
    $("#"+e.id).replaceWith( rendered )
    
    e.save()
    
    a = $("#"+e.id + "  .diary_text")
    window.blur_trigger( a )
  )

#function to render all the entries, not important to how NimbusBase works
window.render_entries= () ->
  $(".holder").html("")

  for x in Entry.all().sort(Entry.ordersort)  
    template = render_entry(x)
    $(".holder").prepend(template)

  for x in $(".diary_text")
	#this is triggered when you go out of the text box and an edit event happens. On a edit, you find the Entry and then change it. Call .save() to save.
    window.blur_trigger(x)

window.sync = -> Entry.sync_all( -> render_entries() )

#log out and delete everything in localstorage
window.log_out = ->
  Nimbus.Auth.logout()
  $("#loading").fadeIn()

#initialization function that is called at the beginning 
jQuery ($) ->
  
  $("#x_button").hide()
  
  render_entries()
  
  Nimbus.Auth.set_app_ready () ->
    console.log("app ready called")
    
    if Nimbus.Auth.authorized()
      $("#loading").fadeOut()
     
      Entry.sync_all( ()->
          render_entries()
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