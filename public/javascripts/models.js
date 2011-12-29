$(function() {
  window.Paginated = {
    hasFullPages: function(perPage) {
      return this.length > 0 && this.length % perPage == 0;
    }
  };

  HasMoreResults = {
    hasMoreResults: function() {
      return this._hasMoreResults;
    },

    setHasMoreResults: function(results) {
      this._hasMoreResults = results.length >=
        Constants.SPLASHBOARD_ITEMS_PER_PAGE;
    },
  }

  window.Relationship = Backbone.Model.extend({
    urlRoot: '/relationships',
  });

  window.Track             = Backbone.Model.extend({
    flag: function(){
      $.ajax({
        type: 'post',
        url: '/tracks/' + this.get('id') + '/flag'
      });
    }
  });
  window.UndiscoveredTrack = Track.extend({
    urlRoot: '/undiscovered_tracks'
  });
  window.TrackList         = Backbone.Collection.extend({
    model: Track,
    url: '/tracks',

    initialize: function() {
      this.setHasMoreResults(true);
    },

    parse: function(response) {
      this.setHasMoreResults(response);

      return Backbone.Collection.prototype.parse.call(this, response);
    },
  }).
    extend(Paginated).
    extend(HasMoreResults);

  window.User     = Backbone.Model.extend();
  window.UserList = Backbone.Collection.extend({
    model: User,
    url: '/users',

    initialize: function() {
      this.setHasMoreResults(true);
    },

    parse: function(response) {
      this.setHasMoreResults(response);

      return Backbone.Collection.prototype.parse.call(this, response);
    },
  }).
    extend(Paginated).
    extend(HasMoreResults);

  window.SuggestedSplasher  = Backbone.Model.extend({
    urlRoot: '/suggested_splashers',
  });
  window.SuggestedSplashers = Backbone.Collection.extend({
    model: SuggestedSplasher,
    url: '/suggested_splashers',
  })

  window.Comment     = Backbone.Model.extend({
    url: "/comments"
  });
  window.CommentList = Backbone.Collection.extend({
    model: Comment,

    create: function(c, opts) {
      c.splash_id = this.parent().get('id');

      Backbone.Collection.prototype.create.call(this, c, opts);
    },

    parent: function(p) {
      if (p) {
        this._parent = p;

        return this;
      } else {
        return this._parent;
      }
    },
  });
  window.Event       = Backbone.Model.extend();
  window.Splash      = Event.extend({
    initialize: function(attrs) {
      this._comments = new CommentList().parent(this);

      this.bind('change', this.resetComments, this);
    },

    comments: function() {
      return this._comments;
    },

    resetComments: function() {
      var self = this;

      this._comments.reset(this.get('comments'));
    },

    urlRoot: '/splashes',

    url: function() {
      if (this.isNew()) {
        return this.urlRoot;
      } else {
        return this.urlRoot + "/" + this.get('id');
      }
    },

    share: function(site){
      $.ajax({
        type: 'post',
        url: '/splashes/' + this.get('id') + '/share',
        data: {site: site},
        success: function(data){
          $('[data-id = "' + data.id + '"].social_link')
            .find('img')
            .attr('src', '/images/twitter-btn-gray.png');
        }
      });
    },
  });
  window.SplashList = Backbone.Collection.extend({
    url: "/splashes"
  });

  window.EventList = Backbone.Collection.extend({
    model: Event,
    url: '/events',

    initialize: function() {
      this.setHasMoreResults(true);
    },

    parse: function(response) {
      this.recordUpdate(response);

      this.setHasMoreResults(response.results);

      return _.map(response.results, function(e) {
        switch (e.type) {
        case "splash": return new Splash(e);
        default:       return new Event(e);
        }
      });
    },

    recordUpdate: function(resp) {
      this.lastUpdate = resp.last_update_at;
    },

    updateCount: function(filters, resultFunc) {
      var self = this;
      var f    = _.extend({count: true,
                           last_update_at: this.lastUpdate}, filters);

      return $.get(this.url, f).
        done(function(response) {
          self.recordUpdate(response);

          resultFunc.call(this, response.results);
        });
    },
  }).
    extend(Paginated).
    extend(HasMoreResults);

  window.Notification     = Backbone.Model.extend({});
  window.NotificationList = Backbone.Collection.extend({
    url: '/notifications',

    markRead: function() {
      $.ajax(Routes.reset_read_notifications_path(), {type: 'PUT'});
    },

    unreadCount: function(opts) {
      $.ajax(this.url, {data: {count: 1}}).done(opts.success);
    },
  });
});
