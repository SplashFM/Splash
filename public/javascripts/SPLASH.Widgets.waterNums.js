var SPLASH = SPLASH || {};
SPLASH.Widgets = SPLASH.Widgets || {};

SPLASH.Widgets.waterNums = function(theSelector, yOffset) {
  var selector      = $(theSelector);
  var sigFig        = 2;
  var numOffset     = {y:80, x:-54};
  var maxWaterWidth = 286;
  var vOffset       = yOffset || 0;

  construct();

  function construct () {
    selector.each(function() {
      var current     = $(this);
      var theString   = cleanText(current.text());
      var newContents = "";
      var firstNum    = false;
      var randX =  Math.floor(Math.random()*maxWaterWidth*-1)+20;
      var innerNum    = "<span class='inner_num'></span>";
      var numOffsetV;

      function shiftHover(offset) {
        current.find('.numHolder').each(function () {
          var newPos = getBackgroundPositionX($(this)) + "px " + offset + "px";
          $(this).css({'background-position': newPos });
        })
      }
      function shiftHoverIn() {
        shiftHover(-240);
      }
      function shiftHoverOut() {
        shiftHover(-160);
      }

      if (selector.hasClass('splash-score')) {
        numOffsetV = 2;
      } else if (selector.parents('.users.show').length) {
        numOffsetV = 1;
      } else {
        numOffsetV = 0;
      }

      for (var i = 0; i < sigFig; ++i) {
        var sSub        = theString.charAt(i);
        firstNum        = firstNum || sSub != "0" ? true : false;
        var bgP         = "background-position:"+ numOffset.x * sSub +"px "+ -numOffset.y * numOffsetV +"px;";
        var style       = "style='"+ bgP +"'";
        newContents     += "<div class='numHolder nonBlank_"+ firstNum +" num_"+ sSub +" digit_"+ i +"'"+ style +">"+ innerNum +"</div>";

        if (numOffsetV == 2) {
          current.parents('li').hover(shiftHoverIn, shiftHoverOut);
        }
      }

      newContents += "<div class='clear'></div><div class='the_water'></div><div class='water_bg_color'></div><div class='noise-overlay'></div>";
      current.data({number: theString});
      current.html(newContents);
      var water = $('.the_water', current);
      water.css({'background-position': randX + "px " +  getBackgroundPositionY(water)+ "px"});

      fixBG(water);
      fixBG($('.noise-overlay', current));
      fixBG($('.numHolder', current));

      rollWater(current);
    });
  }

  // UTIL FUNCTIONS
  function cleanText (text) {
    var localString = text.toString().replace(/\s/g,'');

    for (var i = sigFig - localString.length; i > 0; --i) {
      localString = "0" + localString.toString();
    }
    return localString;
  }

  function rollWater(current) {
    var theWater  = $('.the_water', current);
    var speed     = 2;
    var direction = -1;

    function step() {
      var x = getBackgroundPositionX(theWater);
      var newPos = x + speed * direction;

      if (-1*maxWaterWidth > newPos || newPos > 0) {
        direction *= -1;
        newPos = x + speed * direction;
      }

      var y = getBackgroundPositionY(theWater);
      var newBgPosition = newPos + "px " + y + "px";
      theWater.css('background-position', newBgPosition);
      setTimeout(step, 50);
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
