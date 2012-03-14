$(function() {
  window.RelationshipView = Backbone.View.extend({
    events: {'click a': 'toggle'},

    initialize: function() {
      _.bindAll(this, 'relabel', 'render');

      this.refresh = this.options.refresh == false ? false : true

      this.nextAction = this.model.isNew() ? 'follow' : 'unfollow';

      this.model.bind('destroy', this.changed, this);
      this.model.bind('change',  this.changed, this);

      if (this.refresh) $(this.el).bind('follow unfollow', this.relabel);
    },

    changed: function() {
      this.running = false;

      $(this.el).trigger(this.currentAction());
    },

    currentAction: function() {
      return this.nextAction == 'follow' ? 'unfollow' : 'follow';
    },

    relabel: function() {
      this.$('a').text(I18n.t('users.show.' + this.nextAction))
    },

    render: function() {
      $(this.el).html($.tmpl(this.options.template,
                             {nextAction: this.nextAction}).get(0));

      return this;
    },

    toggle: function(e) {
      e.preventDefault();

      if (! this.running) {
        this.running = true;

        if (this.model.isNew()) {
          this.nextAction = 'unfollow';

          this.model.save();
        } else {
          this.nextAction = 'follow';

          this.model.destroy();
          this.model.id = null; // clear id to force creation
        }
      }
    },
  });
});
