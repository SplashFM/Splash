window.Notification.AllResults = Backbone.View.extend({
  className: 'all-results',
  animation: new Animation('slide', {direction: 'up'}, 200),
  
  events: {
    'click [data-widget = "close"]': 'close',
    'close:notification'           : 'close'
  },

  initialize: function(){
    this.table = new Notification.AllResults.Results;
    
    this.animation = new Animation('slide', {direction: 'left'}, 500);
    
  },
  
  close: function() {
    alert('ok');
    $(this.el).trigger('notification:collapse');

    this.animation.hide(this.el, function() {
      $(this.el).detach();

      this.table.clear();
    }, this);
  },

  load: function() {
    console.log('3. Notification.AllResults loaded')
    this.setHeader()

    $(this.el).css('height', '100%');

    this.animation.show(this.el, _.bind(function() {
      this.table.load();
    }, this));

    return this;
  },

  render: function() {
    $(this.el).html($.tmpl(this.template));
    $(this.el).append(this.table.el);

    return this;
  },

  resize: function() {
    if (this.$('table').height() > $(this.el).height()) {
      $(this.el).css('height', 'auto');
    }
  },

  setHeader: function() {
    this.$('h2').text('All Notifications');
  },
});

window.Notification.AllResults.Results = Backbone.View.extend({
  tagName: 'table',

  initialize: function() {
    this.collection = new NotificationList;
    this.collection.bind('reset', this.addRanks, this);
    this.collection.bind('reset', this.reset, this);
  },

  addRanks: function(collection) {
    var idxs = _.range(collection.length);

    _(collection.toArray()).
      chain().
      zip(idxs).
      each(function(mi) { mi[0].set({rank: mi[1] + 1}); });
  },

  clear: function() {
    this.$('tbody').empty();
  },

  load: function() {
    //TODO: send page no. 
    console.log('4. Notification.AllResults.Results loaded')
    this.collection.fetch({data: {all: true}});
  },

  render: function() {
    $(this.el).html($.tmpl(this.template));

    var $tbody = this.$('tbody');

    this.collection.each(function(m) {
      var v = new Notification.AllResults.Result({model: m});

      $tbody.append(v.render().el);
    }, this);

    return this;
  },

  reset: function() {
    this.clear();

    this.render();

    $(this.el).trigger('notification:loaded');
  },
});



window.Notification.AllResults.Result = Backbone.View.extend({
  tagName: 'tr',
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


$(function() {
  
  Notification.AllResults.prototype.template =
    $('#tmpl-track-search-all-results').template();
  Notification.AllResults.Results.prototype.template =
    $('#tmpl-notification-all-results-table').template();
  Notification.AllResults.Result.prototype.template =
    $('#tmpl-notification-all').template();

});
