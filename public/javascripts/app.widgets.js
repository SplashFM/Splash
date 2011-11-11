$(function() {
  window.BaseApp = Backbone.View.extend({
    initialize: function() {
      this.userSearch  = new BaseApp.UserSearch;
      this.trackSearch = new BaseApp.TrackSearch;
      this.quickSplash = new BaseApp.QuickSplash;

      _.bindAll(this, 'triggerScroll');

      $(document).endlessScroll({
        callback: this.triggerScroll
      });
    },

    triggerScroll: function () {
      this.trigger('endlessScroll');
    }
  });

  window.BaseApp.SplashAction = Backbone.View.extend({
    initialize: function() {
      _.bindAll(this, 'broadcastSplash', 'splash');
    },

    broadcastSplash: function() {
      $(this.el).trigger('splash:splash');
    },

    splash: function() {
      new Splash().save({track_id: this.model.get('id')},
                      {success: this.broadcastSplash});
    },
  });


  window.BaseApp.QuickSplashAction = BaseApp.SplashAction.extend({
    initialize: function() {
      BaseApp.SplashAction.prototype.initialize.call(this);

      this.el = $('[data-widget = "quick-splash-action"]',
                  this.options.parent).get(0);

      $(this.el).bind('click', this.splash);
    },
  });


  window.BaseApp.QuickSplash = Search.extend({
    collection: new TrackList,
    el: '[data-widget = "quick-splash"]',
    events: _.extend({
      'click [data-widget = "toggle"]' : 'toggle',
    }, Search.prototype.events),
    template: '#tmpl-quick-splash-track',

    hide: function() {
      Search.prototype.hide.call(this);

      this.$('[data-widget = "box"]').hide();
    },

    hideResults: function() {
      this.menu.hide();
    },

    renderItem: function(i) {
      var trackView = Search.prototype.renderItem.call(this, i);

      new BaseApp.QuickSplashAction({model: i, parent: trackView});
    },

    toggle: function() {
      this.hideResults();
      this.toggleInput();
    },

    toggleInput: function() {
      this.$('[data-widget = "box"]').toggle();
    }
  });

  window.BaseApp.UserSearch = Search.extend({
    collection: new UserList,
    el: '[data-widget = "global-search"]',
    menuContainer: '[data-widget = "users"] ul',
    template: '#tmpl-global-search-user',
  });

  window.BaseApp.TrackSearch = Search.extend({
    collection: new TrackList,
    el: '[data-widget = "global-search"]',
    menuContainer: '[data-widget = "tracks"] ul',
    template: '#tmpl-global-search-track',

    cycle: function(item, even, odd) {
      if (this.currentCycle != odd) {
        this.currentCycle = odd;
      } else {
        this.currentCycle = even;
      }

      if (this.currentCycle) item.addClass(this.currentCycle);
    },

    renderItem: function(i) {
      this.cycle(Search.prototype.renderItem.call(this, i), 'even', 'odd');
    }
  });

  window.PlayerView = Backbone.View.extend({
    template: $('#tmpl-player').template(),

    initialize: function() {
      _.bindAll(this, 'play');

      $('body').bind('request:play', this.play);
    },

    play: function(_, data) {
      var media = {};
      media[data.track.preview_type] = data.track.preview_url;

      $('#player-area').html($.tmpl(this.template, data.track));

      $("[data-widget = 'player']").
        jPlayer({cssSelectorAncestor: '[data-widget = "player-ui"]',
                 swfPath:             'Jplayer.swf',
                 supplied:            data.track.preview_type,
                 ready: function() {
                   $(this).
                     jPlayer('setMedia', media).
                     jPlayer('play');
                 }});
    },
  });

  window.Player = new PlayerView;
});