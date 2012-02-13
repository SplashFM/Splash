var SPLASH = SPLASH || {};
SPLASH.Widgets = SPLASH.Widgets || {};

SPLASH.Widgets.waterNums = function(theSelector,yOffset) {
  var selector      = $(theSelector);
  var sigFig        = 2;
  var numOffset     = {y:80,x:-54};
  var maxWaterWidth = -286;
  var vOffset       = yOffset || 0;

  (function init() {
    construct();
  }())

  function construct () {
    selector.each(function() {
      var current     = $(this);
      var theString   = cleanText(current.text());
      var newContents = "";
      var firstNum    = false;
      var randX =  Math.floor(Math.random()*maxWaterWidth)+20;

      for(var i = 0; i < sigFig; ++i) {
        var numOffsetV  = selector.parents('.users.show').length ? 1 : 0;
        numOffsetV      = selector.hasClass('splash-score') ? 2 : numOffsetV;
        var sSub        = theString.charAt(i);
        firstNum        = firstNum || sSub != "0" ? true : false;
        var bgP         = "background-position:"+ numOffset.x * sSub +"px "+ -numOffset.y * numOffsetV +"px;";
        var innerNum    = "<span class='inner_num'></span>";
        var style       = "style='"+ bgP +"'";
        newContents     += "<div class='numHolder nonBlank_"+ firstNum +" num_"+ sSub +" digit_"+ i +"'"+ style +">"+ innerNum +"</div>";

        if(numOffsetV==2) {
          current.parents('li').hover(function(){
            current.find('.numHolder').each(function(){
              var newPos = getBackgroundPositionX($(this)) + "px " + -240 + "px";
              $(this).css({'background-position': newPos });
            })
          }, function() {
            current.find('.numHolder').each(function(){
              var newPos = getBackgroundPositionX($(this)) + "px " + -160 + "px";
              $(this).css({'background-position': newPos });
            })
          }
        )};
      }

      newContents+="<div class='clear'></div><div class='the_water'></div><div class='water_bg_color'></div><div class='noise-overlay'></div>";
      current.data({number:theString});
      current.html(newContents);
      $('.the_water',current).css({'background-position': randX + "px " +  getBackgroundPositionY($('.the_water',current))+ "px"});

      rollWater(current);
    });
  }

  // UTIL FUNCTIONS
  function cleanText (text) {
    var localString = text.toString().replace(/\s/g,'');

    for(var i = sigFig - localString.length; i > 0; --i) {
      localString = "0" + localString.toString();
    }
    return localString;
  }

  function rollWater(current) {
    var theWater  = $('.the_water',current);
    var speed     = 2;
    var direction = -1;

    function step() {
      var newPos  = getBackgroundPositionX(theWater) + speed * direction;
      if(newPos < maxWaterWidth || newPos > 0) {
        direction *= -1;
        newPos = getBackgroundPositionX(theWater) + speed * direction;
      }

      var newBgPosition = newPos + "px " + getBackgroundPositionY(theWater) + "px";
      theWater.css({'background-position':newBgPosition});
      setTimeout(step,50);
    }
    step();
  }

  function getBackgroundPositionX(theElement) {
    return parseInt(theElement.css("background-position").split(" ")[0], 10);
  }

  function getBackgroundPositionY(theElement) {
    return parseInt(theElement.css("background-position").split(" ")[1], 10);
  }

  return {};
}
