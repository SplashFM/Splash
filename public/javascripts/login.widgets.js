$(function() {
  window.LoginView = Backbone.View.extend({
    className: 'wrap',
    events: {
      'click a[data-widget = "new-user"]': 'renderAccessRequest',
      'click a[data-widget = "registered-user"]': 'renderSignIn',
      'register:code': 'onCode',
      'forgotpassword': 'renderForgotPassword'
    },

    initialize: function() {
      this.choice         = new NewUserChoice();
      this.accessRequest  = new RequestAccess();
      this.forgotPassword = new ForgotPassword();

      this.registration = new Registration();

      this.signIn = new SignIn();
      this.signIn.bind('signin:unregistered', this.renderChoice, this);
    },

    onCode: function(_, data) {
      this.renderRegistration(data.code);
    },

    renderChoice: function() {
      this.signIn.remove();

      $(this.el).css({paddingTop: '45px'});

      $(this.el).html(this.choice.render().el);
    },

    render: function() {
      if (this.options.to == 'signup') {
        this.renderRegistration();
      } else {
        this.renderChoice();
      }

      return this;
    },

    renderAccessRequest: function() {
      this.choice.remove();

      $(this.el).html(this.accessRequest.render().el);
    },

    renderForgotPassword: function() {
      this.signIn.remove();

      $(this.el).html(this.forgotPassword.render().el);
    },

    renderSignIn: function() {
      this.choice.remove();

      $(this.el).css({paddingTop: '90px'});

      $(this.el).html(this.signIn.render().el);
    },

    renderRegistration: function(code) {
      this.choice.remove();

      $(this.el).css({paddingTop: '20px'});

      $(this.el).html(this.registration.render(code || this.options.code).el);
    },
  });

  window.ForgotPassword = Backbone.View.extend({
    events: {
      'ajax:success form': 'passwordReset',
    },

    template: $('#tmpl-forgot-password').template(),

    passwordReset: function() {
      $(this.el).html(I18n.t('devise.passwords.send_instructions'));
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

      return this;
    },
  });


  window.NewUserChoice = Backbone.View.extend({
    className: 'wrap',
    template: $('#tmpl-choice').template(),

    render: function() {
      $(this.el).html($.tmpl(this.template));

      return this;
    },
  });

  window.RequestAccess = Backbone.View.extend({
    className:    'wrap',
    events:       {
      'ajax:success': 'requested',
      'ajax:error': 'failed',
      'keyup input[name = "access_code"]': 'onCode',
    },
    template:     $('#tmpl-request-invite').template(),
    sentTemplate: $('#tmpl-request-invite-sent').template(),

    initialize: function() {
      _.bindAll(this, 'onValidCode', 'onInvalidCode');
    },

    failed: function() {
      this.$('form input').addClass('error');
    },

    onCode: function(e) {
      if (e.keyCode === $.ui.keyCode.ENTER) {
        var code = $(e.target).val();

        $.ajax({
          url:  Routes.verify_access_requests_path({code: code}),
          error: this.onInvalidCode,
          success: this.onValidCode,
        });
      }
    },

    onInvalidCode: function() {
      this.$('[name = "access_code"]').addClass('error');
    },

    onValidCode: function() {
      var $input = this.$('[name = \"access_code\"]');

      $input.removeClass('error');

      $(this.el).trigger('register:code', {code: $input.val()});
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

      return this;
    },

    requested: function() {
      $(this.el).html($.tmpl(this.sentTemplate));
    },
  });

  window.Registration = Backbone.View.extend({
    events: {
      'ajax:success form': 'onRegister',
      'ajax:error form': 'onErrors'
    },
    template: $('#tmpl-registration').template(),

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

    render: function(accessCode) {
      $(this.el).html($.tmpl(this.template, {accessCode: accessCode}));

      this.$('.omniauth-links a').each(function() {
        var orig = $.param.querystring(window.location.href,
                                       $.param({code: accessCode}));
        var url  = $.param.querystring($(this).attr('href'),
                                       $.param({origin: orig}));

        $(this).attr('href', url);
      });

      return this;
    },
  });

  window.SignIn = Backbone.View.extend({
    template: $('#tmpl-sign-in').template(),

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

    triggerForgotPassword: function() {
      $(this.el).trigger('forgotpassword');
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
