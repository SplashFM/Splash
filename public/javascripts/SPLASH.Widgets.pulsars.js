var SPLASH = SPLASH || {};
SPLASH.Widgets = SPLASH.Widgets || {};

SPLASH.Widgets.pulsars = function(selector) {
  var selectors = 4;
  var rate      = 2000;
  var opacV     = 0.6;
  (function init() {
    jQuery.fx.interval = 100;
    if($('.sessions')) {
      runIt(genNum());
    }
  }())
  
  function genNum() {
    return Math.floor(Math.random()*selectors+1);
  }
  function runIt(firstRun) {
    if(firstRun) {
      selector = $(".p"+firstRun);
      selector.animate({'opacity':opacV},rate,runIt);
      selector.addClass('animating');
    }
    else {      
      var curAni = $('.animating');
      (function roll() {
        var theClass = $('.p'+genNum());
          $('.animating').removeClass('animating').animate({'opacity':'0'},rate);
          $(theClass).addClass('animating').animate({'opacity':opacV},rate,roll);

      }());
    }
  }
}