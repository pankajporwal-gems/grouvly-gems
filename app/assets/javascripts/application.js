//= require jquery
//= require jquery_ujs
//= require ../../../vendor/assets/javascripts/jquery/animatescroll.min
//= require ../../../vendor/assets/javascripts/jquery/jquery.infinitescroll
//= require ../../../vendor/assets/javascripts/jquery/jquery.colorbox-min
//= require ../../../vendor/assets/javascripts/jquery/jquery.cookie
//= require ../../../vendor/assets/javascripts/jquery/detect-card
//= require ../../../vendor/assets/javascripts/underscorejs/underscore-min
//= require ../../../vendor/assets/javascripts/modulejs/modulejs-1.5.0.min
//= require ../../../vendor/assets/javascripts/backbone/backbone-min
//= require ../../../vendor/assets/javascripts/backbone/extended-backbone
//= require ../../../vendor/assets/javascripts/backbone/backbone.subroute.min
//= require ../../../vendor/assets/javascripts/momentjs/moment
//= require ../../../vendor/assets/javascripts/bootstrap/bootstrap.min
//= require ../../../vendor/assets/javascripts/bootstrap/bootstrap-datetimepicker.min
//= require ../../../vendor/assets/javascripts/sweet_alert/sweet-alert.min
//= require ../../../vendor/assets/javascripts/tock/tock.min
//= require ../../../vendor/assets/javascripts/reactjs/react-with-addons-0.13.1
//= require ../../../vendor/assets/javascripts/reactjs/flux
//= require ../../../vendor/assets/javascripts/reactjs/event_emitter.min
//= require ../../../vendor/assets/javascripts/reactjs/immutable.min
//= require ../../../vendor/assets/javascripts/reactjs/shallowEqualImmutable
//= require ../../../vendor/assets/javascripts/reactjs/ImmutableRenderMixin
//= require ../../../vendor/assets/javascripts/braintree/braintree
//= require ../../../vendor/assets/javascripts/owl_carousel/owl.carousel.min
//= require ../../../vendor/assets/javascripts/selectize/selectize.min
//= require i18n
//= require i18n/translations
//= require_tree .

modulejs.define('jquery', function () { return jQuery; });
modulejs.define('backbone', function () { return Backbone; });
modulejs.define('underscore', function () { return _; });
modulejs.define('tock', function () { return Tock; });
modulejs.define('i18n', function () { return I18n; });
modulejs.define('react', function () { return React; });
modulejs.define('flux', function () { return Flux; });
modulejs.define('immutable', function () { return Immutable; });
modulejs.define('eventEmitter', function () { return EventEmitter; });
modulejs.define('braintree', function() { return braintree; });

$(function() {
  var router = modulejs.require('router');
  router.initialize();

  var tracking = modulejs.require('tracking');
  tracking.initialize();

  $('.block-message-details').on('click', function(e) {
    $(this).css('background-color', '#dcf7f7');
  });

  $(window).scroll(function() {
    var currentPosition = $('.nav-offset').offset();

    if (currentPosition) {
      var scrollPosition = $(window).scrollTop();
      currentPosition = currentPosition.top - 40;

      if (currentPosition <= scrollPosition) {
        $('#main-nav').addClass('active');
      } else {
        $('#main-nav').removeClass('active');
      }
    }
  });

  // Responsive Menu
  var pull = $('.res-btn');
  var menu = $('#main-nav .horizontal-menu');
  var menuHeight = menu.height();
  var mainNav = $('#main-nav');

  $(pull).on('click', function(e) {
    e.preventDefault();

    var menuIcon = pull.find('.horiz-line');

    if (menuIcon.hasClass('active')) {
      menuIcon.removeClass('active');
      mainNav.removeClass('menu-active');
    } else {
      menuIcon.addClass('active');
      mainNav.addClass('menu-active');
    }

    menu.fadeToggle();
  });

  $(window).resize(function(){
    var w = $(window).width();

    if (w > 992 && menu.is(':hidden')) menu.removeAttr('style');
  });
});
