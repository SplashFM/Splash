var app    = {};
var splash = {};

function fixBG(elements) {
  elements.each(function() {
    $(this).css('background-image', $(this).css('background-image'));
  });
};
