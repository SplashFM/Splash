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
    $('[data-widget = "search"]').each(function(_, e) {
      var form    = $(e);
      var input   = form.find(':text');
      var results = $('#' + form.data('search-results'));

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

Widgets.TypingStop ={
  init: function(){
    $('#user_email').typing({
        start: function (event, $elem) {
        },
        stop: function (event, $elem) {
          $.ajax({
            type: 'get',
            url: Routes.users_exists_path(),
            data: "email=" + $elem.val(),
            success: function(data){
              $('#password').show();
              $('p.form-button').show();
            },
            error: function(data){
              $('#password').hide();
              $('p.form-button').hide();
            }
          });
        },
        delay: 200
    });
  }
}

Widgets.Upload = {
  init: function(upload) {
    var form = upload.find('form');

    upload.linkToggle();

    form.fileupload({
      // this will be removed soon, so no i18n needed
      fail:  function()        { upload.text('Upload failed.') },
      start: function()        { form.hide(); upload.text('Uploading.'); },
      stop:  function(e, data) { upload.text('Uploaded.'); }
    });
  }
}

$(document).ready(function() {
  Widgets.Search.init();
  Widgets.Track.init();
  Widgets.TypingStop.init();
});

