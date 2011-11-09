$(function() {
  window.Paginated = {
    hasFullPages: function(perPage) {
      return this.length % perPage == 0;
    }
  };

  window.Track     = Backbone.Model.extend();
  window.TrackList = Backbone.Collection.extend({
    model: Track,
    url: '/tracks'
  }).extend(Paginated);

  window.User     = Backbone.Model.extend();
  window.UserList = Backbone.Collection.extend({
    model: User,
    url: '/users'
  }).extend(Paginated);

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

    url: function() {
      return "/splashes/" + this.get('id');
    },
  });
  window.EventList = Backbone.Collection.extend({
    model: Event,
    url: '/events',

    parse: function(response) {
      this.recordUpdate(response);

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
  }).extend(Paginated);
});
