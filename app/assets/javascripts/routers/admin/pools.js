modulejs.define('adminPoolsRouter', ['jquery', 'backbone', 'react', 'poolStore'], function($,
  Backbone, React, PoolStore) {

  var subroute = Backbone.SubRoute.extend({
    routes: {
      ':locationId': 'goToShow'
    },

    goToShow: function(id, params) {
      var React = modulejs.require('react');
      var AdminPoolsShow = modulejs.require('adminPoolsShow');
      var AdminPoolsShowPossibleMatches = modulejs.require('adminPoolsShowPossibleMatches');
      var view = React.createFactory(AdminPoolsShow);
      var view2 = React.createFactory(AdminPoolsShowPossibleMatches);

      if (PoolStore.getAll().size < 1) {
        React.render(view({ params: params }), $('#block-reservation-pool')[0]);
      } else {
        React.render(view({ params: params }), $('#block-reservation-pool #block-match-first')[0]);
        React.render(view2(), $('#block-reservation-pool #block-match-second')[0]);
      }
    }
  });

  return subroute;
});
