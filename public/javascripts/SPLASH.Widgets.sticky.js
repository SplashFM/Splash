var SPLASH = SPLASH || {};
SPLASH.Widgets = SPLASH.Widgets || {};

SPLASH.Widgets.sticky = function(selector) {
  var _selector = $(selector);
  var _window   = $(window);
  
  (function init() {
    setListeners();
  }())
  
  function setListeners() {
    _window.bind('scroll',updateSticky);
  }
  
  function updateSticky() {
    _selector.css({ 'left' : -_window.scrollLeft() });
  }
}