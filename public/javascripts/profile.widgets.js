$(function() {
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

      if (this.model.isNew()) {
        this.model.save();

        this.nextAction = 'unfollow';
      } else {
        this.model.destroy();
        this.model.id = null; // clear id to force creation

        this.nextAction = 'follow';
      }
    },
  });
});