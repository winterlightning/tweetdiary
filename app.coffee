Nimbus.Auth.setup("Dropbox", "lejn01o1njs1elo", "2f02rqbnn08u8at", "diary_app") #switch this with your own app key (please!!!!)

Entry = Nimbus.Model.setup("Entry", ["text", "time"])

#function to add a new entry
window.create_new_entry = ()->
  console.log("create new entry called")
  
  content = $("#writearea").val()
  if content isnt ""
    Entry.create(text: content, time: Date.now().toString() )
    $("#writearea").val("") #clear the div afterwards

#initialization
jQuery ($) ->
  for x in Entry.all()
    d = new Date(Date(x.time))
    
    console.log(d.getDate())
    
    template = """<div class='feed'><div class='feed_content'>
     <header>
        <div class='time'>3 days ago</div>
        <div class="date avatar"><p>#{ d.getDate() }<span>May</span></p></div>
        <p class="diary_text">#{ x.text }</p>
        <div class='actions'><a onclick='window.like_obj('412910_10100693904950715')'>8</a></div>
     </header>
     </div></div>"""
    console.log(x, template)
    $(".holder").prepend(template)

exports = this #this is needed to get around the coffeescript namespace wrap
exports.Entry = Entry