Track     = Backbone.Model.extend();
TrackList = Backbone.Collection.extend({
  model: splash.Track,
  url: '/tracks',
});
