$(function() {
  window.BaseApp = Backbone.View.extend({
    initialize: function() {
      this.userSearch    = new BaseApp.UserSearch;
      this.trackSearch   = new BaseApp.TrackSearch;
      this.quickSplash   = new BaseApp.QuickSplash;
      this.notifications = new BaseApp.Notifications({
        el: $('[data-widget = "notifications"]')
      });

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
  });


  window.BaseApp.QuickSplashAction = BaseApp.SplashAction.extend({
    events: {'click' : 'splash'},

    splash: function() {
      new Splash().save({track_id: this.model.get('id')},
                      {success: this.broadcastSplash});
    },
  });

  window.BaseApp.Notifications = Backbone.View.extend({
    events: {
      'click [data-widget = "toggle-notifications"]': 'toggle'
    },

    initialize: function() {
      _.bindAll(this, 'renderNotification');

      this.list       = this.$('[data-widget = "list-notifications"]');

      this.collection = new NotificationList;
      this.collection.bind('reset', this.reset, this);
      this.collection.fetch();
    },

    isActive: function() {
      return $(this.el).hasClass('active');
    },

    renderNotification: function(model) {
      $('.load_more', this.list).before(new BaseApp.Notifications.Notification({
        model: model
      }).render().el);
    },

    reset: function() {
      this.setCount(this.collection.length);

      this.collection.each(this.renderNotification);
    },

    setCount: function(count) {
      this.$('[data-widget = "toggle-notifications"]').text(count);

      if (count > 0) {
        $(this.el).addClass('new');
      } else {
        $(this.el).removeClass('new');
      }

    },

    toggle: function() {
      this.list.toggle();

      $(this.el).toggleClass('active');

      if (this.isActive()) {
        this.collection.markRead();

        this.setCount(0);
      }
    },
  });

  window.BaseApp.Notifications.Notification = Backbone.View.extend({
    tagName: 'div',
    className: 'item',
    template: $('#tmpl-notification').template(),

    render: function() {
      $(this.el).addClass(this.model.get('type'));

      $(this.el).html($.tmpl(this.template, this.model.toJSON()));

      return this;
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
      var trackEl = Search.prototype.renderItem.call(this, i);

      new BaseApp.QuickSplashAction({
        model: i,
        el: $('[data-widget = "quick-splash-action"]', trackEl)
      });
    },

    toggle: function() {
      this.hideResults();
      this.toggleInput();
    },

    toggleInput: function() {
      var box = this.$('[data-widget = "box"]');

      box.toggle();

      if (box.is(':visible')) $(':text', box).focus();
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
                 swfPath:             '/Jplayer.swf',
                 supplied:            data.track.preview_type,
                 ready: function() {
                   $(this).
                     jPlayer('setMedia', media).
                     jPlayer('play');
                 }});
    },
  });

  window.UserMentions = Backbone.View.extend({
    initialize: function() {
      _.bindAll(this, 'find', 'isSearchable', 'onClose', 'onSelect');

      this.showingMenu = false;
      this.mentions    = [];

      $(this.el).autocomplete({
        autoFocus: true,
        close:     this.onClose,
        delay:     0,
        focus:     function() { return false },
        search:    this.isSearchable,
        select:    this.onSelect,
        source:    this.find,
      }).keydown(function(e) {
        if (e.which === $.ui.keyCode.TAB) e.preventDefault();
      });
    },

    atMention: function(input) {
      var cursor = $(input).getSelection().start;
      var text   = $(input).val();

      return text.substr(0, cursor).match(/@\w$/) != null;
    },

    commentWithMentions: function() {
      var text = $(this.el).val();

      $.each(this.mentions, function(_, m) {
        text = text.replace(m[0], "{" + m[1] + "}");
      });

      return text;
    },

    find: function(req, resp) {
      var term    = req.term;
      var at      = term.lastIndexOf('@');
      var mention = term.substr(at + 1);

      $.ajax({
        url: Routes.users_path({filter: mention}),
        dataType: 'json',
        success: function(data) {
          resp($.map(data, function(e) {
            return {value: e.id, label: e.name};
          }));
        }
      });
    },

    isSearchable: function(e) {
      return (this.showingMenu ||
              (this.showingMenu = this.atMention(e.target)));
    },

    onClose: function() {
      this.showingMenu = false;
    },

    onSelect: function(e, ui) {
      var l      = ui.item.label;
      var v      = ui.item.value;
      var text   = $(e.target).val();
      var before = text.substr(0, text.lastIndexOf('@'));
      var after  = text.substr(text.lastIndexOf('@'));

      $(e.target).val(before + '@' + l);

      this.mentions.push([l, v]);

      $(e.target).setSelection(0, $(e.target).val().length);
      $(e.target).collapseSelection(false);

      return false;
    },
  });

  window.Player = new PlayerView;
});
