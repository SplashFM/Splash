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
    $(this.el).html($.tmpl(this.template));

    return this;
  },

  reload: function(_, data) {
    $("[data-widget = 'email']").val('');
    this.$("[data-widget = 'email']").removeClass('error');
  },

  clearText: function(){
    this.$("[data-widget = 'email']").val('');
  },
});

$(function() {
  InviteUserView.template = $('#tmpl-email-invitation').template();
});
