modulejs.define('adminMatchesRouter', ['jquery', 'backbone', 'i18n', 'configConstants'], function($, Backbone, i18n, ConfigConstants) {
  function alertSuccess(data, btn) {
    swal({
      title: i18n.t('admin.matches.show.captured'),
      text: data.message,
      type: 'success'
    }, function() {
      btn.remove();
    });
  }

  function alertError(data) {
    swal({
      title: i18n.t('admin.matches.show.capture_error'),
      text: data.responseJSON.errors,
      type: 'error'
    });
  }

  function confirmCapture() {
    $('.btn-capture').click(function(e) {
      e.preventDefault();

      var form = $(this).parents('form');
      var btn = $(this);

      swal({
        title: i18n.t('admin.matches.show.capture_payment'),
        text: i18n.t('admin.matches.show.are_you_sure_capture_payment'),
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: ConfigConstants.SWAL_CONFIRM_BUTTON_COLOR,
        cancelButtonText: i18n.t('admin.matches.show.cancel'),
        confirmButtonText: i18n.t('admin.matches.show.ok'),
        closeOnConfirm: false
      }, function() {
        btn.val(i18n.t('user.payments.securely_submitting'));
        btn.addClass('disabled');
        $('.sweet-alert button.confirm').attr('disabled', true).addClass('disabled');

        $.ajax({
          type: 'POST',
          url: form.attr('action'),
          data: form.serialize(),
          dataType: 'json'
        }).always(function (data, textStatus) {
          btn.val(i18n.t('admin.matches.show.capture'));
          btn.removeClass('disabled');
          $('.sweet-alert button.confirm').attr('disabled', false).removeClass('disabled');

          if (textStatus == 'success') {
            alertSuccess(data, btn);
          } else {
            alertError(data);
          }
        });
      });
    });
  }

  var confirmBookVenues = function () {
    $('#form_book_venues').on('click', '[type="submit"]', function (e) {
      e.preventDefault();
      swal({
        title: i18n.t('admin.matches.show.book_venues'),
        text: i18n.t('admin.matches.show.are_you_sure_book_venues'),
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: ConfigConstants.SWAL_CONFIRM_BUTTON_COLOR,
        cancelButtonText: i18n.t('admin.matches.show.cancel'),
        confirmButtonText: i18n.t('admin.matches.show.ok'),
        closeOnConfirm: true
      }, function () {
        $(e.delegateTarget).trigger('submit');
      });
    });
  };

  var confirmLocationDetails = function () {
    $('#form_notify_location_details').on('click', '[type="submit"]', function (e) {
      e.preventDefault();
      swal({
        title: i18n.t('admin.matches.show.location_details'),
        text: i18n.t('admin.matches.show.are_you_sure_send_location_details'),
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: ConfigConstants.SWAL_CONFIRM_BUTTON_COLOR,
        cancelButtonText: i18n.t('admin.matches.show.cancel'),
        confirmButtonText: i18n.t('admin.matches.show.ok'),
        closeOnConfirm: true
      }, function () {
        $(e.delegateTarget).trigger('submit');
      });
    });
  };

  var confirmUnmatchReservation = function () {
    $('.form_unmatch').on('click', '[type="submit"]', function (e) {
      e.preventDefault();
      swal({
        title: i18n.t('admin.matches.show.unmatch'),
        text: i18n.t('admin.matches.show.are_you_sure_unmatch'),
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: ConfigConstants.SWAL_CONFIRM_BUTTON_COLOR,
        cancelButtonText: i18n.t('admin.matches.show.cancel'),
        confirmButtonText: i18n.t('admin.matches.show.ok'),
        closeOnConfirm: true
      }, function () {
        $(e.delegateTarget).trigger('submit');
      });
    });
  };

  var confirmMatchReservation = function () {
    $('.confirm_match_btn').on('click', '[type="submit"]', function (e) {
      e.preventDefault();
      swal({
        title: i18n.t('admin.matches.show.confirm_match'),
        text: i18n.t('admin.matches.show.are_you_sure_confirm_match'),
        type: 'warning',
        showCancelButton: true,
        confirmButtonColor: ConfigConstants.SWAL_CONFIRM_BUTTON_COLOR,
        cancelButtonText: i18n.t('admin.matches.show.cancel'),
        confirmButtonText: i18n.t('admin.matches.show.ok'),
        closeOnConfirm: true
      }, function () {
        $(e.delegateTarget).trigger('submit');
      });
    });
  };


  var subroute = Backbone.SubRoute.extend({
    routes: {
      ':matchId': 'goToDefault',
      '': 'goToDefault'
    },

    goToDefault: function() {
      var Helper = modulejs.require('helper');
      Helper.addColorbox();
      confirmCapture();
      confirmBookVenues();
      confirmLocationDetails();
      confirmUnmatchReservation();
      confirmMatchReservation();
    }
  });

  return subroute;
});
