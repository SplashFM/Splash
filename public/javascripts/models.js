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

  window.Event     = Backbone.Model.extend();
  window.EventList = Backbone.Collection.extend({
    model: Event,
    url: '/events',

    parse: function(response) {
      this.recordUpdate(response);

      return response.results;
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
