var SPLASH = SPLASH || {};
SPLASH.Widgets = SPLASH.Widgets || {};

SPLASH.Widgets.waterNums = function(theSelector) {
  var selector      = $(theSelector);
  var sigFig        = 2;
  var numOffset     = {y:80,x:-54};
  var maxWaterWidth = -286;
  
  (function init() {
    construct();
  }())
  
  function construct () {
    selector.each(function() {
      var current     = $(this);
      var theString   = cleanText(current.text());
      var newContents = "";
      var firstNum    = false;
      
      for(var i = 0; i < sigFig; ++i) {
        var numOffsetV  = selector.parents('.users').length ? 1 : 0;
        var sSub        = theString.charAt(i);
        firstNum        = firstNum || sSub != "0" ? true : false;
        var bgP         = "background-position:"+ numOffset.x * sSub +"px "+ -numOffset.y * numOffsetV +"px;";
        var innerNum    = "<span class='inner_num'></span>";
        var style       = "style='"+ bgP +"'";
        newContents     += "<div class='numHolder nonBlank_"+ firstNum +" num_"+ sSub +" digit_"+ i +"'"+ style +">"+ innerNum +"</div>"
      }
      
      newContents+="<div class='clear'></div><div class='the_water'></div><div class='water_bg_color'></div><div class='noise-overlay'></div>";
      current.data({number:theString});
      current.html(newContents);
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
      var newPos  = parseInt(theWater.css('background-position-x'),10) + speed * direction;
      if(newPos < maxWaterWidth || newPos > 0) {
        direction *= -1;
        newPos = parseInt(theWater.css('background-position-x'),10) + speed * direction;
      }
      theWater.css({'background-position-x':newPos});
      setTimeout(step,50);
    }
    step();
  }
  
  return {};
}