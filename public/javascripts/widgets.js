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

$(document).ready(function() {
  Widgets.Track.init();
});