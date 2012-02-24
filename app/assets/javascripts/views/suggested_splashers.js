window.SuggestedSplashersView = Backbone.View.extend({
  events: {
    'click [data-widget = "next-suggested-users"]': 'viewMore',
    'ignore:splasher': 'triggerUpdate',
    'follow:splasher': 'triggerUpdate'
  },

  initialize: function() {
    this.collection = new SuggestedSplashers;
    this.collection.bind('reset', this.render, this);
    this.collection.fetch();

    this.cursor      = 0;
    this.suggestions = [];

    this.splashersCount = 3;
  },

  $ul: function() {
    return this._$ul = this.$('ul');
  },

  advanceCursor: function() {
    this.cursor = this.nextPosition(this.cursor);
  },

  appendSuggestion: function(s) {
    this.$ul().append(s.render().el);
  },

  currentSlice: function() {
    var start = this.cursor;
    var end   = this.nextPosition(start);
    var ms    = this.collection.models;

    if (start < end) {
      return ms.slice(start, end);
    } else {
      var before = ms.slice(start, this.collection.length);
      var after  = ms.slice(0, end);

      return before.concat(after);
    }
  },

  makeSuggestion: function(model) {
    var followerID = this.options.followerID;

    return new SuggestedSplasherView({followerID: followerID, model: model});
  },

  nextPosition: function(cursor) {
    return this.wrappedCursor(cursor + this.splashersCount);
  },

  render: function() {
    $(this.el).html($.tmpl(this.template));

    this.resetSuggestions();

    return this;
  },

  resetSuggestions: function() {
    _.invoke(this.suggestions, 'remove');

    this.suggestions = _.map(this.currentSlice(), this.makeSuggestion, this);

    _.each(this.suggestions, this.appendSuggestion, this);

    this.suggestionsChanged();
  },

  suggestionsChanged: function() {
    var su = this.$('[data-widget = "next-suggested-users"]');

    if (this.collection.length <= this.splashersCount) {
      su.hide();
    } else {
      su.show();
    }
  },

  triggerUpdate: function(e, data) {
    this.collection.remove(data.view.model);

    this.cursor = this.wrappedCursor(this.cursor);

    if (this.collection.length > this.splashersCount) {
      var replacement = this.makeSuggestion(_.last(this.currentSlice()));

      this.suggestions.push(replacement);
      this.suggestions.splice(this.suggestions.indexOf(data.view), 1);

      this.appendSuggestion(replacement);
    }

    this.suggestionsChanged();

    data.view.model.destroy();
    data.view.remove(true);
  },

  viewMore: function(e) {
    e.preventDefault();

    this.advanceCursor();

    this.resetSuggestions();
  },

  wrappedCursor: function(cursor) {
    if (cursor >= this.collection.length) {
      return cursor - this.collection.length;
    } else {
      return cursor;
    }
  },
});

window.SuggestedSplasherView = Backbone.View.extend({
  events: {
    'click [data-widget = "delete-suggested-user"]': 'triggerIgnore',
    'follow': 'triggerFollow',
  },
  tagName: 'li',

  initialize: function() {
    _.bindAll(this, 'remove');
  },

  remove: function(animate) {
    var self = this;

    if (animate) {
      $(this.el).animate({height: 0}, {
        duration: 500,
        complete: this.remove
      });

      return this;
    } else {
      return Backbone.View.prototype.remove.call(this);
    }
  },

  render: function() {
    $(this.el).html($.tmpl(this.template, this.model.toJSON()));

    this.$('.wrap').append(this.renderRelationship());

    return this;
  },

  renderRelationship: function() {
    var r = new Relationship({
      follower_id: this.options.followerID,
      followed_id: this.model.id,
    });

    return new RelationshipView({
      model:    r,
      refresh:  false,
      tagName:  'span',
      template: $('#tmpl-suggested-relationship').template(),
    }).render().el;
  },

  triggerFollow: function(e) {
    e.preventDefault();

    $(this.el).trigger('follow:splasher', {view: this})
  },

  triggerIgnore: function(e) {
    e.preventDefault();

    $(this.el).trigger('ignore:splasher', {view: this})
  },
});

$(function() {
  SuggestedSplashersView.prototype.template =
    $('#tmpl-suggested-splashers').template();
  SuggestedSplasherView.prototype.template  =
    $('#tmpl-suggested-splasher').template();
})
