Widgets.Pjax = {
  init: function() {
    var skip =
      ":not([data-bb])" +
      ":not([data-remote])" +
      ":not([data-skip-pjax])" +
      ":not(.fancybox)" +
      ":not([data-widget = \"play\"])" +
      ":not([href^=#])" +
      ":not([data-widget = 'purchase'])";

    $("#header a" + skip + ", #main a[href]" + skip).
      pjax('[data-pjax-container]', {timeout: 60000});

    $w('pjax').pjax("[data-pjax-container]", {timeout: 60000});

    $('body').bind('success.pjax', function() {
      Widgets.Editable.reload();
      Scaphandrier.Fancybox.init();
      new SPLASH.Widgets.waterNums('.waterNum');
      SPLASH.Widgets.sticky("#header .shell");
      Scaphandrier.PreventHeaderLinksDefault.init();
      SPLASH.Widgets.SettingsButton();
      SPLASH.Widgets.stepFontSize('.actor_name',62);
      $('.tooltip').hide();
    });
  }
}

$(document).ready(function() {
  Widgets.Pjax.init();
});
