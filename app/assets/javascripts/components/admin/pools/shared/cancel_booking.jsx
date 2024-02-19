modulejs.define('cancelBooking', ['react', 'immutableRenderMixin'], function(React, ImmutableRenderMixin) {
  var component = React.createClass({displayName: "component",
    mixins: [ImmutableRenderMixin],

    render: function() {
      var user = this.props.user;
      var id = this.props.reservation_id
      var userLink = '/admin/reservations/'+id+'/cancel_booking';

      return (
        <div className='row'>
          <a href={userLink}>
            <button className='btn-danger'>Cancel Booking</button>
          </a>
        </div>
      );
    }
  });
  return component;
});
