Widgets.Pjax = {
  init: function() {
    var skip =
      ":not([data-remote])" +
      ":not([data-skip-pjax])" +
      ":not(.fancybox)" +
      ":not([data-widget = \"play\"])" +
      ":not([href^=#])" +
      ":not([data-widget = 'purchase'])";

    $("#header a" + skip + ", #main a[href]" + skip).
      pjax('[data-pjax-container]', {timeout: 2500});

    $('body').bind('success.pjax', function() {
      Widgets.Upload.reload();
      Widgets.Editable.reload();
      Scaphandrier.Fancybox.init();
      new SPLASH.Widgets.waterNums('.waterNum');
      SPLASH.Widgets.sticky("#header .shell");
      Scaphandrier.PreventHeaderLinksDefault.init();
      SPLASH.Widgets.SettingsButton();
    });
  }
}

$(document).ready(function() {
  Widgets.Pjax.init();
});
