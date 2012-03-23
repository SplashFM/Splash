Backbone.View.mixin = function(module) {
  _.defaults(this.prototype,        module);
  _.defaults(this.prototype.events, module.events);

  return this;
}

Purchase = {
  events: {
    'click [data-widget = "purchase"]': 'purchase'
  },

  purchase: function(e) {
    e.preventDefault();

    if (! itmsOpen($(e.target).attr('href')))
      window.open($(e.target).attr('href'));
  },
};

window.BaseApp = Backbone.View.extend({
  initialize: function() {
    this.globalSearch  = new BaseApp.GlobalSearch;
    this.userSearch    = new BaseApp.UserSearch;
    this.notifications = new BaseApp.Notifications({
      el: $('[data-widget = "notifications"]')
    });
  },
});

window.BaseApp.SplashAction = Backbone.View.extend({
  initialize: function() {
    _.bindAll(this, 'broadcastSplash', 'splash');
  },

  broadcastSplash: function() {
    $(this.el).trigger('splash:splash', {track: this.model});
  },
});

window.FullSplashAction = BaseApp.SplashAction.extend({
  events: {
    'submit form': 'splash'
  },

  initialize: function() {
    BaseApp.SplashAction.prototype.initialize.call(this);

    _.bindAll(this, 'finishSplash');

    this.comment  = new SplashComment({el: this.$('form textarea')});

    this.toggle   = new Toggle({
      el:        this.$('[data-widget = "toggle-splash"]'),
      target:    this.$('form'),
      isEnabled: this.model.get('splashable'),
    });
    this.toggle.bind('toggle:show', this.triggerOpen, this);
    this.toggle.bind('toggle:hide', this.triggerClose, this);
  },

  broadcastSplash: function() {
    if (this.options.parent) {
      $(this.el).trigger('splash:resplash', {track: this.model});
    } else {
      BaseApp.SplashAction.prototype.broadcastSplash.call(this);
    }
  },

  splash: function(e) {
    e.preventDefault();

    this.$('input[type = "submit"]').attr('disabled', true);

    new Splash().save({
      share: {
        facebook: this.$('input[name = "post_to_fb"]').attr('checked')
      },
      comment:  this.comment.comment(),
      track_id: this.model.get('id'),
      parent_id: this.options.parent && this.options.parent.get('id'),
    }, {
      success: this.finishSplash,
      wait: true
    });
  },

  triggerClose: function() {
    this.trigger('splash:close');
  },

  triggerOpen: function() {
    this.trigger('splash:open');
  },

  finishSplash: function() {
    this.toggle.toggle();
    this.toggle.disable();
    // FIXME: neither of these seem to actually trigger a rerender of the single view.
    this.broadcastSplash();
    this.model.change();
  }
});


window.BaseApp.QuickSplashAction = BaseApp.SplashAction.extend({
  events: {'click' : 'splash'},

  broadcastSplash: function() {
    $(this.el).trigger('splash:quick', {track: this.model});
  },

  splash: function() {
    new Splash().save({track_id: this.model.get('id')},
                    {success: this.broadcastSplash});
  },
});

window.BaseApp.Notifications = Backbone.View.extend({
  events: {
    'click [data-widget = "toggle-notifications"]': 'toggle',
    'click div.item': 'toggle'
  },

  initialize: function() {
    _.bindAll(this, 'renderNotification', 'setCount', 'toggle');

    this.list       = this.$('[data-widget = "list-notifications"]');

    this.collection = new NotificationList;
    this.collection.bind('reset', this.reset, this);
    this.collection.fetch();
    var _this = this;
    $(this.el).clickout(function(){ if($('.dropDown',_this.el).is(':visible')) {
      _this.toggle();
    }});
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
    this.collection.unreadCount({success: this.setCount});

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
  events: {'click': 'showTarget'},

  render: function() {
    $(this.el).addClass(this.model.get('type'));

    $(this.el).html($.tmpl(this.template, this.model.toJSON()));

    return this;
  },

  showTarget: function() {
    switch (this.model.get('type')) {
    case 'following':
      Backbone.history.navigate(this.model.get('notifier').url, {trigger: true});

      break;
    case 'mention':
    case 'commentforsplasher':
    case 'commentforparticipants':
      r = SingleSplash.Router.routes.splashes(this.model.get('splash_id'));
      Backbone.history.navigate(r, {trigger: true});
    }
  },
});

window.BaseApp.GlobalSearch = Backbone.View.extend({
  el: '[data-widget = "global-search"]',
  events: {
    'focus .field': 'expand',
    'search:hide': 'collapse'
  },

  initialize: function() {
    _.bindAll(this, 'collapse');

    $(this.el).clickout(this.collapse);
  },

  collapse: function() {
    this.$(':text').val('');

    this.$el.removeClass('opened')
  },

  expand: function() {
    this.$el.addClass('opened')
  },
});


window.BaseApp.UserSearch = Search.extend({
  el: '[data-widget = "global-search"]',
  cancelableSearch: true,
  menuContainer: '[data-widget = "users"] ul',

  initialize: function(opts) {
    this.collection = new UserList;

    Search.prototype.initialize.call(this, opts)
  },

  renderItem: function(i) {
    return new UserView({model: i}).render().$el.appendTo(this.menu);
  },
});

window.BaseApp.TrackSearch = Search.extend({
  el: '[data-widget = "global-search"]',
  cancelableSearch: true,
  menuContainer: '[data-widget = "tracks"] ul',
  extraParams: {popular: true, short: true},

  initialize: function(opts) {
    this.collection = new TrackList;

    Search.prototype.initialize.call(this, opts)
  },

  renderItem: function(i) {
    return new TrackSearch.Track({model: i}).render().$el.appendTo(this.menu);
  },
});

ViewAllResults.addTo(BaseApp.TrackSearch)

window.UserMentions = Backbone.View.extend({
  initialize: function() {
    _.bindAll(this, 'find', 'isSearchable', 'onClose', 'onSelect');

    this.showingMenu = false;

    $(this.el).autocomplete({
      appendTo:  this.options.parent,
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
    return $(this.el).val();
  },

  find: function(req, resp) {
    var term    = req.term;
    var at      = term.lastIndexOf('@');
    var mention = term.substr(at + 1);

    $.ajax({
      url: Routes.users_path({filter: mention, following: 1}),
      dataType: 'json',
      success: function(data) {
        resp($.map(data, function(e) {
          return {value: e.nickname};
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

    $(e.target).setSelection(0, $(e.target).val().length);
    $(e.target).collapseSelection(false);

    return false;
  },
});

UserMentions.linkMentions = function(text) {
  return text.replace(Constants.NICKNAME_REGEXP, '<a href="$1">$1</a>');
};

window.List = Backbone.View.extend({
  tagName: 'ul',

  initialize: function() {
    _.bindAll(this, 'renderItem');

    this.itemTemplate = this.options.itemTemplate;
    this.items        = this.options.items;
  },

  render: function() {
    _.each(this.items, this.renderItem);

    return this;
  },

  renderItem: function(i) {
    return $('<li/>').append($.tmpl(this.itemTemplate, i)).appendTo(this.el);
  },
});

window.Toggle = Backbone.View.extend({
  events: {'click': 'toggleTarget'},

  initialize: function() {
    this.$target   = $(this.options.target);
    this.isEnabled = this.options.isEnabled;

    if (this.options.doToggle) this.doToggle = this.options.doToggle;
  },

  disable: function() {
    this.isEnabled = false;
  },

  doToggle: function() {
    this.$target.toggle();
  },

  toggle: function() {
    if (this.isEnabled) this.doToggle();

    this.triggerToggled();
  },

  toggleTarget: function(e) {
    e.preventDefault();

    this.toggle();
  },

  triggerToggled: function() {
    if (this.$target.is(':visible')) {
      this.trigger('toggle:show');
    } else {
      this.trigger('toggle:hide');
    }
  },
});

window.SplashComment = Backbone.View.extend({
  initialize: function() {
    this.mentions = new UserMentions({
      el:     $(this.el),
      parent: $(this.el).parent(),
    });
  },

  comment: function() {
    return this.mentions.commentWithMentions();
  },
});

$(function() {
  BaseApp.Notifications.Notification.prototype.template =
    $('#tmpl-notification').template();
  BaseApp.UserSearch.prototype.template =
    $('#tmpl-user').template();
  BaseApp.UserSearch.prototype.templateRelationship =
    $('#tmpl-relationship-list').template();
});
