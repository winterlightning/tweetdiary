// Generated by CoffeeScript 1.4.0
(function() {
  var Entry, exports;

  Nimbus.Auth.authorized_callback = function() {
    console.log("tweetdiary authorized callback done");
    if (Nimbus.Auth.authorized()) {
      return $("#loading").fadeOut();
    }
  };

  Entry = Nimbus.Model.setup("Entry", ["text", "create_time", "tags"]);

  Entry.ordersort = function(a, b) {
    var x, y;
    x = new Date(a.create_time);
    y = new Date(b.create_time);
    if (x < y) {
      return -1;
    } else {
      return 1;
    }
  };

  /*
  Nimbus.Auth.authorized_callback = ()->
  
    console.log("tweetdiary authorized callback done")
  
    if Nimbus.Auth.authorized()
      $("#loading").fadeOut()
      
      Entry.sync_all( ()->
        render_entries()
      )
  */


  window.create_new_entry = function() {
    var content, hashtags, template, x;
    console.log("create new entry called");
    content = $("#writearea").val();
    if (content !== "") {
      hashtags = twttr.txt.extractHashtags(content);
      x = Entry.create({
        text: content,
        create_time: (new Date()).toString(),
        tags: hashtags
      });
      $("#writearea").val("");
      template = render_entry(x);
      return $(".holder").prepend(template);
    }
  };

  window.delete_entry = function(id) {
    var x;
    x = Entry.find(id);
    $(".feed#" + id).remove();
    return x.destroy();
  };

  window.filter_entry = function(e) {
    console.log("filter entries", e);
    $(".feed").hide();
    $("." + e).show();
    $("#filter").val("#" + e);
    return $("#x_button").show();
  };

  window.clear_tags = function() {
    $("#filter").val("");
    $(".feed").show();
    return $("#x_button").hide();
  };

  window.render_entry = function(x) {
    var d, n, processed_text, t, tag_string, timeago, _i, _len, _ref;
    d = new Date(x.create_time);
    timeago = jQuery.timeago(d);
    n = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    processed_text = x.text;
    tag_string = "";
    if (x.tags != null) {
      _ref = x.tags;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        t = _ref[_i];
        tag_string = tag_string + t + " ";
        processed_text = processed_text.replace("#" + t, "<a onclick='filter_entry(\"" + t + "\");return false;'>#" + t + "</a>");
      }
    }
    return "<div class='feed " + tag_string + "' id='" + x.id + "'><div class='feed_content'>\n<header>\n    <div class=\"date avatar\"><p>" + (d.getDate()) + "<span>" + n[d.getMonth()] + "</span></p></div>\n    <p class=\"diary_text\" id=\"" + x.id + "\" contenteditable>" + processed_text + "</p>\n    <div class=\"timeago\">" + timeago + "</div>\n    <div class='actions'>\n      <a onclick='delete_entry(\"" + x.id + "\")'>delete</a>\n    </div>\n</header>\n</div></div>";
  };

  window.blur_trigger = function(x) {
    return $(x).blur(function(x) {
      var a, e, hashtags, rendered;
      console.log("blur called");
      e = Entry.find(x.target.id);
      e.text = x.target.innerHTML;
      hashtags = twttr.txt.extractHashtags(x.target.innerHTML);
      e.tags = hashtags;
      rendered = render_entry(e);
      $("#" + e.id).replaceWith(rendered);
      e.save();
      a = $("#" + e.id + "  .diary_text");
      return window.blur_trigger(a);
    });
  };

  window.render_entries = function() {
    var template, x, _i, _j, _len, _len1, _ref, _ref1, _results;
    $(".holder").html("");
    _ref = Entry.all().sort(Entry.ordersort);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      x = _ref[_i];
      template = render_entry(x);
      $(".holder").prepend(template);
    }
    _ref1 = $(".diary_text");
    _results = [];
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      x = _ref1[_j];
      _results.push(window.blur_trigger(x));
    }
    return _results;
  };

  window.sync = function() {
    return Entry.sync_all(function() {
      return render_entries();
    });
  };

  window.log_out = function() {
    Nimbus.Auth.logout();
    return $("#loading").fadeIn();
  };

  jQuery(function($) {
    $("#x_button").hide();
    render_entries();
    Nimbus.Auth.set_app_ready(function() {
      console.log("app ready called");
      if (Nimbus.Auth.authorized()) {
        $("#loading").fadeOut();
        return Entry.sync_all(function() {
          return render_entries();
        });
      }
    });
    return $("#filter").keyup(function() {
      if ($("#filter").val() !== "" && $("." + $("#filter").val().replace("#", ""))) {
        window.filter_entry($("#filter").val().replace("#", ""));
        $("#x_button").show();
      }
      if ($("#filter").val() === "") {
        return clear_tags();
      }
    });
  });

  exports = this;

  exports.Entry = Entry;

}).call(this);
