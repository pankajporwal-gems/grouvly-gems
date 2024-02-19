modulejs.define('cancelBooking', ['react', 'immutableRenderMixin'], function(React, ImmutableRenderMixin) {
  var component = React.createClass({displayName: "component",
    mixins: [ImmutableRenderMixin],

    render: function() {
      var user = this.props.user;
      var id = this.props.reservation_id

      return (
        React.createElement("div", {className: "row"},
          React.createElement("a", {href: "#"},
            React.createElement("button", {className: "btn-danger cancel_booking_btn", 'data-id': id}, "Cancel Booking")
          )
        )
      );
    }
  });

  return component;
});

$(document).on('click', ".cancel_booking_btn", function(){
  var id = $(this).attr("data-id");
  var url = '/admin/reservations/'+id+'/cancel_booking';
  swal({
    title: I18n.t('admin.matches.show.are_you_sure_cancel'),
    text: I18n.t('admin.matches.show.cancellation_msg'),
    type: "warning",
    showCancelButton: true,
    confirmButtonClass: "btn-danger",
    cancelButtonText: I18n.t('admin.matches.show.cancel'),
    confirmButtonText: I18n.t('admin.matches.show.ok'),
    closeOnConfirm: false
  },
  function(){
    $.ajax({
      type: 'GET',
      url: url,
      dataType: 'json',
      success: function(notification){
        if (notification.result){
          swal({
            title: I18n.t('admin.matches.show.cancelled_booking'),
            text: notification.msg,
            type: 'success'
          },
          function() {
            $(".block-reservation-"+id+"").hide();
          });
        }
        else{
          swal({
            title: I18n.t('admin.matches.show.booking_not_cancelled'),
            text: notification.msg,
            type: 'error'
          });
        }
      }
    })
  });
});


