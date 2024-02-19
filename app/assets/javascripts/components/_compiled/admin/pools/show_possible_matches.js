modulejs.define('adminPoolsShowPossibleMatches', ['react', 'poolStore', 'poolActions', 'adminPoolsReservationItem',
  'immutableRenderMixin', 'i18n'], function(React, PoolStore, PoolActions, AdminPoolsReservationItem,
    ImmutableRenderMixin, i18n) {

  var _element = $('#block-pagination-second .pagination a[rel=next]');
  var _url = _element.attr('href');
  var _end = false;
  var _page = 0;

  function fixUrl(page) {
    var url = _url.split('page=');
    url = (url[0] + 'page=' + page).split('/');
    url[3] = PoolStore.getChosenReservation();
    _page = page;
    return url.join('/');
  }

  function setupScroll() {
    var element =  $('#block-reserved-users-second');

    element.infinitescroll({
      navSelector: '#block-pagination-second .pagination',
      nextSelector: _element,
      itemSelector: '#block-reserved-users-second',
      dataType: 'json',
      appendCallback: false,
      path: function(page) { return fixUrl(page); },
      loading: {
        msgText: '<em>' + i18n.t('admin.pools.show.loading_users') + '</em>',
        speed: 'slow'
      }
    }, function(data) {
      PoolActions.fetchedOtherPossibleMatches(data);

      if (data) {
        if ($.parseJSON(data.matches).length == 0) _end = true;
      }
    });

    element.infinitescroll('update', { state: { currPage: 1 } });

    _end = false;

    for (var i=0; i<_page; i++) {
      if (_end) break;

      element.infinitescroll('retrieve');
    }
  }

  var component = React.createClass({displayName: "component",
    mixins: [ImmutableRenderMixin],

    getInitialState: function() {
      return { collection: PoolStore.getAllPossibleMatches() };
    },

    componentDidMount: function() {
      PoolStore.addFetchedOtherPossibleMatchesListener(this._onChange);
      setupScroll();
    },

    componentWillUnmount: function() {
      PoolStore.removeFetchedOtherPossibleMatchesListener(this._onChange);
    },

    _onFetchedOtherPossibleMatches: function() {
      this.setState({ collection: PoolStore.getAllPossibleMatches() });
    },

    _onChange: function() {
      this.setState({ collection: PoolStore.getAllPossibleMatches() });
    },

    render: function() {
      var html = null;

      console.log(this.state);
      if (this.state.collection.size < 1) {
        html = React.createElement("div", {className: "text-center"}, "Nothing to match.");
      } else {
        var collection = this.state.collection;
        var reservations = [];

        collection.forEach(function(model, index) {
          var key = 'possible-match-' + index;
          var view = React.createElement(AdminPoolsReservationItem, {key: key, model: model, type: "second"});
          reservations.push(view);
        });
        html = React.createElement("div",null,
          React.createElement("h5",{ className: "text-center" },
            React.createElement("strong",null,"Potential matches")
          ),
        reservations
        );
      }

      return html;
    }
  });

  return component;
});
