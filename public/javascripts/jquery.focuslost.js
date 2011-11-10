(function($) {
    // will store the last focus chain
    var currentFocusChain = $();
    // stores a reference to any DOM objects we want to watch focus for
    var focusWatch = [];

    function checkFocus() {
        var newFocusChain = $(":focus").parents().andSelf();
        // elements in the old focus chain that aren't in the new focus chain...
        var lostFocus = currentFocusChain.not(newFocusChain.get());
        lostFocus.each(function() {
            if ($.inArray(this, focusWatch) != -1) {
                $(this).trigger('focuslost');
            }
        });
        currentFocusChain = newFocusChain;
    }
    // bind to the focus/blur event on all elements:
    $("*").live('focus blur', function(e) {
        // wait until the next free loop to process focus change
        // when 'blur' is fired, focus will be unset
        setTimeout(checkFocus, 100);
    });

    $.fn.focuslost = function(fn) {
        return this.each(function() {
            // tell the live handler we are watching this event
            if ($.inArray(this, focusWatch) == -1) focusWatch.push(this);
            $(this).bind('focuslost', fn);
        });
    };
})(jQuery);
