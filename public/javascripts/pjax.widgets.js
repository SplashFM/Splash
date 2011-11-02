Widgets.Pjax = {
  init: function() {
    var skip =
      ":not([data-remote])" +
      ":not([data-skip-pjax])" +
      ":not(.fancybox)" +
      ":not([data-widget = \"play\"])" +
      ":not([href^=#])";

    $("#header a" + skip + ", #main a" + skip).
      pjax('[data-pjax-container]', {timeout: 2500});

    $('body').bind('success.pjax', function() {
      Widgets.Feed.reload();
      Widgets.Search.reload();
      Widgets.Upload.reload();
      Widgets.Editable.reload();
    });
  }
}

$(document).ready(function() {
  Widgets.Pjax.init();
});
