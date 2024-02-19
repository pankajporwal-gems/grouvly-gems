modulejs.define('adminPoolsReservationItem', ['react', 'userPhotos', 'userInformation', 'userWorkHistory',
  'userEducationHistory', 'userGender', 'userQualities', 'immutableRenderMixin', 'poolActions', 'cancelBooking', 'rollCount', 'moveGrouvly'],
  function(React, UserPhotos, UserInformation, UserWorkHistory, UserEducationHistory, UserGender,
    UserQualities, ImmutableRenderMixin, PoolActions, cancelBooking, rollCount, moveGrouvly) {

  var firstReservationChosen = function(el, model) {
    var view = React.createFactory(component);
    var blockPossibleMatches = $('#block-reservation-pool #block-match-second')[0];
    var blockChosenFirst = $('#block-chosen-first')[0];
    var blockChosenSecond = $('#block-chosen-second')[0];
    var blockChosen = $('#block-chosen-pool');
    var btnConfirm = $('.btn-confirm-match');

    blockChosen.removeClass('hidden');
    $('.block-match-user').removeClass('active');
    $(el).addClass('active');

    React.unmountComponentAtNode(blockChosenFirst);
    React.unmountComponentAtNode(blockChosenSecond);
    React.unmountComponentAtNode(blockPossibleMatches);
    React.render(view({ model: model, type: 'chosenFirst' }), blockChosenFirst);

    if (!btnConfirm.hasClass('disabled')) btnConfirm.addClass('disabled');

    $('#first_reservation_id').val(model.get('slug'));
  };

  var secondReservationChosen = function(el, model) {
    var view = React.createFactory(component);
    var blockChosenSecond = $('#block-chosen-second')[0];
    var btnConfirm = $('.btn-confirm-match');

    $('#block-match-second .block-match-user').removeClass('active');
    $(el).addClass('active');

    React.unmountComponentAtNode(blockChosenSecond);
    React.render(view({ model: model, type: 'chosenSecond' }), blockChosenSecond);

    if (btnConfirm.hasClass('disabled')) btnConfirm.removeClass('disabled');

    $('#second_reservation_id').val(model.get('slug'));
  };

  var component = React.createClass({displayName: "component",
    mixins: [ImmutableRenderMixin],

    _onClick: function() {
      var el = this.getDOMNode();
      var model = this.props.model;

      if (this.props.type == 'first') {
        firstReservationChosen(el, model);
        PoolActions.fetchPossibleMatches(model.get('slug'))
      } else if (this.props.type == 'second' ) {
        secondReservationChosen(el, model);
      }
    },

    render: function() {
      var model = this.props.model.toJS();
      var userId = model.user.id;
      var dangerBlock = null;
      var reservationId = model.slug;
      var wing_count = model.wing_quantity;

      if (model.current_state !== 'payment_entered' && model.current_state !== 'pending_payment') {
        dangerBlock = React.createElement("span", {className: "label label-danger"}, "DO NOT MATCH THIS. REPORT THIS DATA TO KARREN OR SILVIA!");
      }

      if (model.current_state == 'pending_payment') {
        dangerBlock = React.createElement("span", {className: "label label-danger"}, "Pending Payment!");
      }


      return (
        React.createElement("div", {className: "block-match-user clearfix block-reservation-"+ reservationId+"", onClick: this._onClick},
          React.createElement("div", {className: "col-md-3"},
            React.createElement(UserPhotos, {lead: model.user, wings: model.wings, wing_count: wing_count})
          ),

          React.createElement("div", {className: "col-md-6"},
            dangerBlock,
            React.createElement(UserInformation, {user: model.user, wings: model.wings, wing_count: wing_count, key: 'user-information' + userId}),
            React.createElement(UserWorkHistory, {user: model.user, key: 'user-work-history' + userId}),
            React.createElement(UserEducationHistory, {user: model.user, key: 'user-education-history' + userId}),
            React.createElement(UserGender, {user: model.user, key: 'user-gender' + userId}),
            React.createElement(moveGrouvly, {reservation_id: reservationId, key: 'move-grouvly' + userId}),
            React.createElement(rollCount, {roll_count: model.roll_count, key: 'roll-count' + userId})
          ),


          React.createElement("div", {className: "col-md-3"},
            React.createElement(cancelBooking, {user: model.user, key: 'cancel-booking' + userId, reservation_id: reservationId})
          ),


          React.createElement("div", {className: "col-md-12"},
            React.createElement(UserQualities, {user: model.user, key: 'user-qualities' + userId})
          )
        )
      );
    }
  });

  return component;
});
