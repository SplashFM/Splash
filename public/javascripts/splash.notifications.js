var Splash = Splash || {};

Splash.notifications = (function(){
  
  var selector = '.nav-notifications';
  
  function init() {
    setListeners();
  }
  
  function setListeners() {
    $('a.count',selector).bind('click',onRootClick);
  }
  
  function onRootClick(e) {
    $(selector).toggleClass('active');
  }
  
  $().ready(function(){init();});
}());