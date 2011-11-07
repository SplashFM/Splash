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
    url: '/events'
  }).extend(Paginated);
});
