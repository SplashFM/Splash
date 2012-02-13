Paginate = function(collection, elemsPerPage, fetchData) {
  var lastLength;

  var data = _({}).extend(fetchData, {page: 0});

  return _({
    collection: function() {
      return collection;
    },

    fetchNext: function() {
      data.page  = data.page + 1;
      lastLength = collection.length;

      collection.fetch({
        add:     true,
        data:    data,
        success: _.bind(function() { this.trigger('loaded'); }, this)
      });
    },

    hasNext: function() {
      return lastLength == null ||
             collection.length == (lastLength + elemsPerPage);
    },
  }).extend(Backbone.Events);
};
