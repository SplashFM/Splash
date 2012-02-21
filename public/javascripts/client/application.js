var app    = {};
var splash = {};

function fixBG(elements) {
  setTimeout(function() {
    elements.each(function() {
      $(this).css('background-image', $(this).css('background-image'));
    });
  }, 600);
};
