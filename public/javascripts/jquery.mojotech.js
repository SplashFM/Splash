(function($) {
  $.fn.linkToggle = function() {
    return this.each(function() {
      var div = $(this);

      $('a[href = "#' + this.id + '"]').
        click(function() { div.toggle(); });
    });
  }
})(jQuery);