// Author: Ryan Heath
// http://rpheath.com

(function($) {
  const SETTINGS = {
    url: '/search',
    param: 'query',
    dom_id: '#results',
    delay: 100,
    loading_css: '#loading'
  };

  const SearchBox = function(settings) {
    var self = this;

    this.settings = settings;

    this.loading = function() {
      $(self.settings.loading_css).show();
    };

    this.resetTimer = function(timer) {
      if (timer) clearTimeout(timer);
    };

    this.idle = function() {
      $(self.settings.loading_css).hide();
    };

    this.process = function(input) {
      var terms = input.val();
      var path = self.settings.url.split('?'),
        query = [self.settings.param, '=', terms].join(''),
        base = path[0], params = path[1], query_string = query

      if ($.trim(terms) === '') return;

      if (params)
        query_string = [params.replace('&amp;', '&'), query].join('&');

      self.start(input);

      $.get([base, '?', query_string].join(''), function(data) {
        $(self.settings.dom_id).html(data);

        self.stop(input);
      })
    };

    this.start = function(input) {
      input.trigger('before.searchbox', {searchbox: self});
      self.loading();
    };

    this.stop = function(input) {
      self.idle();
      input.trigger('after.searchbox', {searchbox: self});
    };
  };

  $.fn.searchbox = function(config) {
    var settings = $.extend(true, {}, SETTINGS, config || {});

    return this.each(function() {
      var $input = $(this);
      var sb     = new SearchBox(settings);

      $input.data('searchbox', sb);

      $input.trigger('init.searchbox');
      sb.idle();

      $input
      .focus()
      .keyup(function() {
        if ($input.val() != this.previousValue) {
          sb.resetTimer(this.timer);

          this.timer = setTimeout(function() {
            sb.process($input);
          }, sb.settings.delay);

          this.previousValue = $input.val();
        }
      });
    });
  }
})(jQuery);