window.InviteUserView = Backbone.View.extend({
  events:       {
    'ajax:success': 'reload',
    'ajax:error': 'error',
    'focus  [data-widget = "email"]' : "clearText",
  },

  error: function() {
    this.$("[data-widget = 'email']").addClass('error');
  },

  render: function() {
    $(this.el).html($.tmpl(this.template, {invitations_count: this.options.remaining_invitations}));

    return this;
  },

  reload: function(_, data) {
    $("[data-widget = 'remaining_count']").html(data.remaining_count);
    $("[data-widget = 'email']").val('');
    this.$("[data-widget = 'email']").removeClass('error');

    if (data.remaining_count < 1) {
      this.$('input').attr('disabled', true);
    }
  },

  clearText: function(){
    this.$("[data-widget = 'email']").val('');
  },
});

$(function() {
  InviteUserView.template = $('#tmpl-email-invitation').template();
});
