modulejs.define('reservationsRouter', ['jquery', 'backbone','tracking'], function($, Backbone, tracking) {
  var reserveDate = function(e, value) {
    e.preventDefault();
    $('#reservation_schedule').val(value);
    $('#new_reservation').submit();
  };

  var reserveLastMinuteBooking = function(e, value) {
    e.preventDefault();
    $('#reservation_schedule').val(value);
    $('#reservation_last_minute_booking').val(true);
    $('#new_reservation').submit();
  }


  var eventTracking = (function(tracking) {

    var trackDatePicked = function() {
      var eventName = 'Picked a date';

      $('#btn-confirm').on('click', function(e){
        tracking.trackEvent(eventName, { 'When': 'This week', 'Acceptance Date': $(e.currentTarget).data('value') });
      });
      $('#btn-second-reservation').on('click', function(e){
        tracking.trackEvent(eventName, { 'When': 'Next week', 'Acceptance Date': $(e.currentTarget).data('value') });
      });
      $('#btn-third-reservation').on('click', function(e){
        tracking.trackEvent(eventName, { 'When': 'Week after', 'Acceptance Date': $(e.currentTarget).data('value') });
      });
      $('#custom_reservation_date').on('change', function(e){
        tracking.trackEvent(eventName, { 'When': 'Future', 'Acceptance Date': $(e.currentTarget).val() });
      });
      $('#last_minute_grouvly_booking').on('click', function(e){
        tracking.trackEvent(eventName, { 'When': 'This week', 'Acceptance Date': $(e.currentTarget).data('value') });
      });
    };

    var bindFutureDates = function() {
      var $element = $('#custom_reservation_date'),
          eventName = 'Pressed More Dates';
      $element.on('click', function(){
        tracking.trackEvent(eventName, {}, true);
      });
    };

    var init = function() {
      trackDatePicked();
      bindFutureDates();
    };

    return {
      initialize: init
    }
  })(tracking);

  var subroute = Backbone.SubRoute.extend({
    routes: {
      'email_reservation': 'goToDefault',
      'new': 'goToDefault',
      '': 'goToDefault'
    },

    goToDefault: function() {
      $('#btn-confirm, #btn-first-reservation, #btn-second-reservation, #btn-third-reservation').click(function(e) {
        reserveDate(e, $(this).data('value'));
      });

      $('#last_minute_grouvly_booking').click(function(e) {
        reserveLastMinuteBooking(e, $(this).data('value'));
      });

      $('#custom_reservation_date').change(function(e) {
        reserveDate(e, $(this).val());
      });

      eventTracking.initialize();
    }
  });

  return subroute;
});
