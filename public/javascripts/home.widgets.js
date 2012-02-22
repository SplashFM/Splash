$(function() {
  window.WithAllResults = {
    events: {
      'search:expand #stream-feed': 'searchExpanded',
      'search:collapse #stream-feed': 'searchCollapsed',
      'search:loaded #stream-feed': 'checkSize'
    },

    checkSize: function() {
      var off = $(this.allResults.el).offset();
      var arh = off.top + $(this.allResults.el).height();

      if ($(this.el).height() < arh) {
        $(this.el).height($(this.el).height() + arh - $(this.el).height());
      }
    },

    searchCollapsed: function() {
      this.eventFeed.enable();
      this.trackSearch.enable();
    },

    searchExpanded: function(_, data) {
      this.eventFeed.disable();
      this.trackSearch.disable();

      this.showAllResults(data.terms);
    },

    showAllResults: function(searchTerms) {
      this.$('.events-wrap').prepend(this.allResults.el);

      this.allResults.load(searchTerms);
    },
  };

  window.HomeController = Backbone.View.extend({
    initialize: function() {
      this.eventFeed   = new Events({
        currentUserID: this.options.userID,
        filters:       _.extend(
          {
            user:     this.options.userID,
            follower: this.options.userID
          },
          this.options.queryString
        ),
        updateFilters: {
          follower: this.options.userID,
          splashes: 1,
        },
      });

      this.scroll = new EndlessScroll({
        data: this.eventFeed,
        noMoreResults: $('<p/>').
          text(I18n.t('events.all_loaded')).
          addClass('loaded'),
        spinnerContainer: this.$('.loading-spinner-container'),
      });

      this.suggestedSplashers = new SuggestedSplashersView({
        el: this.$('[data-widget = "suggested-users"]').get(0),
        followerID: this.options.userID,
        splashersCount: this.options.suggestedUsersPerPage,
      });
    },

    render: function() {
      this.suggestedSplashers.render();

      return this;
    }
  });

  TrackSearch = Search.extend({
    UPLOAD_BEGIN_POS: -625,
    UPLOAD_END_POS: -25,

    animation: new Animation('slide', {direction: 'up'}, 200),
    collection: new TrackList,
    el: '[data-widget = "track-search"]',
    events: _.extend({
      'click [data-widget = "toggle-upload"]': 'showUpload',
      'click [data-widget = "view-all-results"]': 'viewAllResults',
      'hiding': 'removeUploadProgressForm',
      'showing': 'prepareUploadProgressForm',
      'upload:done': 'onUploadDone',
      'upload:error': 'onUploadError',
      'upload:metadata': 'onMetadataSave',
      'upload:progress': 'onUploadProgress',
      'upload:splash': 'onUploadSplash',
      'upload:start': 'onUploadStart',
      'search:expand': 'hide',
    }, Search.prototype.events),
    extraParams: {popular: true},
    keepResults: true,
    maxBrowseablePages: 2,
    menuContainer: 'ul',

    initialize: function() {
      Search.prototype.initialize.call(this);

      this.input     = this.$('input.field');
      this.uploadBar = this.input;

      this.uploadStep =
        Math.abs(parseInt((this.UPLOAD_END_POS + this.UPLOAD_BEGIN_POS) / 100));

      this.upload = new Upload().render();
      this.$('.wrap').append(this.upload.hide().el);
    },

    disable: function() {
      $(this.el).block({
        message: null,
        overlayCSS: {opacity: 0}
      });

      this.$('input.field').attr('disabled', true);
      this.$('[data-widget = "toggle-upload"]').addClass('disabled');
    },

    enable: function() {
      this.$('input.field').attr('disabled', false);
      this.$('[data-widget = "toggle-upload"]').removeClass('disabled');

      $(this.el).unblock();
    },

    onUploadError: function() {
      this.uploadBar.addClass('error');
      this.uploadBar.val(I18n.t('upload.error'));
    },

    onMetadataSave: function() {
      this.uploadBar.val(I18n.t('upload.metadata'));
    },

    onUploadDone: function(e) {
      this.uploadBar.val(I18n.t('upload.done'));
    },

    onUploadProgress: function(_, data) {
      this.setUploadProgress(data.percent);
    },

    onUploadSplash: function() {
      this.uploadBar.val(I18n.t('upload.exists'));
    },

    onUploadStart: function() {
      this.uploadBar.removeClass('error');
      this.uploadBar.val(I18n.t('upload.start'));

      this.setUploadProgress(0);
    },

    open: function() {
      this.menu.find('li:last').addClass('last');
    },

    renderItem: function(i) {
      var opts = {model: i};

      $(new TrackSearch.Track(opts).render().el).appendTo(this.menu);
    },

    prepareUploadProgressForm: function() {
      this.uploadBar.removeClass('error');
      this.uploadBar.addClass('uploading')
      this.uploadBar.attr('disabled','true');
      this.uploadBar.attr('value', I18n.t('upload.waiting'));

      this.setUploadProgress(0);
    },

    removeUploadProgressForm: function() {
      this.uploadBar.removeClass('uploading')
      this.uploadBar.removeAttr('disabled','disabled');
      this.uploadBar.attr('value','');
    },

    setUploadProgress: function(percent) {
      var pos = this.UPLOAD_BEGIN_POS + percent * this.uploadStep;

      this.uploadBar.css('background-position', pos + 'px 0');
    },

    showUpload: function(e) {
      e.stopPropagation();

      this.upload.show();
    },

    viewAllResults: function() {
      $(this.el).trigger('search:expand', {terms: this.term()});
    },
  });

  TrackSearch.Track = Backbone.View.extend({
    events: {
      'click [data-widget = "play"]': 'play'
    },
    tagName: 'li',
    template: $('#tmpl-home-track').template(),

    play: function(e) {
      e.preventDefault();

      $(this.el).trigger('request:play',
                         {track: this.model.toJSON()});
    },

    render: function() {
      $(this.el).attr('data-track_id', this.model.get('id'));
      $(this.el).html($.tmpl(this.template, this.model.toJSON()));

      new FullSplashAction({
        model: this.model,
        el: this.$('[data-widget = "full-splash-action"]').get(0),
      });

      return this;
    },
  });

  window.TrackSearch.AllResults = Backbone.View.extend({
    className: 'all-results',
    events: {
      'click [data-widget = "close"]': 'close',
      'splash:splash': 'close',
      'search:loaded': 'resize',
    },
    template: $('#tmpl-track-search-all-results').template(),

    initialize: function() {
      this.table = new TrackSearch.AllResults.Results;

      $(this.el).hide();

      this.animation = new Animation('slide', {direction: 'left'}, 500);
    },

    close: function() {
      $(this.el).trigger('search:collapse');

      this.animation.hide(this.el, function() {
        $(this.el).detach();

        this.table.clear();
      }, this);
    },

    load: function(searchTerms) {
      this.setHeader(searchTerms)

      $(this.el).css('height', '100%');

      this.animation.show(this.el, _.bind(function() {
        this.table.load(searchTerms);
      }, this));

      return this;
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));
      $(this.el).append(this.table.el);

      return this;
    },

    resize: function() {
      if (this.$('table').height() > $(this.el).height()) {
        $(this.el).css('height', 'auto');
      }
    },

    setHeader: function(searchTerms) {
      this.$('h2').text(I18n.t('all_results.header', {terms: searchTerms}));
    },
  });

  window.TrackSearch.AllResults.Results = Backbone.View.extend({
    tagName: 'table',
    template: $('#tmpl-track-search-all-results-table').template(),

    initialize: function() {
      this.collection = new TrackList;
      this.collection.bind('reset', this.addRanks, this);
      this.collection.bind('reset', this.reset, this);
    },

    addRanks: function(collection) {
      var idxs = _.range(collection.length);

      _(collection.toArray()).
        chain().
        zip(idxs).
        each(function(mi) { mi[0].set({rank: mi[1] + 1}); });
    },

    clear: function() {
      this.$('tbody').empty();
    },

    load: function(searchTerms) {
      this.collection.fetch({data: {with_text: searchTerms}});
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

      var $tbody = this.$('tbody');

      this.collection.each(function(m) {
        var v = new TrackSearch.AllResults.Result({model: m});

        $tbody.append(v.render().el);
      }, this);

      return this;
    },

    reset: function() {
      this.clear();

      this.render();

      $(this.el).trigger('search:loaded');
    },
  });

  window.TrackSearch.AllResults.Result = Backbone.View.extend({
    events: {
      'click': 'clicked',
    },
    tagName: 'tr',
    template: $('#tmpl-track-search-all-results-table-row').template(),
    templateSplash: $('#tmpl-all-results-splash').template(),

    clicked: function(e) {
      if (! $(e.target).is('[data-widget = "toggle-splash"]')) this.play();
    },

    play: function() {
      $(this.el).trigger('request:play',
                         {track: this.model.toJSON()});
    },

    render: function() {
      $(this.el).html($.tmpl(this.template, this.model.toJSON()));

      this.splash = new FullSplashAction({
        model: this.model,
        el: $.tmpl(this.templateSplash).get(0),
      });

      $(this.splash.el).live('splash:splash', _.bind(this.toggleSplash, this));

      this.toggle   = new Toggle({
        el:        this.$('[data-widget = "toggle-splash"]'),
        target:    this.splash.el,
        isEnabled: this.model.get('splashable'),
        doToggle:  _.bind(this.toggleSplash, this),
      });

      return this;
    },

    toggleSplash: function() {
      if ($(this.splash.el).is(':visible')) {
        $(this.el).removeClass('splashing');
        $(this.splash.el).detach();
      } else {
        $(this.el).addClass('splashing');
        $(this.el).after(this.splash.el);
      }
    },
  });



  Upload = Backbone.View.extend({
    className: 'uploadForm',
    events: {'upload:complete': 'hide'},
    tagName: 'div',
    template: $('#tmpl-upload').template(),

    initialize: function() {
      _.bindAll(this, 'hide', 'onError', 'onProgress', 'onStart', 'onUpload');
      $(this.el).clickout(this.hide);
    },

    hide: function(args) {
      $(this.el).hide();

      this.metadata.reset();

      $(this.el).trigger("hiding");

      return this;
    },

    onProgress: function(_, data) {
      $(this.el).trigger('upload:progress', {
        percent: parseInt(data.loaded / data.total * 100)
      });
    },

    onError: function() {
      $(this.el).trigger('upload:error');
    },

    onStart: function() {
      $(this.el).trigger('upload:start');
    },

    onUpload: function(_, data) {
      switch (data.jqXHR.status) {
      case 201:
        this.metadata.setModel(new UndiscoveredTrack(data.result), 'edit');

        $(this.el).trigger('upload:done');

        break;
      case 200:
        this.metadata.setModel(new UndiscoveredTrack(data.result), 'splash');

        $(this.el).trigger('upload:splash');

        break;
      }
    },

    render: function() {
      $(this.el).append($.tmpl(this.template));

      this.$('form').fileupload({
        progress: this.onProgress,
        start: this.onStart,
        done: this.onUpload,
        fail: this.onError
      });

      this.metadata = new Upload.Metadata({model: this.model});

      $(this.el).append(this.metadata.render().el);

      return this;
    },

    show: function() {
      $(this.el).show();

      $(this.el).trigger('showing');

      return this;
    },
  });

  Upload.Metadata = Backbone.View.extend({
    events: {'submit': 'onSubmit'},
    tagName: 'form',
    template: $('#tmpl-upload-metadata').template(),

    initialize: function() {
      _.bindAll(this, 'onComplete', 'onError', 'onSubmit');
    },

    onComplete: function() {
      this.$('[name = "title"]').val('');
      this.$('[name = "performers"]').val('');
      this.$('[name = "albums"]').val('');
      this.$('textarea').val('');

      $(this.el).trigger('upload:complete');

      this.$('[data-widget = "metadata"]').hide();
      this.$('[data-widget = "complete-upload"]').hide();
    },

    onError: function() {
      $(this.el).trigger('upload:error');
    },

    onSubmit: function(e) {
      e.preventDefault();

      if (this.mode == 'edit') {
        var attrs = {
          albums: this.$('[name = "albums"]').val(),
          comment: this.comment.comment(),
          title: this.$('[name = "title"]').val(),
          performers: this.$('[name = "performers"]').val(),
        }

        $(this.el).trigger('upload:metadata');

        this.model.save(attrs, {
          error: this.onError,
          success: this.onComplete
        });
      } else {
        new Splash().save({
          comment:  this.comment.comment(),
          track_id: this.model.get('id')
        }, {
          success: this.onComplete
        });
      }
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

      this.comment = new SplashComment({el: this.$('textarea')});

      this.$('[data-widget = "complete-upload"]').hide();

      return this;
    },

    reset: function() {
      $(this.el).empty();

      this.render();
    },

    setModel: function(model, mode) {
      var button = this.$('[data-widget = "complete-upload"] input');

      this.model = model;
      this.mode  = mode;

      if (mode == 'edit') {
        this.$('[name = "title"]').val(model.get('title'));
        this.$('[name = "performers"]').val(model.get('performers'));
        this.$('[name = "albums"]').val(model.get('albums'));

        button.val(I18n.t('upload.save'));

        this.$('[data-widget = "metadata"]').show();
      } else {
        button.val(I18n.t('upload.splash'));
      }

      this.$('[data-widget = "complete-upload"]').show();
    },
  });

  window.SuggestedSplashersView = Backbone.View.extend({
    events: {
      'click [data-widget = "next-suggested-users"]': 'viewMore',
      'ignore:splasher': 'triggerUpdate',
      'follow:splasher': 'triggerUpdate'
    },
    template: $('#tmpl-suggested-splashers').template(),

    initialize: function() {
      this.collection = new SuggestedSplashers;
      this.collection.bind('reset', this.render, this);
      this.collection.fetch();

      this.cursor      = 0;
      this.suggestions = [];
    },

    $ul: function() {
      return this._$ul = this.$('ul');
    },

    advanceCursor: function() {
      this.cursor = this.nextPosition(this.cursor);
    },

    appendSuggestion: function(s) {
      this.$ul().append(s.render().el);
    },

    currentSlice: function() {
      var start = this.cursor;
      var end   = this.nextPosition(start);
      var ms    = this.collection.models;

      if (start < end) {
        return ms.slice(start, end);
      } else {
        var before = ms.slice(start, this.collection.length);
        var after  = ms.slice(0, end);

        return before.concat(after);
      }
    },

    makeSuggestion: function(model) {
      var followerID = this.options.followerID;

      return new SuggestedSplasherView({followerID: followerID, model: model});
    },

    nextPosition: function(cursor) {
      return this.wrappedCursor(cursor + this.options.splashersCount);
    },

    render: function() {
      $(this.el).html($.tmpl(this.template));

      this.resetSuggestions();

      return this;
    },

    resetSuggestions: function() {
      _.invoke(this.suggestions, 'remove');

      this.suggestions = _.map(this.currentSlice(), this.makeSuggestion, this);

      _.each(this.suggestions, this.appendSuggestion, this);

      this.suggestionsChanged();
    },

    suggestionsChanged: function() {
      var su = this.$('[data-widget = "next-suggested-users"]');

      if (this.collection.length <= this.options.splashersCount) {
        su.hide();
      } else {
        su.show();
      }
    },

    triggerUpdate: function(e, data) {
      this.collection.remove(data.view.model);

      this.cursor = this.wrappedCursor(this.cursor);

      if (this.collection.length > this.options.splashersCount) {
        var replacement = this.makeSuggestion(_.last(this.currentSlice()));

        this.suggestions.push(replacement);
        this.suggestions.splice(this.suggestions.indexOf(data.view), 1);

        this.appendSuggestion(replacement);
      }

      this.suggestionsChanged();

      data.view.model.destroy();
      data.view.remove(true);
    },

    viewMore: function(e) {
      e.preventDefault();

      this.advanceCursor();

      this.resetSuggestions();
    },

    wrappedCursor: function(cursor) {
      if (cursor >= this.collection.length) {
        return cursor - this.collection.length;
      } else {
        return cursor;
      }
    },
  });

  window.SuggestedSplasherView = Backbone.View.extend({
    events: {
      'click [data-widget = "delete-suggested-user"]': 'triggerIgnore',
      'follow': 'triggerFollow',
    },
    tagName: 'li',
    template: $('#tmpl-suggested-splasher').template(),

    initialize: function() {
      _.bindAll(this, 'remove');
    },

    remove: function(animate) {
      var self = this;

      if (animate) {
        $(this.el).animate({height: 0}, {
          duration: 500,
          complete: this.remove
        });

        return this;
      } else {
        return Backbone.View.prototype.remove.call(this);
      }
    },

    render: function() {
      $(this.el).html($.tmpl(this.template, this.model.toJSON()));

      this.$('.wrap').append(this.renderRelationship());

      return this;
    },

    renderRelationship: function() {
      var r = new Relationship({
        follower_id: this.options.followerID,
        followed_id: this.model.id,
      });

      return new RelationshipView({
        model:    r,
        refresh:  false,
        tagName:  'span',
        template: $('#tmpl-suggested-relationship').template(),
      }).render().el;
    },

    triggerFollow: function(e) {
      e.preventDefault();

      $(this.el).trigger('follow:splasher', {view: this})
    },

    triggerIgnore: function(e) {
      e.preventDefault();

      $(this.el).trigger('ignore:splasher', {view: this})
    },
  });

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
