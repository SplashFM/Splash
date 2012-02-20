//  TODO:: SET INTEGER
var SPLASH = SPLASH || {};
SPLASH.Widgets = SPLASH.Widgets || {};

SPLASH.Widgets.numFlipper = function (the_selector) {
  var selector      = $(the_selector),
  numOffset         = {'x':-45,'y':53},
  sigFig            = 3;

  (function init () {
    construct();
  }());

  function construct () {
    selector.each(function() {
      var current     = $(this);
      var theString   = cleanText(current.text());
      var newContents = "";
      var firstNum    = false;

      for(var i=0;i<sigFig;++i) {
        var sSub        = theString.charAt(i);
        firstNum        = firstNum||sSub!="0" ? true : false;
        var innerNum    = "<span class='inner_num'></span>";
        newContents     += "<div class='numHolderCount nonBlank_"+firstNum+" num_"+sSub+" digit_"+i+"' style='"+digitStyle(sSub,i)+"'>"+innerNum+"</div>"
      }
      current.css({'width':theString.length*-numOffset.x+"px"});
      newContents+="<div class='clear'></div>";
      current.data({number:theString});
      current.html(newContents);

      var numHolderCount = $('.numHolderCount', current);

      fixBG(numHolderCount);
    });
  }

  // UTIL FUNCTIONS
  function digitStyle(number,i) {
    var bgP         = "background-position:"+getBackgroundPosition(number)+"px "+-numOffset.y+"px;";
    var style       = "left:"+-i*numOffset.x+"px;"+bgP;
    return style;
  }

  function cleanText (text) {
    var localString = text.toString().replace(/\s/g,'');
    for(var i=sigFig-localString.length;i>0;--i) {
      localString = "0"+localString.toString();
    }
    return localString;
  }

  function calcNonBlanks(holder) {
    var firstNum = false;
    $('.numHolder',holder).each(function(){
      var _this = $(this);
      if(_this.hasClass('nonBlank_false') && !_this.hasClass('num_0')) {
        _this.removeClass('nonBlank_false').addClass('nonBlank_true');
      }
    });
  }

  function getBackgroundPosition (number) {
    return (parseInt(number,10)*parseInt(numOffset.x,10));
  }

  function setNumber (e) {
    var target            = $(e.currentTarget);
    var currentNum        = target.data('number');
    var currentNumString  = currentNum.toString();
    var newNum            = cleanText(++currentNum);
    animateNum(currentNumString,newNum,target)
    target.data({number:newNum});
  }

  function animateNum (currentNumS,newNum,target) {
    for(var i=0;i<newNum.length;++i) {
        if(currentNumS.charAt(i)!=newNum.charAt(i))
        {
          var speed         = 200;
          var currentTarget = $('.num_'+currentNumS.charAt(i)+'.digit_'+i+'',target);
          var theClone      = currentTarget.clone().removeClass('num_'+currentNumS.charAt(i)).addClass('num_'+newNum.charAt(i));
          var theParent     = currentTarget.parents('.numFlipper');

          theClone.removeAttr('style');
          theClone.attr({'style':digitStyle(newNum.charAt(i),i)});
          theClone.css({'top':-numOffset.y+"px"});

          calcNonBlanks(theParent);

          theParent.prepend(theClone).addClass('animating');

          currentTarget.animate({'top':''+numOffset.y+'px'},speed,function(){$(this).remove()});
          theClone.animate({'top':'0px'},speed);
          setTimeout(function(){theParent.removeClass('animating')},speed*2.5);
        }
      }
  }

  return {};
}
