var SPLASH = SPLASH || {};
SPLASH.Widgets = SPLASH.Widgets || {};

SPLASH.Widgets.adaptiveHome = (function(selector) {
  $(document).ready(init);
  var _doc,
      _win,
      _body;
  function init() {
    _doc  = $(document);
    _body = $('body');
    _win  = $(window);
    setSize();
    setListeners();
  }

  function setSize() {
    var theSize = parseInt(_win.width(),10);
    theSize >= 930 && _body.attr('class','large');
    theSize < 930 && theSize > 700 && _body.attr('class','medium');
    theSize <= 700 && _body.attr('class','small');
  }

  function setListeners() {
    _win.resize(setSize);
  }

})()