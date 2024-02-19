modulejs.define('adminMembersRouter', ['jquery', 'backbone'], function($, Backbone) {
  var subroute = Backbone.SubRoute.extend({
    routes: {
      ':memberId': 'goToDefault',
      '': 'goToDefault'
    },

    goToDefault: function() {
      var Helper = modulejs.require('helper');
      Helper.addColorbox();
    }
  });

  return subroute;
});
