modulejs.define('adminVouchersRouter', ['jquery', 'backbone'], function($, Backbone) {
  var subroute = Backbone.SubRoute.extend({
    routes: {
      ':id/edit': 'goToDefault',
      ':id': 'goToDefault',
      'new': 'goToDefault',
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

      $('#voucher_user_id').selectize({
        valueField: 'id',
        labelField: 'name',
        searchField: 'name',
        render: {
          option: function(item, escape) {
            var info = item.user_info;
            var smallPicture = escape(info.small_profile_picture);
            var userLocation = escape(info.location);

            return (
              '<div class="media">' +
                '<div class="media-left">' +
                  '<img src="' + smallPicture + '"/>' +
                '</div>' +
                '<div class="media-body">' +
                  '<h4 class="media-heading">' + escape(item.name) + '</h4>' +
                  '<span class="description">' + userLocation + '</span>' +
                '</div>' +
              '</div>'
            );
          }
        },
        load: function(query, callback) {
          if (!query.length) return callback();

          $.ajax({
            url: '/admin/members/search/?name=' + encodeURIComponent(query),
            type: 'GET',
            dataType: 'json',
            error: function() { callback(); },
            success: function(res) { callback(res.members); }
          });
        }
      });
    },
  });

  return subroute;
});
