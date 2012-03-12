$(function() {
  window.ForgotPassword = Backbone.View.extend({
    events: {
      'ajax:success form': 'passwordReset',
      'ajax:error form': 'error',
    },

    template: $('#tmpl-forgot-password').template(),

    error: function() {
      this.$(':text').addClass('error');
    },

    passwordReset: function() {
      $(this.el).html(I18n.t('devise.passwords.send_instructions'));
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

      return this;
    },
  });

  window.Registration = Backbone.View.extend({
    className: 'wrap',
    events: {
      'ajax:before form': 'validate',
      'ajax:success form': 'onRegister',
      'ajax:error form': 'onErrors',
      'click .login-toggle': 'toggleLogin'
    },
    template: $('#tmpl-registration').template(),

    focus: function() {
      this.$('#user_email').focus();

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
      var email      = this.options.email;
      var accessCode = this.options.accessCode;

      $(this.el).html($.tmpl(this.template, {email: email}));

      this.$('.omniauth-links a').each(function() {
        var orig = $.param.querystring(window.location.href,
                                       $.param({code: accessCode}));
        var url  = $.param.querystring($(this).attr('href'),
                                       $.param({origin: orig}));

        $(this).attr('href', url);
      });

      return this;
    },

    toggleLogin: function() {
      this.$el.trigger('signin:close', {email: this.$('#user_email').val()});
    },

    validate: function() {
      if (! this.$('#age').is(':checked')) {
        this.$('label[for = "age"]').addClass('error');

        return false;
      }
    },
  });

  window.SignIn = Backbone.View.extend({
    className: 'wrap',
    template: $('#tmpl-sign-in').template(),

    events: {
      'click .signup-toggle': 'toggleSignup'
    },

    initialize: function() {
      _.bindAll(this, 'onLogin', 'onLoginFailed', 'onNewUser',
                      'onRegisteredUser', 'triggerForgotPassword');
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

      this.$('form').
        bind('ajax:success', this.onLogin).
        bind('ajax:error', this.onLoginFailed);

      this.$('#forgot_password').click(this.triggerForgotPassword)

      return this;
    },

    toggleSignup: function() {
      this.$el.trigger('signin:unregistered');
    },

    triggerForgotPassword: function() {
      this.$('.signin').html(new ForgotPassword().render().el);
    },

    onLogin: function() {
      this.$("#user_password").removeClass('error');
      this.$("#forgot_password").hide();

      window.location.href = Routes.home_path();
    },

    onLoginFailed: function() {
      this.$el.trigger('signin:unregistered', {email: this.emailField.val()});
    }
  });
});
