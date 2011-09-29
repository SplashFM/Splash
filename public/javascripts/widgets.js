var Widgets = Widgets || {};

Widgets.Track = {
  init: function() {
    $('[data-widget = "splash-action"]').live('ajax:success', function() {
      $(':submit', this).
        attr('disabled', true).
        val(I18n.t('tracks.widget.splashed'));
    });

    $('[data-widget = "play"]').live('click', function(e) {
      e.preventDefault();

      Widgets.Player.play($(this).attr('href'), $(this).data('track-type'));
    });
  }
}

Widgets.TrackInfo = {
  init: function() {
    $('[data-widget = "track-info-toggle"]').
      live('ajax:before', function(e) {
        var ti = $(this).siblings('[data-widget = "track-info"]');

        if (ti.length > 0) {
          ti.toggle();

          return false
        }
      }).
      live('ajax:success', function(_, data) {
        $(this).parent().append(data);
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

    $('[data-widget = "player"]').
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

    $('[data-widget = "search"]').each(function(_, e) {
      var form    = $(e);
      var input   = form.find(':text');
      var results = $('#' + form.data('search-results'));

      form.submit(function() { return false; });

      input.searchbox({
        url: form.attr('action'),
        dom_id: '#' + results.attr('id'),
        param: input.attr('name'),
        delay: 500
      });

      input.bind('after.searchbox', function() {
        Widgets.Upload.init(results.find('[data-widget = "upload"]'));

        results.show();
      });
    });
  }
};

Widgets.SeeMore = {
  init: function() {
    $('[data-widget = "see-more"]').live('ajax:success', function(_, data) {
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
      done:  function(e, data) { upload.text('Uploaded.'); }
    });
  }
}

Widgets.UploadToggle = {
  init: function() {
    $('[data-widget = "upload-toggle"]').live('click', function() {
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
    $('[data-widget = "editable"]').editable(submitEdit, {type    : 'textarea',
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
          user = $.parseJSON(data.responseText).user;
          d = new Date();
          $('#avatar').attr('src', user.avatar_url+d.getTime());
          $.fancybox.close();
      });
  }
}

Widgets.AvatarUpload = {
  init: function(){
    $('#fileupload').fileupload({
      fail:  function() {  $.fancybox.close(); },
      add: function(e, data){
                var that = $(this).data('fileupload');
                $('.files').empty();
                data.context = that._renderUpload(data.files)
                    .appendTo($(this).find('.files')).fadeIn(function () {
                        // Fix for IE7 and lower:
                        $(this).show();
                    }).data('data', data);
                if ((that.options.autoUpload || data.autoUpload) &&
                        data.isValidated) {
                    data.jqXHR = data.submit();
                }
      },
      done:  function(e, data) {
                  $('.jcrop-holder img').attr('src', data.result.user.avatar_url);
                  $('#avatar').attr('src', data.result.user.avatar_url).fadeIn();
                  $('table.files').empty();
              }
    });

    // Open download dialogs via iframes, to prevent aborting current uploads:
    $('#fileupload .files a:not([target^=_blank])').live('click', function (e) {
        e.preventDefault();
        $('<iframe style="display:none;"></iframe>')
            .prop('src', this.href)
            .appendTo('body');
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
});

