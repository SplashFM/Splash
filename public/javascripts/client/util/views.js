splash.EndlessScroll = Backbone.View.extend({
  initialize: function() {
    _.bindAll(this, 'loaded', 'scroll');

    this.spinner = $('<div/>').
      attr('id', 'loading-spinner').
      addClass('loading-spinner');

    this.spinnerContainer = $(this.options.spinnerContainer);

    this.data = this.options.data;
    this.data.bind('loaded', this.loaded);

    $(document).endlessScroll({callback: this.scroll});
  },

  activate: function() {
    this.active = true;

    return this;
  },

  deactivate: function() {
    this.active = false;

    return this;
  },

  loaded: function() {
    if (this.data.hasNext()) {
      this.spinner.remove();
    } else {
      this.spinnerContainer.html(this.options.noMoreResults);
    }

    return this;
  },

  loading: function() {
    this.spinnerContainer.html(this.spinner);
  },

  scroll: function () {
    if (this.data.hasNext()) {
      this.data.fetchNext();
      this.loading();
    }

    return this;
  }
});
