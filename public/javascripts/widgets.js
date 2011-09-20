var Widgets = Widgets || {};

Widgets.Track = {
  init: function() {
    $('[data-widget = "splash"]').live('ajax:success', function() {
      $(':submit', this).
        attr('disabled', true).
        val(I18n.t('tracks.widget.splashed'));
    });
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

  function showFlash(type, value){
    $("#flash_notice, #flash_error").remove();

    if(type=='error'){
      $( "#flashTemplate" ).tmpl( {flash_error_messages: value} ).prependTo( "#main" );
    } else{
      $( "#flashTemplate" ).tmpl( {flash_ok_messages: value} ).prependTo( "#main" );
    }

    $('#flash_error, #flash_notice').fadeIn();
  };

  function manageResponse() {
    $("form#user_new")
      .bind('ajax:success', function(evt, data, status, xhr){
        window.location.href = Routes.home_path();
      })
      .bind('ajax:error', function(evt, xhr, status, error){
        showFlash(status, $.parseJSON(xhr.responseText).error)
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
          showFlash('success', I18n.t('devise.passwords.send_instructions'));
        },
        error: function(data){
          showFlash('error', I18n.t('devise.failure.send_instructions'));
        }
      });
    });
  };

  return self;
})();

Widgets.Upload = {
  init: function(upload) {
    var form = upload.find('form');

    upload.linkToggle();

    form.fileupload({
      // this will be removed soon, so no i18n needed
      fail:  function()        { upload.text('Upload failed.') },
      start: function()        { form.hide(); upload.text('Uploading.'); },
      done:  function(e, data) { upload.text('Uploaded.'); }
    });
  }
}

$(document).ready(function() {
  Widgets.Search.init();
  Widgets.Track.init();
  Widgets.TypingStop.init();
  Widgets.SignIn.init();
});

