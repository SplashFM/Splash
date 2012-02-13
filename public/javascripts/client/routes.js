$(function () {
  Router = Backbone.Router.extend({
    routes: {
      'top/users/:sample':          'topUsers',
      'top/tracks/:sample/:period': 'topTracks'
    },

    initialize: function(options) {
      this.app = options.app;

      this.app.top = {};
    },

    topTracks: function(sample, period) {
      if (! _(['everyone', 'following']).include(sample)) sample = 'everyone';
      if (! _(['7d', 'alltime']).include(period)) period = 'alltime';

      var opts = {sample: sample, period: period, type: 'tracks'};

      this.activate('splashboard', splash.board.Manager, opts);
    },

    topUsers: function(sample) {
      if (! _(['everyone', 'following']).include(sample)) sample = 'everyone';

      var opts = {sample: sample, type: 'users'};

      this.activate('splashboard', splash.board.Manager, opts);
    },

    activate: function(name, constructor, opts) {
      if (! this.app[name]) this.app[name] = new constructor;

      this.app[name].activate(opts);
    },
  });

  Router.attach = function(app) {
    app.routes = new Router({app: app});

    Backbone.history.start({pushState: true});

    $('body').delegate('a[data-bb]', 'click', function(e) {
      e.preventDefault();

      app.routes.navigate($(e.target).attr('href').substr(1), {trigger: true});
    })
  };

  Router.attach(app);
});
