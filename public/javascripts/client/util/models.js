Paginate = function(collection, elemsPerPage, fetchData) {
  var lastLength;

  var data = _({}).extend(fetchData, {page: 0});

  elemsPerPage = elemsPerPage || 10;

  collection.bind('reset', function() { data.page = 1 });

  return _({
    collection: function() {
      return collection;
    },

    fetchNext: function() {
      data.page  = data.page + 1;
      lastLength = collection.length;

      this.trigger('fetch');

      return collection.fetch({
        add:     true,
        data:    data,
        success: _.bind(function() { this.trigger('loaded'); }, this), // TODO: change this
        error:   _.bind(function() { this.trigger('paginate:error'); }, this)
      });
    },

    hasNext: function() {
      return lastLength == null ||
             collection.length == (lastLength + elemsPerPage);
    },

    refetch: function() {
      collection.reset()

      data.page = 0

      return this.fetchNext();
    }
  }).extend(Backbone.Events);
};
