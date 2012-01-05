window.UserSettings = Backbone.View.extend({
  events: {
    'ajax:error form': 'onErrors',
    'ajax:success form': 'onSuccess'
  },
  el: '[data-widget = "settings"]',

  onErrors: function(_, data){
    var l = $('<dl/>');

    $.each($.parseJSON(data.responseText), function(k, v) {
      // @ToDo: I had to add '' because $('<dd/>').text(v) is
      //       returning empty string, jquery bug?
      l.append($('<dt/>').text(k))
       .append($('<dd/>').text(''+v));

    });

    this.$('[data-widget = "errors"]').html(l).show();
  },

  onSuccess: function(){
    $.fancybox.close();
  }
});
