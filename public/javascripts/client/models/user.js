User     = Backbone.Model.extend();
UserList = Backbone.Collection.extend({
  model: splash.User,
  url: '/users',
});
