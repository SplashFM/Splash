// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var Scaphandrier = Scaphandrier || {};

Scaphandrier.Fancybox = {
  init: function() {
    $('a.lb').fancybox();
    $('a.donation').fancybox({width: 600, height: 400, autoDimensions: false});
  }
};

// inline labels
// http://www.zurb.com/playground/inline-form-labels
Scaphandrier.InlineLabels = {
  init: function() {
    $(window).bind('load', function() { setTimeout(function() {
      $("label.inlined + input.input-text").each(function () {
        if($(this).val() !== '') {
          $(this).prev().addClass('has-text');
        }
      });
    }, 100);});

    $("label.inlined + input.input-text").focus(function() {
      $(this).prev('label.inlined').addClass('focus');
    }).keypress(function() {
      $(this).prev('label.inlined').addClass('has-text').removeClass('focus');
    }).blur(function() {
      if($(this).val() === '') {
        $(this).prev('label.inlined').removeClass('has-text').removeClass('focus');
      }
    }).change(function() {
      if($(this).val() === '') {
        $(this).prev('label.inlined').removeClass('has-text').removeClass('focus');
      } else {
      $(this).prev('label.inlined').addClass('has-text');
      }
    });
  }
};

// prevent console logging from throwing an error on incompatible browsers.
Scaphandrier.Console = {
  init: function() {
    if (typeof(window.console) == 'undefined') {
      window.console = { info: function(){}, log: function(){}};
    }
  }
};

// Handle flash messages
Scaphandrier.Flash = {
  init : function() {
    $("#flash_notice").fadeIn("slow");
    $("#flash_error").fadeIn("slow");
  }
};

Scaphandrier.Browser = {
  IE6 : ($.browser.msie && parseInt($.browser.version) == 6),
  IE7 : ($.browser.msie && parseInt($.browser.version) == 7),
  IE8 : ($.browser.msie && parseInt($.browser.version) == 8)
}

// onLoad
jQuery(document).ready(function() {
  Scaphandrier.Fancybox.init();
  Scaphandrier.InlineLabels.init();
  Scaphandrier.Console.init();
  Scaphandrier.Flash.init();
});
