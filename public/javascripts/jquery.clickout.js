(function($) {
  $.fn.clickout = function(hideFn) {
    return this.each(function(_, el) {
      $(window).click(function(ev) {
        if ($(el).is(":visible") && $(ev.target).closest(el).length == 0)
          hideFn.call();
      });
    });
  };
})(jQuery);