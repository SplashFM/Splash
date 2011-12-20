var SPLASH = SPLASH || {};
SPLASH.Widgets = SPLASH.Widgets || {};

SPLASH.Widgets.JPlayerSeekable = (function() {
  var down = false,
      cached,
      target;

  $('.jp-seek-bar').live('mousedown',downdown);
  $('.jp-seek-bar').live('mouseup',up);
  $('.jp-seek-bar').live('mousemove',movement);
  $('.jp-audio').live('mouseleave',up);

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

  return {};
}())