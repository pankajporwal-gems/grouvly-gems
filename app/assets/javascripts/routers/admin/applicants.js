modulejs.define('adminApplicantsRouter', ['jquery', 'backbone'], function($, Backbone) {
  var subroute = Backbone.SubRoute.extend({
    routes: {
      ':applicantId': 'goToDefault',
      '': 'goToDefault'
    },

    goToDefault: function() {
      var Helper = modulejs.require('helper');
      Helper.addColorbox();
    }
  });

  return subroute;
});
