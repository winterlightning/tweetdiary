$ ->
  new FastClick(document.body)
  
  #$(window).on "load", ->
  #  new FingerBlast(document.body)  
  
  render_entries()
  
  Nimbus.Auth.set_app_ready () ->
    console.log("app ready called")
    
    if Nimbus.Auth.authorized()
      $("#loginModal").removeClass("active")
     
      window.auto_sync()

  
  ###
  $("#writearea").focus((e)->
    $(document).scrollTop(0)
    e.preventDefault()
    $('html, body').animate({scrollTop:0,scrollLeft:0}, 'fast')
  )
  ###
  
  #$("#loginModal").removeClass("active")

window.toggle_slide = () ->
  $("body").toggleClass("slide_left")

#create a model for each entry
Entry = Nimbus.Model.setup("Entry", ["text", "create_time", "tags"])

#The order sort which sorts each entry by creation time
Entry.ordersort = (a, b) ->
  x = new Date(a.create_time)
  y = new Date(b.create_time)
  (if (x < y) then -1 else 1)

#function to render a single entry
window.render_entry = (x) ->
  d = new Date(x.create_time)
  timeago = jQuery.timeago(d);
  
  n = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  
  processed_text = x.text
  tag_string = ""
  
  if d.getDate() < 10
    date_string = "0" + d.getDate()
  else
    date_string = d.getDate().toString()
  
  if x.tags?
    for t in x.tags
      tag_string = tag_string + t + " "
      processed_text = processed_text.replace("#"+t, "<a onclick='filter_entry(\"#{ t }\");return false;'>##{ t }</a>")
  
  """<li class="event" id="#{ x.id }">       
    <label></label>
    <div class="thumb user-1"><span><strong>#{ date_string }</strong> #{ n[d.getMonth()] }</span></div>
    <div class="content-perspective">
      <div class="content-timeline">
        <div class="content-inner">
          <h3>#{ processed_text }</h3>
          
        </div>

        <div class="event-menu">
            <a onclick="window.edit_entry('#{ x.id }')" style="padding-bottom: 7px">
              <i class="icon-pencil" style="font-size: 18px;"></i>
            </a>
            <a style="padding-bottom: 7px" onclick="window.delete_entry('#{ x.id }')">
              <i class="icon-trash" style="font-size: 17px;"></i>
            </a>          
        </div>

      </div>
    </div>
  </li>"""

#function to render all the entries, not important to how NimbusBase works
window.render_entries= () ->
  $(".timeline").html("")

  for x in Entry.all().sort(Entry.ordersort)  
    template = render_entry(x)
    $(".timeline").prepend(template)
    
  $(".event").click( ()->
    $(this).toggleClass("active")
  )
  

#Function to delete a entry
window.delete_entry = (id) ->
  if not id?
    id = window.current_entry
  
  x = Entry.find(id)
  $(".event#"+id).remove()
  x.destroy()
  
  $("#editModal").removeClass("active")

#log out and delete everything in localstorage
window.log_out = ->
  Nimbus.Auth.logout()
  $("body").toggleClass("slide_left")
  $("#loginModal").addClass("active")

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
    $(".timeline").prepend(template)
    
    $("#addModal").toggleClass("active")
    
    $(".event").click( ()->
      $(this).toggleClass("active")
    )

#edit a entry
window.edit_entry = (id) ->
  console.log("edit entry called")
  
  x = Entry.find(id)
  $("#editarea").val(x.text)
  
  $("#editModal").addClass("active")
  window.current_entry = id
  
#save entry
window.save_entry = () ->
  x = Entry.find(window.current_entry)
  x.text = $("#editarea").val()
  x.save()
  
  window.render_entries()
  
  $("#editModal").removeClass("active")


window.last_data = ""

window.auto_sync = ->
  console.log("auto sync called")
  
  if Nimbus.Auth.authorized() #and (window.navigator.onLine or navigator.network.connection.type is Connection.WIFI or navigator.network.connection.type is Connection.CELL_3G) 
    
    Entry.sync_all( ()->
      if window.last_data isnt localStorage["Entry"]      

        console.log("got here")
        
        window.render_entries()
        window.last_data = localStorage["Entry"]
    
      setTimeout("window.auto_sync()", 2000)
    )
  else
    setTimeout("window.auto_sync()", 2000)


exports = this #this is needed to get around the coffeescript namespace wrap
exports.Entry = Entry