$(function() {
  window.LoginView = Backbone.View.extend({
    className: 'wrap',
    events: {
      'click a[data-widget = "new-user"]': 'renderRegistration',
      'click a[data-widget = "registered-user"]': 'renderSignIn',
    },

    initialize: function() {
      this.choice = new NewUserChoice();

      this.registration = new Registration();

      this.signIn = new SignIn();
      this.signIn.bind('signin:unregistered', this.renderChoice, this);
    },

    renderChoice: function() {
      this.signIn.remove();

      $(this.el).css({paddingTop: '45px'});

      $(this.el).html(
        this.choice.render().email(this.signIn.email()).el);
    },

    render: function() {
      this.renderChoice();

      return this;
    },

    renderSignIn: function() {
      this.choice.remove();

      $(this.el).css({paddingTop: '90px'});

      $(this.el).html(this.signIn.render().el);
    },

    renderRegistration: function() {
      this.choice.remove();

      $(this.el).css({paddingTop: '20px'});

      $(this.el).html(this.registration.render().el);
    },
  });

  window.NewUserChoice = Backbone.View.extend({
    className: 'wrap',
    template: $('#tmpl-choice').template(),

    email: function(val) {
      this.$('.email').text(val);

      return this;
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

      return this;
    },
  });

  window.Registration = Backbone.View.extend({
    events: {
      'ajax:success': 'onRegister',
      'ajax:error': 'onErrors'
    },
    template: $('#tmpl-registration').template(),

    email: function(val) {
      this.$('[name = "user[email]"]').val(val);

      return this;
    },

    onErrors: function(_, xhr) {
      var errors = $.parseJSON(xhr.responseText);

      for (var k in errors) {
        switch (k) {
        case 'email':
          this.$('[name = "user[email]"]').addClass('error');

          break;
        case 'password':
          this.$('[name = "user[password]"]').addClass('error');
          this.$('[name = "user[password_confirmation]"]').addClass('error');

          break;
        }
      }
    },

    onRegister: function() {
      window.location.href = Routes.home_path();
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

      return this;
    },
  });

  window.SignIn = Backbone.View.extend({
    events: {
      'ajax:success': 'onLogin',
      'ajax:error': 'onLoginFailed',
      'click #forgot_password': 'resetPassword',
    },
    template: $('#tmpl-sign-in').template(),

    initialize: function() {
      _.bindAll(this, 'onNewUser', 'onRegisteredUser');
    },

    email: function(val) {
      return this._email;
    },

    onNewUser: function() {
      this.trigger('signin:unregistered');
    },

    onRegisteredUser: function() {
      this.wrapper.animate({paddingTop: 90 - 53});
      this.pwdField.show();
      this.pwdField.focus();
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

      this.wrapper        = this.$('.main .wrap');
      this.emailField     = this.$('[data-widget = "user-email"]')
      this.pwdField       = this.$('#user_password');
      this.forgotPwdField = this.$('#forgot_password');

      return this;
    },

    resetPassword: function() {
      // TODO: Show flash messages (the ones on Widgets.SignIn weren't working).
      $.ajax({
        type: 'post',
        url: Routes.user_password_path(),
        data: {'user[email]': this.emailField.val()},
      });
    },

    onLogin: function() {
      this.$("#user_password").removeClass('error');
      this.$("#forgot_password").hide();

      window.location.href = Routes.home_path();
    },

    onLoginFailed: function() {
      this.$("#user_password").addClass('error');
      this.$("#forgot_password").show();
    },
  });
});
