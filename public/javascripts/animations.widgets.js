$(function() {
  window.Animation = function(effect, options, speed) {
    this.hide = function(el, callback, context) {
      animate(el, 'hide', maybe(callback, context));
    }

    this.show = function(el, callback, context) {
      animate(el, 'show', maybe(callback, context));
    }

    function animate(el, mode, callback) {
      $(el).effect(effect, _.extend(options, {mode: mode}, speed, callback))
    }

    function maybe(callback, context) {
      if (callback && context) {
        return _.bind(callback, context);
      } else if (callback) {
        return callback;
      }

      // undefined when no callback was passed
    }
  }
});
