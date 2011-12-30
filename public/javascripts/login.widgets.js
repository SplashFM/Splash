$(function() {
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

  window.CodeTest = Backbone.View.extend({
    className: 'code-test',
    events: {
      'keyup input': 'verify',
      'click p.submit.via-email input': 'verify',
    },

    template: $('#tmpl-code-test').template(),

    initialize: function() {
      _.bindAll(this, 'onInvalidCode', 'onValidCode');
    },

    onInvalidCode: function() {
      this.$('input').addClass('error');
    },

    onValidCode: function() {
      var $input = this.$('input');

      $input.removeClass('error');

      $(this.el).trigger('register:code', {code: $input.val()});
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

      return this;
    },

    verify: function(e) {
      if (e.type === 'click' || e.keyCode === $.ui.keyCode.ENTER) {
        var code = this.$('[name = "access_code"]').val();

        $.ajax({
          url:  Routes.verify_access_requests_path({code: code}),
          error: this.onInvalidCode,
          success: this.onValidCode,
        });
      }

    },
  });


  window.RequestInvite = Backbone.View.extend({
    className: 'signup',
    events: {
      'click [href = "#request-invite-email"]': 'renderRequestInviteEmail',
      'click [href = "#code-test"]': 'renderCodeTest',
      'invited': 'userInvited',
      'register:code': 'onCode',
    },
    template: $('#tmpl-request-invite').template(),
    templateConfirmed: $('#tmpl-request-invite-confirmed').template(),
    templateRegistering: $('#tmpl-request-invite-registering').template(),

    onCode: function() {
      this.renderRegistrationInfo();
    },

    render: function() {
      if (this.options.registering) {
        this.renderRegistrationInfo();
      } else if (window.location.pathname == this.options.invitePath) {
        this.renderInviteConfirmation(this.options);
      } else {
        $(this.el).html($.tmpl(this.template));
      }

      return this;
    },

    renderCodeTest: function() {
      $(this.el).html(new CodeTest().render().el);
    },

    renderInviteConfirmation: function(data) {
      $(this.el).html(new SocialShare().render(data).el);
    },

    renderRegistrationInfo: function() {
      $(this.el).html($.tmpl(this.templateRegistering));
    },

    renderRequestInviteEmail: function() {
      $(this.el).html(new RequestInviteEmail().render().el);
    },

    userInvited: function(_, data) {
      this.renderInviteConfirmation(data);
    },
  });

  window.SocialShare = Backbone.View.extend({
    events: {
      'click [href = "#twitter-share"]': 'twitterPost',
    },
    templateConfirmed: $('#tmpl-request-invite-confirmed').template(),

    shareUrl: function() {
      return $(".referral-url").val();
    },

    twitterPost: function() {
      text = encodeURIComponent("Check out http://www.Splash.FM, a new website for social music discovery - " + this.shareUrl());
      window.open("http://twitter.com/intent/tweet?text="+text+"&via=splash.fm&text=","tweet_window","channelmode=no,directories=no,location=no,menubar=no,scrollbars=no,toolbar=no,status=no,width=500,height=375,left=300,top=200");
    },

    render: function(data) {
      $(this.el).html($.tmpl(this.templateConfirmed, data));

      return this;
    },
  });


  window.RequestInviteEmail = Backbone.View.extend({
    events: {
      'ajax:success': 'accepted',
      'ajax:error':   'refused',
    },
    template: $('#tmpl-request-invite-email').template(),

    accepted: function(_, user) {
      $(this.el).trigger('invited', {referralURL: user.referral_url});
    },

    refused: function() {
      this.$('form input').addClass('error');
    },

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
    className: 'wrap',
    events: {
      'ajax:before form': 'validate',
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

    render: function() {
      var accessCode = this.options.accessCode;

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
