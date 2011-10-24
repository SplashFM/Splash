Widgets.Pjax = {
  init: function() {
    $("#header a:not([data-remote]):not([data-skip-pjax]):not(.fancybox):not([data-widget = \"play\"]):not([href^=#])")
            .pjax('[data-pjax-container]', {timeout: 2500});
    $("#main a:not([data-remote]):not([data-skip-pjax]):not(.fancybox):not([data-widget = \"play\"]):not([href^=#])")
            .pjax('[data-pjax-container]', {timeout: 2500});

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
