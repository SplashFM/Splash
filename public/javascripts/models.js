$(function() {
  window.Track     = Backbone.Model.extend();
  window.TrackList = Backbone.Collection.extend({
    model: Track,
    url: '/tracks'
  });

  window.User     = Backbone.Model.extend();
  window.UserList = Backbone.Collection.extend({
    model: User,
    url: '/users'
  });
});
