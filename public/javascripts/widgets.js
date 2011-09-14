var Widgets = Widgets || {};

Widgets.Track = {
  init: function() {
    $('.track .splash').live('ajax:success', function() {
      $(':submit', this).
        attr('disabled', true).
        val(I18n.t('tracks.widget.splashed'));
    });
  }
}

Widgets.Search = {
  init: function() {
    $('[data-widget = "track-search"] :text').
      liveSearch({url: Routes.search_path() + "?type=track&f=",
                  id: 'track-search'});
    $('[data-widget = "global-search"] :text').
      liveSearch({url: Routes.search_path() + "?type=global&f=",
                  id: 'global-search'});
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

$(document).ready(function() {
  Widgets.Search.init();
  Widgets.Track.init();
  Widgets.TypingStop.init();
});
