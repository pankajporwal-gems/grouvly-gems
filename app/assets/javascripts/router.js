modulejs.define('router', ['jquery', 'backbone', 'tracking'], function($, Backbone, tracking) {
  var init = function() {
    var GrouvlyRouter = Backbone.Router.extend({
      routes: {
        'admin/applicants(/)(*subroute)': 'goToAdminApplicants',
        'admin/matches(/)(*subroute)': 'goToAdminMatches',
        'admin/members(/)(*subroute)': 'goToAdminMembers',
        'admin/pools(/)(*subroute)': 'goToAdminPools',
        'admin/venues(/)(*subroute)': 'goToAdminVenues',
        'admin/vouchers(/)(*subroute)': 'goToAdminVouchers',
        'admin/reservations(/)(*subroute)': 'goToAdminReservations',
        'user/membership(/)(*subroute)': 'goToMembership',
        'user/payment(/)(*subroute)': 'goToPayment',
        'user/reservations(/)(*subroute)': 'goToReservations',
        'r(/)(*subroute)': 'goToJoin',
        'faq': 'goToFaq',
        'why-facebook': 'goToWhyFacebook',
        '(/)': 'goToHome'
      },

      goToJoin: function () {
        $('#reservations-controller #questions .tab-heading').on('click', function() {
          var icon = $(this).find('.icon-square');

          if (icon.hasClass('icon-plus')) {
            icon.removeClass('icon-plus').addClass('icon-minus');
          } else {
            icon.removeClass('icon-minus').addClass('icon-plus');
          }

          var content = $(this).closest('.tab-container').find('.tab-content');
          content.slideToggle();
        });
      },

      initialize: function () {
        var Router = modulejs.require('sharedRouter');
      },

      goToAdminApplicants: function(subroute) {
        var Router = modulejs.require('adminApplicantsRouter');
        new Router('admin/applicants', { createTrailingSlashRoutes: true });
      },

      goToAdminMatches: function(subroute) {
        var Router = modulejs.require('adminMatchesRouter');
        new Router('admin/matches', { createTrailingSlashRoutes: true });
      },

      goToAdminMembers: function(subroute) {
        var Router = modulejs.require('adminMembersRouter');
        new Router('admin/members', { createTrailingSlashRoutes: true });
      },

      goToAdminPools: function(subroute) {
        var Router = modulejs.require('adminPoolsRouter');
        new Router('admin/pools', { createTrailingSlashRoutes: true });
      },

      goToAdminVenues: function(subroute) {
        var Router = modulejs.require('adminVenuesRouter');
        new Router('admin/venues', { createTrailingSlashRoutes: true });
      },

      goToAdminVouchers: function(subroute) {
        var Router = modulejs.require('adminVouchersRouter');
        new Router('admin/vouchers', { createTrailingSlashRoutes: true });
      },

      goToAdminReservations: function(subroute) {
        var Router = modulejs.require('adminReservationsRouter');
        new Router('admin/reservations', { createTrailingSlashRoutes: true });
      },

      goToMembership: function(subroute) {
        var Router = modulejs.require('membershipRouter');
        new Router('user/membership', { createTrailingSlashRoutes: true });
      },

      goToPayment: function(subroute) {
        var Router = modulejs.require('paymentRouter');
        new Router('user/payment', { createTrailingSlashRoutes: true });
      },

      goToReservations: function(subroute) {
        var Router = modulejs.require('reservationsRouter');
        new Router('user/reservations', { createTrailingSlashRoutes: true });
      },

      goToFaq: function() {
        $('.collapse').on('show.bs.collapse', function() {
          $(this).siblings('h3').find('i').removeClass('fa-plus-square-o').addClass('fa-minus-square-o');
        });

        $('.collapse').on('hide.bs.collapse', function() {
          $(this).siblings('h3').find('i').addClass('fa-plus-square-o').removeClass('fa-minus-square-o');
        });
      },

      goToWhyFacebook: function() {
        var eventName = 'Declined Facebook Permission';
        tracking.trackEvent(eventName);
      },

      goToHome: function() {
        var bindFacebookSignup = (function(){
          var eventName = 'Pressed Sign up Button';

          $('.jumbotron').on('click', 'a[href^="https://www.facebook.com"]', function(){
            tracking.trackEvent(eventName, { 'Button': 'Main', 'Page Name': 'Home' });
          });

          $('#block-say-yes').on('click', 'a[href^="https://www.facebook.com"]', function(){
            tracking.trackEvent(eventName, { 'Button': 'Footer', 'Page Name': 'Home' });
          });

        })();

        $('.arrow-down').on('click',function() {
          var scrollTo = $('#counter').offset().top;

          $('html, body').animate({
            scrollTop: scrollTo
          }, 1000);
        });

        $('#gallery-silder').owlCarousel({
          pagination: false,
          autoPlay: 5500,
          items: 5,
          itemsScaleUp:true,
          autoHeight : true,
          itemsTablet: [780,3],
          itemsMobile : false
        });

        var testi = $('#testi-slider');

        testi.owlCarousel({
          navigation: false,
          pagination: false,
          autoPlay: 10000,
          singleItem : true,
          autoHeight : true
        });

        $('.next').click(function() { testi.trigger('owl.next'); })
        $('.prev').click(function() { testi.trigger('owl.prev'); });

        $('.tab-heading').on('click', function() {
          var icon = $(this).find('.icon-square');

          if (icon.hasClass('icon-plus')) {
            icon.removeClass('icon-plus').addClass('icon-minus');
          } else {
            icon.removeClass('icon-minus').addClass('icon-plus');
          }

          var content = $(this).closest('.tab-container').find('.tab-content');
          content.slideToggle();
        });
      }
    });

    new GrouvlyRouter();

    Backbone.history.start({ root: '', pushState: true, hashChange: false });
  };

  return { initialize: init };
});
