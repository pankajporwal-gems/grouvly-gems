modulejs.define('sharedRouter', ['jquery','tracking'], function($, tracking) {
  var eventBar = (function () {
    $('.block-event-bar').on('click', '.close-button', function (e) {
      // Hide event bar
      $('body').removeClass('has-event-bar');
      $(e.delegateTarget).slideUp(200);
      // set cookie
      $.cookie('_grouvly_event_bar', '1', { path: '/' });
    });
  })();

  var bindFacebookSignup = (function () {
      var eventName = 'Pressed Sign up Button';

      $('.navbar').on('click', 'a[href^="https://www.facebook.com"].btn-primary', function(){
        tracking.trackEvent(eventName, { 'Button': 'Header', 'Page Name': gon.pageName });
      });
  })();

});
