jQuery(function($){
  if (typeof($.datepicker) === 'object') {
    $.datepicker.regional['en'] = {"dayNamesShort":["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],"dateFormat":"yy-mm-dd","showMonthAfterYear":false,"nextText":"Next","dayNamesMin":["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],"currentText":"Today","changeYear":true,"monthNames":["January","February","March","April","May","June","July","August","September","October","November","December"],"weekHeader":"Wk","changeMonth":true,"monthNamesShort":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"firstDay":0,"closeText":"Close","dayNames":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],"isRTL":false,"prevText":"Previous"};
    $.datepicker.setDefaults($.datepicker.regional['en']);
  }
  if (typeof($.timepicker) === 'object') {
    $.timepicker.regional['en'] = {"secondText":"Seconds","dateFormat":"D, dd M yy ","ampm":false,"timeFormat":"hh:mm:ss","hourText":"Hour","minuteText":"Minute"};
    $.timepicker.setDefaults($.timepicker.regional['en']);
  }
});
$(document).ready(function() {
  $('input.date_picker').live('focus', function(event) {
    var date_picker = $(this);
    if (typeof(date_picker.datepicker) == 'function') {
      if (!date_picker.hasClass('hasDatepicker')) {
        date_picker.datepicker();
        date_picker.trigger('focus');
      }
    }
    return true;
  });
  $('input.datetime_picker').live('focus', function(event) {
    var date_picker = $(this);
    if (typeof(date_picker.datetimepicker) == 'function') {
      if (!date_picker.hasClass('hasDatepicker')) {
        date_picker.datetimepicker();
        date_picker.trigger('focus');
      }
    }
    return true;
  });
});