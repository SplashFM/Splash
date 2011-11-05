$(function() {
  window.Track = Backbone.Model.extend();

  window.TrackList = Backbone.Collection.extend({
    model: Track,
    url: '/tracks'
  });
});
