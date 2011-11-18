// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var Scaphandrier = Scaphandrier || {};

Scaphandrier.PreventHeaderLinksDefault = {
  init : function() {
    $('a[href="#"]','#header').click(function(e){
      e.preventDefault();
    });
  }
}
Scaphandrier.Fancybox = {
  params: {
    customizations: {
      'type' : 'ajax',
      'width' : 460,
      'height': 480,
      'autoScale' : false,
      'autoDimensions' : false,
      'titleShow' : false,
      'overlayShow' : true,
      'overlayColor' : '#000',
      'overlayOpacity' : 0.5,
      'transitionIn' : 'none',
      'transitionOut' : 'none',
      'padding' : 0,
      'margin' : 0,
      'scrolling' : 'no',
      'onComplete' : function() {
        Widgets.AvatarUpload.init();
        Widgets.Avatar.init();
      }
    }
  },

  init: function() {
    $(".fancybox").fancybox(this.params.customizations);
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

var Splash = Splash || {};

Splash.Widget = {
  init: function() {
    $("tr[data-source=\"soundcloud\"] td[data-track_url]").each(function(i, e) {
      SC.oEmbed($(e).attr("data-track_url"), {}, e);
    });
    
    $("tr[data-source=\"itunessearch\"] td[data-track_url]").each(function(i, e) {
      jwplayer($(e).attr("id")).setup({
        flashplayer: "/player.swf",
        file: $(e).attr("data-track_url"),
        'controlbar': 'bottom',
        'width': '470',
        'height': '24'
      });
    })
  }
}

Splash.ShareButton = function() {
  $('.share-btn').live( 'click' , toggleShare );

  function toggleShare(e) {
    $(e.target).parents('.container').find('.share_pane').toggle();
    e.preventDefault();
  }

}

// onLoad
jQuery(document).ready(function() {
  Scaphandrier.Fancybox.init();
  Scaphandrier.InlineLabels.init();
  Scaphandrier.Console.init();
  Scaphandrier.Flash.init();
  Scaphandrier.PreventHeaderLinksDefault.init();
  Splash.Widget.init();
  SPLASH.Widgets.sticky("#header .shell");
  Splash.ShareButton();
  SPLASH.Widgets.pulsars();
});
