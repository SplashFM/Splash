var Widgets = Widgets || {};

function $ws(name) {
  return "[data-widget = '" + name + "']";
}

function $w(name) {
  return $($ws(name));
}

Widgets.Paginate = {
  init: function() {
    $w('next-page').live('ajax:success', function(_, data) {
      $(this).replaceWith(data);
    });
  }
}

Widgets.Scroll = {
  init: function() {
    $(".scroll-area").jScrollPane();
  }
}

Widgets.Tabs = {
  init: function(){
    $('.tabs').tabs();
  }
}

Widgets.Upload = {
  init: function() {
    var self = this;

    $w('upload-toggle').live('click', function(e) {
      e.preventDefault();

      $($(this).attr('href')).toggle();
    });

    self.reload();

    $w('upload-cancel').live('ajax:success', function(_, data) {
      $w('upload-container').replaceWith(data);
    });

    $($ws('upload-container') + ' form').
      live('ajax:success', function(_, data) {
        $w('upload-container').replaceWith(data);

        $w('upload-container').trigger('splash:uploaded');
        $w('upload').hide();

        self.reload();
      }).live('ajax:error', function(_, data) {
        if (data.status === 409) {
          Widgets.FlashTemplate.error(I18n.t("upload.already_splashed"));
        }

        $w('upload-container').html(data.responseText);

        self.reload();
      });
  },

  reload: function () {
    var self   = this;
    var upload = $w('upload');
    var form   = $w('upload-container').find('form');

    form.fileupload({
      // this will be removed soon, so no i18n needed
      fail:  function(e, data, xhr) {
        $w('upload-container').html(data.jqXHR.responseText)
        self.reload();

        $w('upload').show();
      },
      start: function()        { form.hide(); upload.text('Uploading.'); },
      done:  function(e, data) {
        $w('upload').html(data.result);
      }
    });
  }
}

Widgets.SplashAction = {
  init: function() {
    $w("splash-action").live('ajax:success', function() {
      $(':submit', this).
        attr('disabled', true).
        val(I18n.t('tracks.widget.splashed'));

      $(this).trigger('splash:splash').hide();
    });

    $w("splash-toggle").live('click', function(e) {
      e.preventDefault();

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
    this.reload();
  },

  reload: function(){
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

Widgets.UserProfile = {
  init: function(){
    $w("user-edit").live('ajax:success', function() {
      Widgets.FlashTemplate.success(I18n.t('flash.actions.update.notice', {resource_name: "User"}));
    })
    .live('ajax:error', function(evt, xhr, status, error){
      $.each($.parseJSON(xhr.responseText), function(key,value){
        Widgets.FlashTemplate.error(key + ': ' + value);
      })
    });
  }
}

Widgets.Avatar = {
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
  },

  locate: function(width, height){
    if(width <= Constants.AVATAR_WIDTH){
      marginLeft = (Constants.AVATAR_WIDTH - width) / 2;
    } else {
      marginLeft = 0;
    }

    if(height <= Constants.AVATAR_HEIGHT){
      marginTop  = (Constants.AVATAR_HEIGHT - height) / 2;
    } else {
      marginTop = 0;
    }

    $(".user-vcard .picture .style").attr('style', "margin-left:" + marginLeft + 'px; margin-top:' + marginTop + 'px;');
  }
}

Widgets.AvatarUpload = {
  init: function(){
    $('#fileupload').fileupload({
              done:  function(e, data) {
                $('#user-avatar').attr('src', data.result.avatar_thumb_url).fadeIn();
                $.fancybox.close();

                Widgets.Avatar.locate(data.result.avatar_geometry.width, data.result.avatar_geometry.height);
              },
              error: function(xhr, data) {
                var l = $('<dl/>');

                $.each($.parseJSON(xhr.responseText), function(k, v) {
                  // @ToDo: I had to add '' because $('<dd/>').text(v) is
                  //       returning empty string, jquery bug?
                  l.append($('<dt/>').text(k))
                   .append($('<dd/>').text(''+v));

                });

                $w("notification").html(l).show();
              }
    });
  }
}

Widgets.AvatarCrop = {
  init: function(){
      $('#cropbox').Jcrop({
        onChange: update_crop,
        onSelect: update_crop,
        setSelect: [0, 0, 125, 185],
        aspectRatio: 125/185,
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

    $("form.edit_user").bind('ajax:complete', function(evt, data, status, xhr){
      var user = $.parseJSON(data.responseText);
      var d = new Date();
      $('#user-avatar').attr('src', user.avatar_thumb_url + d.getTime());
      $.fancybox.close();

      Widgets.Avatar.locate(user.avatar_geometry.width, user.avatar_geometry.height);
    });
  }
}

Widgets.Notification = {
  init: function(){
    $w("notification-count").live('click', function() {
      if ($('.content').is(':visible')) {
        $.ajax({
          type: 'GET',
          url: Routes.notifications_path(),
          success: function(data, status, xhr){
            $(".notification-list").html(data);
            $('.content').hide();
          }
        });
      }
      else {
        $.ajax({
          type: 'PUT',
          url: Routes.reset_read_notifications_path(),
          success: function(_){
            resetNotificationCounter();
            $('.content').show();
          }
        });
      }
    });

    function resetNotificationCounter() {
      $(".count").html("<span> 0 </span>");
    };
  }
}

Widgets.SuggestedUsers = {
  init: function(){
    $w('next-suggested-users').live('ajax:success', function(_, data) {
        $w("suggested-users").html(data);
    });

    suggested_widgets = [$w('delete-suggested-user'), $w('follow-suggested-user')]

    $.each(suggested_widgets, function(i, e){
      e.live('ajax:success', function() {
        $.ajax({
          type: 'GET',
          url: Routes.suggested_splashers_path(),
          success: function(data){
            $w('suggested-users').html(data);
          }
        });
      });
    });
  }
}

$(document).ready(function() {
  Widgets.Scroll.init();
  Widgets.Upload.init();
  Widgets.Editable.init();
  Widgets.UserProfile.init();
  Widgets.SplashAction.init();
  Widgets.Notification.init();
  Widgets.Paginate.init();
  Widgets.SuggestedUsers.init();
  new SPLASH.Widgets.waterNums('.waterNum');
});

