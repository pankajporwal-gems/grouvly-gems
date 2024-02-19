modulejs.define('adminReservationsRouter', ['jquery', 'backbone'], function($, Backbone) {
  var subroute = Backbone.SubRoute.extend({
    routes: {
      '': 'goToDefault'
    },

    goToDefault: function() {
      $('.datepicker').datetimepicker({
        format: 'YYYY-MM-DD',
        icons: {
          time: 'fa fa-clock-o',
          date: 'fa fa-calendar',
          up: 'fa fa-chevron-up',
          down: 'fa fa-chevron-down',
          previous: 'fa fa-chevron-left',
          next: 'fa fa-chevron-right',
          today: 'fa fa-crosshairs',
          clear: 'fa fa-trash',
          close: 'fa fa-times'
        },
      });
    }
  });

  return subroute;
});
