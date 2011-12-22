var SPLASH = SPLASH || {};
SPLASH.Widgets = SPLASH.Widgets || {};

SPLASH.Widgets.JPlayerSeekable = (function() {
  var down = false,
      cached,
      target;

  $('#player').live($.jPlayer.event.ready,reBind);

  function reBind() {
    $('.jp-seek-bar').die('mousedown',downdown);
    $('.jp-seek-bar').die('mouseup',up);
    $('.jp-seek-bar').die('mousemove',movement);
    $('.jp-audio').die('mouseleave',up);
    $('.jp-seek-bar').live('mousedown',downdown);
    $('.jp-seek-bar').live('mouseup',up);
    $('.jp-seek-bar').live('mousemove',movement);
    $('.jp-audio').live('mouseleave',up);
    cached = $('#player');
    target = $('.jp-seek-bar');
  }

  function movement(e) {
    cached = cached || $('#player');
    target = target || $('.jp-seek-bar');
    if(down==true) {
      var p = (e.layerX / target.width())* 100;
      cached.jPlayer( "playHead", p );
    }
  }

  function downdown(e) {
    down = true;
    movement(e);
  }

  function up(e) {
    down = false;
  }

  return {'reBind':reBind};
}())