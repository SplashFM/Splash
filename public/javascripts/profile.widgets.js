$(function() {
  window.ProfileController = Backbone.View.extend({
    initialize: function() {
      this.trackSearch = new TrackSearch({perPage: this.options.tracksPerPage});
      this.eventFeed = new Events({
        app:           window.App,
        currentUserID: this.options.userID,
        filters:       {user: this.options.userID},
        updateFilters: {user: this.options.userID, splashes: 1},
      });
      this.scroll = new EndlessScroll({
        data: this.eventFeed,
        noMoreResults: $('<p/>').
          text(I18n.t('events.all_loaded')).
          addClass('loaded'),
        spinnerContainer: $('.loading-spinner-container'),
      });
      this.relationship = new RelationshipView({
        className: 'follow-container',
        model:     new Relationship(this.options.relationship),
        template:  $('#tmpl-profile-relationship').template(),
      });

      this.allResults = new TrackSearch.AllResults();
    },

    render: function() {
      if (! this.options.isOwner) {
        this.$('.user-vcard > div').append(this.relationship.render().el);
      }

      this.allResults.render();

      return this;
    }
  }).extend(WithAllResults);

  window.RelationshipView = Backbone.View.extend({
    events: {'click a': 'toggle'},

    initialize: function() {
      _.bindAll(this, 'render');

      this.refresh = this.options.refresh == false ? false : true

      this.nextAction = this.model.isNew() ? 'follow' : 'unfollow';

      this.model.bind('destroy', this.changed, this);
      this.model.bind('change',  this.changed, this);

      if (this.refresh) $(this.el).bind('follow unfollow', this.render);
    },

    changed: function() {
      this.running = false;

      $(this.el).trigger(this.currentAction());
    },

    currentAction: function() {
      return this.nextAction == 'follow' ? 'unfollow' : 'follow';
    },

    render: function() {
      $(this.el).html($.tmpl(this.options.template,
                             {nextAction: this.nextAction}).get(0));

      return this;
    },

    toggle: function(e) {
      e.preventDefault();

      if (! this.running) {
        this.running = true;

        if (this.model.isNew()) {
          this.nextAction = 'unfollow';

          this.model.save();
        } else {
          this.nextAction = 'follow';

          this.model.destroy();
          this.model.id = null; // clear id to force creation
        }
      }
    },
  });
});
