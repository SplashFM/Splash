var Widgets = Widgets || {};

function $ws(name) {
  return "[data-widget = '" + name + "']";
}

function $w(name) {
  return $($ws(name));
}

Widgets.Feed = {
  init: function() {
    var filters = {};

    $w('events-filter').tokenInput(Routes.tags_path(), {
      theme: "facebook",
      onAdd: function(e) {
        if (filters[e.type] == null) filters[e.type] = [];

        filters[e.type].push(e);

        refresh(filters);
      },
      onDelete: function(e) {
        var filter = filters[e.type];

        filter.splice(filter.indexOf(e), 1);

        refresh(filters);
      }
    });

    $w('event-update-counter').live('ajax:success', function(_, data) {
      updateEventData(data);

      $w('event-update-counter').hide();
    });

    setInterval(this.fetchUpdateCount, 60000); // 1 minute

    function refresh(filters) {
      var data = [];

      for (var f in filters) {
        for (var i = 0; i < filters[f].length; i++) {
          data.push("filters[" + filters[f][i].type + "][]=" + filters[f][i].id);
        }
      }

      $.get($w('events').data('refresh_url'), data.join("&"), function(_, data) {
        updateEventData(data);
      });
    }

    function updateEventData(data) {
      $w("event-list").replaceWith(data);
    }
  },

  fetchUpdateCount: function() {
    var url = $w('event-list').data('update_url');

    $.ajax(url, {
      success: function(data) {
        $w('event-update-counter').find('a').
          text(I18n.t('events.updates', {count: data}));
        $w('event-update-counter').show();
      },
      error: function() {
        $w('event-update-counter').hide();
      }
    });
  }
}

Widgets.Track = {
  init: function() {
    $w("play").live('click', function(e) {
      e.preventDefault();

      Widgets.Player.play($(this).attr('href'), $(this).data('track-type'));
    });
  }
}

Widgets.TrackInfo = {
  init: function() {
    function splashWidget(anchor) {
      return anchor.parents($ws("splash"));
    }

    $w("splash-info-toggle").
      live('ajax:before', function(e) {
        var ti = splashWidget($(this)).find($ws("splash-info"));

        if (ti.length > 0) {
          ti.toggle();

          return false
        }
      }).
      live('ajax:success', function(_, data) {
        splashWidget($(this)).replaceWith(data);
      });
  }
}

Widgets.Player = {
  init: function() {
    $('#player-template').template("player-template");
  },

  play: function(url, type) {
    media       = {}
    media[type] = url

    $('#player-area').html($.tmpl('player-template'));

    $w("player").
      jPlayer({cssSelectorAncestor: '#player-container',
               swfPath:             'Jplayer.swf',
               supplied:            type,
               ready: function() {
                 $(this).jPlayer('setMedia', media).jPlayer('play');
               }});
  }
}

Widgets.Search = {
  init: function() {
    Widgets.SeeMore.init();

    $w("search").each(function(_, e) {
      var form    = $(e);
      var input   = form.find(':text');
      var results = $('#' + form.data('search-results'));

      form.submit(function() { return false; });

      input.searchbox({
        url: form.attr('action'),
        dom_id: '#' + results.attr('id'),
        param: input.attr('name'),
        delay: 1000
      });

      input.bind('after.searchbox', function() {
        Widgets.Upload.init(results.find($ws("upload")));

        results.show();
      });
    });

    $w('results').live('splash:splash splash:uploaded', function() {
      $(this).hide();
    });
  }
};

Widgets.SeeMore = {
  init: function() {
    $w("see-more").live('ajax:success', function(_, data) {
      $(this).replaceWith(data);
    });
  }
}

Widgets.TypingStop ={
  init: function(){
    $('#user_email').typing({
        start: function (event, $elem) {
        },
        stop: function (event, $elem) {
          $.ajax({
            type: 'get',
            dataType: 'js',
            url: Routes.users_exists_path(),
            data: "email=" + $elem.val(),

            complete: function(data){
              if(data.status == 200){
                $('#password').show();
                $('p.form-button').show();
              } else if(data.status == 404) {
                $('#password').hide();
                $('p.form-button').hide();
              }
            },
          });
        },
        delay: 200
   });
  }
}

Widgets.SignIn = (function(){
  var self = {};

  self.init = function() {
    manageResponse();
    ajaxifyForgotPasswordButton();
  };

  function manageResponse() {
    $("form#user_new")
      .bind('ajax:success', function(evt, data, status, xhr){
        window.location.href = Routes.home_path();
      })
      .bind('ajax:error', function(evt, xhr, status, error){
        Widgets.FlashTemplate.error($.parseJSON(xhr.responseText).error);
        $("#forgot_password").show();
      });
  };

  function ajaxifyForgotPasswordButton() {
    $('#forgot_password').live("click", function() {
      email = $("#user_email").val();
      $.ajax({
        type: 'post',
        url: Routes.user_password_path(),
        data: "user[email]=" + email,
        success: function(data){
          Widgets.FlashTemplate.success(I18n.t('devise.passwords.send_instructions'));
        },
        error: function(data){
          Widgets.FlashTemplate.error(I18n.t('devise.failure.send_instructions'));
        }
      });
    });
  };

  return self;
})();

Widgets.Upload = {
  init: function(upload) {
    var form = upload.find('form');

    form.fileupload({
      // this will be removed soon, so no i18n needed
      fail:  function()        { upload.text('Upload failed.') },
      start: function()        { form.hide(); upload.text('Uploading.'); },
      done:  function(e, data) { upload.trigger('splash:uploaded', data); }
    });
  }
}

Widgets.UploadToggle = {
  init: function() {
    $w("upload-toggle").live('click', function() {
      $($(this).attr('href')).toggle();
    });
  }
}

Widgets.SplashAction = {
  init: function() {
    $w("splash-action").live('ajax:success', function() {
      $(':submit', this).
        attr('disabled', true).
        val(I18n.t('tracks.widget.splashed'));

      $(this).trigger('splash:splash');
    });

    $w("splash-toggle").live('click', function() {
      $($(this).attr('href')).toggle();
    });
  }
}

Widgets.FlashTemplate = {
  success: function(value){
    $("#flash_notice, #flash_error").remove();
    $( "#flashTemplate" ).tmpl( {flash_ok_messages: value} ).prependTo( "#main" );
    $('#flash_error, #flash_notice').fadeIn();
  },

  error: function(value){
    $("#flash_notice, #flash_error").remove();
    $( "#flashTemplate" ).tmpl( {flash_error_messages: value} ).prependTo( "#main" );
    $('#flash_error, #flash_notice').fadeIn();
  }
}

Widgets.Editable = {
  init: function(){
    $w("editable").editable(submitEdit, {type    : 'textarea',
                                     cancel  : I18n.t('jeditable.labels.cancel'),
                                     submit  : I18n.t('jeditable.labels.submit'),
                                     tooltip : I18n.t('jeditable.labels.tooltip')});

    function submitEdit(value){
      var returned = $.ajax({
         url: $(this).attr('data-action'),
         type: "PUT",
         data : "user[tagline]=" + value,
         dataType : "json",
          success: function(evt, data, status, xhr){
            Widgets.FlashTemplate.success(I18n.t('flash.actions.update.notice', {resource_name: "User"}));
          },
          error: function(xhr, status, extra){
            Widgets.FlashTemplate.error('Tagline ' + $.parseJSON(xhr.responseText).tagline);
          }
      });

      return(value);
    }
  }
}

Widgets.UserAvatar = {
  init: function(){
    $(".user-image").mouseover(function() {
      $('.upload-avatar-link').show();
    }).mouseout(function(){
      $('.upload-avatar-link').hide();
    });
  }
}

Widgets.Avatar = {
  init: function(){
    $("form.edit_user")
      .bind('ajax:complete', function(evt, data, status, xhr){
          user = $.parseJSON(data.responseText);
          d = new Date();
          $('#avatar').attr('src', user.avatar_url+d.getTime());
          $.fancybox.close();
      });
  }
}

Widgets.AvatarUpload = {
  init: function(){
    $('#fileupload').fileupload({
      done:  function(e, data) {
                  $('#avatar').attr('src', data.result.avatar_url).fadeIn();
                  $.fancybox.close();
              }
    });
  }
}

Widgets.AvatarCrop = {
  init: function(){
      $('#cropbox').Jcrop({
        onChange: update_crop,
        onSelect: update_crop,
        setSelect: [0, 0, 240, 300],
        aspectRatio: 1,
        minSize: [40, 60]
      });

      function update_crop(coords) {
        $attrs = $("#image-attrs");

        var largeWidth = $attrs.attr("data-large-width");
        var largeHeight = $attrs.attr("data-large-height");
        var originalWidth = $attrs.attr("data-original-width");

        var ratio = originalWidth / largeWidth;
        $("#crop_x").val(Math.round(coords.x * ratio));
        $("#crop_y").val(Math.round(coords.y * ratio));
        $("#crop_w").val(Math.round(coords.w * ratio));
        $("#crop_h").val(Math.round(coords.h * ratio));
      }
  }
}

Widgets.AvatarEdition = {
  init: function(){
    $w("edit_avatar").click(function(){
      $.ajax({
        url: $(this).attr('data-action'),
        type: "GET",
        dataType : "json",
        beforeSend: function(){
          $("#spinner").show();
        },
        complete: function() {
          $("#spinner").hide();
        },
        success: function(evt, data, status, xhr){
          $('#crop').show();
          $w("edit_avatar").hide();
          Widgets.AvatarCrop.init();
          $w("crop-cancel").click(function(){
            $.fancybox.close();
            return false;
          })
        },
        error: function(xhr, status, extra){
          alert(I18n.t('users.crop.fetch_error'));
        }
      });

      return false;
    });
  }
}

$(document).ready(function() {
  Widgets.Player.init();
  Widgets.Search.init();
  Widgets.Track.init();
  Widgets.TypingStop.init();
  Widgets.SignIn.init();
  Widgets.UploadToggle.init();
  Widgets.TrackInfo.init();
  Widgets.Editable.init();
  Widgets.UserAvatar.init();
  Widgets.SplashAction.init();
  Widgets.Feed.init();
});

