modulejs.define('adminPoolsShow', ['jquery', 'react', 'poolStore', 'poolActions', 'adminPoolsReservationItem',
  'adminPoolsShowPossibleMatches', 'immutableRenderMixin', 'i18n'], function($, React, PoolStore, PoolActions,
    AdminPoolsReservationItem, AdminPoolsShowPossibleMatches, ImmutableRenderMixin, i18n) {

  function setupScroll() {
    $('#block-reserved-users-first').infinitescroll({
      navSelector: '#block-pagination-first .pagination',
      nextSelector: '#block-pagination-first .pagination a[rel=next]',
      itemSelector: '#block-reserved-users-first',
      dataType: 'json',
      appendCallback: false,
      loading: {
        msg: null,
        msgText: '<em>' + i18n.t('admin.pools.show.loading_users') + '</em>',
        selector: null,
        speed: 'slow',
        start: undefined
      },
    }, function(data) { PoolActions.fetchedOtherReservations(data); });
  }

  var component = React.createClass({displayName: "component",
    mixins: [ImmutableRenderMixin],

    getInitialState: function() {
      return { collection: PoolStore.getAll() };
    },

    componentDidMount: function() {
      PoolStore.addFetchedOtherReservationsListener(this._onFetchedOtherReservations);
      PoolStore.addFetchedPossibleMatchesListener(this._onFetchedPossibleMatches);
      setupScroll();
    },

    componentWillUnmount: function() {
      PoolStore.removeFetchedOtherReservationsListener(this._onFetchedOtherReservations);
      PoolStore.removeFetchedPossibleMatchesListener(this._onFetchedPossibleMatches);
    },

    _onFetchedOtherReservations: function() {
      this.setState({ collection: PoolStore.getAll() });
    },

    _onFetchedPossibleMatches: function() {
      React.render(React.createElement(AdminPoolsShowPossibleMatches, null), $('#block-reservation-pool #block-match-second')[0]);
    },

    render: function() {
      var html;

      if (this.state.collection.size < 1) {
        html = React.createElement("div", {className: "col-md-12 text-center"}, "Nothing to match.");
      } else {
        var collection = this.state.collection;
        var reservations = [];

        collection.forEach(function(model, index) {
          var view = React.createElement(AdminPoolsReservationItem, {key: index, model: model, type: "first"});
          reservations.push(view);
        });

        html = React.createElement("div",null,
          React.createElement("h5",{ className: "text-center" },
            React.createElement("strong",null,"All bookings for today")
          ),
        reservations
        );
      }

      return html;
    }
  });

  return component;
});
