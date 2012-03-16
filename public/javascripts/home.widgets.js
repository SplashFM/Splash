$(function() {
  window.InviteUserView = Backbone.View.extend({
    events:       {
      'ajax:success': 'reload',
      'ajax:error': 'error',
      'focus  [data-widget = "email"]' : "clearText",
    },

    template: $('#tmpl-email-invitation').template(),

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

  window.Tutorial = Backbone.View.extend({
    className: 'tutorial',
    events: {'click .close a': 'hide'},
    template: $('#tmpl-tutorial').template(),

    initialize: function() {
      _.bindAll(this, 'hide', 'pauseSlideShow', 'center', 'centerShade',
                      'renderShade', 'updateNavigation');

      this.shadeEl   = $('<div class="tutorial-wrap"></div>').get(0);
      $(this.shadeEl).click(this.hide);

      $(window).bind('resize', this.renderShade);
      $(window).bind('resize', this.center);
      $(window).bind('scroll', this.center);
      $(window).bind('scroll', this.centerShade);

      this.firstShow = true;
    },

    blockBody: function() {
      $('body').css({overflow: 'hidden'});
    },

    center: function() {
      var $el  = $(this.el);
      var $w   = $(window);
      var top  = ($w.height() - $el.outerHeight()) / 2 + $w.scrollTop() + "px";
      var left = ($w.width() - $el.outerWidth()) / 2 + $w.scrollLeft() + "px";

      $el.css("position","absolute");
      $el.css("top", top);
      $el.css("left", left);
    },

    centerShade: function() {
      var $el = $(this.shadeEl);
      var $w   = $(window);

      $el.css("position","absolute");
      $el.css("top", $w.scrollTop());
      $el.css("left", $w.scrollLeft());
    },

    hide: function() {
      this.unblockBody();

      $(this.el).hide();
      $(this.shadeEl).hide();

      this.resetSlideShow();
      this.pauseSlideShow();
    },

    render: function() {
      this.renderEl();

      return this;
    },

    renderEl: function() {
      $(this.el).html($.tmpl(this.template));
    },

    renderShade: function() {
      $(this.shadeEl).
        width($(window).width()).
        height($(window).height()).get(0);
    },

    resetSlideShow: function() {
      this.$('.tutorial-content').cycle(0);
    },

    resumeSlideShow: function() {
      this.$('.tutorial-content').cycle('resume');
    },

    setupSlideShow: function() {
      this.$('.tutorial-content').cycle({
        after: this.updateNavigation,
        activePagerClass: 'active',
        delay: -6000,
        fit: true,
        fx: 'scrollHorz',
        next: this.$('.tutorial-pager-next'),
        onPagerEvent: this.pauseSlideShow,
        onPrevNextEvent: this.pauseSlideShow,
        pager: this.$('.tutorial-pager-absolute'),
        prev: this.$('.tutorial-pager-prev'),
        speed: 200,
        timeout: 10000,
        width: $(this.el).width(),
      });
    },

    setupRelativePager: function() {
      var children = this.$('.tutorial-content').children();
      var total    = children.length;

      children.each(function(i, e) {
        var p = new Tutorial.RelativePager({
          totalPages: total,
          currentIdx: i
        })

        $(e).append(p.render().el);
      })
    },

    show: function() {
      this.blockBody();
      this.renderShade();

      $(this.shadeEl).show();

      if (this.firstShow) this.renderEl();

      $(this.el).show();

      if (this.firstShow) {
        this.center();
        this.setupRelativePager();
        this.setupSlideShow();

        this.firstShow = false;
      }  else {
        this.resumeSlideShow();
      }
    },

    pauseSlideShow: function() {
      this.$('.tutorial-content').cycle('pause');
    },

    unblockBody: function() {
      $('body').css({overflow: 'auto'});
    },

    updateNavigation: function(elem) {
      var idx = this.$('.tutorial-pager-absolute .active').
        index('.tutorial-pager-absolute a');

      if (idx == 4) {
        var tpn = this.$('.tutorial-pager-next');

        this.$('.total-pages').css({marginRight: tpn.hide().width()});
      } else if ([-1, 0].indexOf(idx) > -1) {
        var tpp = this.$('.tutorial-pager-prev');

        this.$('.current-page').css({marginLeft: tpp.hide().width()});
      } else {
        this.$('.tutorial-pager-next').show();
        this.$('.tutorial-pager-prev').show();
        this.$('.total-pages').css({marginRight: 0});
        this.$('.current-page').css({marginLeft: 0});
      }
    },
  });

  window.Tutorial.RelativePager = Backbone.View.extend({
    className: 'tutorial-pager-relative',
    template: $('#tmpl-tutorial-relative-pager').template(),

    render: function() {
      $(this.el).html($.tmpl(this.template));

      this.$('.total-pages').text(this.options.totalPages);
      this.$('.current-page').text(this.options.currentIdx + 1);

      return this;
    },
  });
});
