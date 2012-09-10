window.User.AllResults = Backbone.View.extend({
  className: 'all-results',
  
  events: {
    'click [data-widget = "close"]': 'close',
    'search:loaded': 'resize',
  },

  initialize: function(){
    this.table = new User.AllResults.Results;
    
    this.animation = new Animation('slide', {direction: 'left'}, 500);
    
    _.bindAll(this, "close");
    this.options.eventAgg.bind("userSearch:close", this.close);
 },
  
  close: function() {
    $(this.el).trigger('userSearch:collapse');

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
    this.$('h2').text(I18n.t('all_results.header_users', {terms: searchTerms}));
  },
});

window.User.AllResults.Results = Backbone.View.extend({

  initialize: function() {
    this.collection = new UserList;
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
    this.$('ul#results').empty();
  },

  load: function(searchTerms) {
    this.collection.fetch({data: {with_text: searchTerms}});
  },

  render: function() {
    $(this.el).html($.tmpl(this.template));

    var $tbody = this.$('ul#results');

    this.collection.each(function(m) {
      var v = new User.AllResults.Result({model: m});

      $tbody.append(v.render().el);
    }, this);

    return this;
  },

  reset: function() {
    this.clear();

    this.render();

    $(this.el).trigger('userSearch:loaded');
  },
});



window.User.AllResults.Result = Backbone.View.extend({
  tagName: 'li',
  menuContainer: this.$('ul#results'),
  
  render: function() {
    $(this.el).html($.tmpl(this.template, this.model.toJSON()));

    score = this.model.get('score');
    outer = $('<div/>').addClass('outer').text(score)
    span  = $('<span/>').addClass('number avan-bold invite left');
    this.$('.splash-score').replaceWith(span.html(outer)); 
    
    new RelationshipView({
      el: this.$('.right .follow-links'),
      model:    new Relationship(this.model.get('relationship')),
      template: $('#tmpl-relationship-list').template()
    }).render()
    
   
    return this;
  },

});


$(function() {
  
  User.AllResults.prototype.template =
    $('#tmpl-track-search-all-results').template();
  User.AllResults.Results.prototype.template =
    $('#tmpl-track-search-all-results-table').template();
  User.AllResults.Result.prototype.template =
    $('#tmpl-user').template();

});
