Widgets.Pjax = {
  init: function() {
    var skip =
      ":not([data-remote])" +
      ":not([data-skip-pjax])" +
      ":not(.fancybox)" +
      ":not([data-widget = \"play\"])" +
      ":not([href^=#])" +
      ":not([data-widget = 'purchase'])";

    $("#header a" + skip + ", #main a" + skip).
      pjax('[data-pjax-container]', {timeout: 2500});

    $('body').bind('success.pjax', function() {
      window.HomeApp = new Home;

      Widgets.Feed.reload();
      Widgets.Upload.reload();
      Widgets.Editable.reload();
    });
  }
}

$(document).ready(function() {
  Widgets.Pjax.init();
});
