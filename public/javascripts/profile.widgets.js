$(function() {
  window.RelationshipView = Backbone.View.extend({
    events: {'click a': 'toggle'},

    initialize: function() {
      this.nextAction = this.model.isNew() ? 'follow' : 'unfollow';

      this.model.bind('destroy', this.render, this);
      this.model.bind('change',  this.render, this);
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