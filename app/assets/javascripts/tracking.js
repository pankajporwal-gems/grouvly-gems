modulejs.define('tracking', ['underscore'], function(_) {

  var trackedEvents = [];

  var init = function() {
    if (!window.analytics){
      return false;
    }
    _trackPage();
    _identifyUser();
  };

  var trackEvent = function(name, attributes, preventDuplicate) {
    // Prevent duplication of events on some elements (required for triggers such as focus, blur, keyup/down)
    if (preventDuplicate && _.indexOf(trackedEvents, name) != -1) {
      return false;
    }
    // Merge attributes with the user details
    attributes = _.extend(attributes, _traits());
    // Push events to Segment
    window.analytics.track(name, attributes);

    trackedEvents.push(name);
  };

  var _trackPage = function () {
    var pageName = gon.pageName || null;
    window.analytics.page(pageName);
  };

  var _identifyUser = function () {
    if (gon.user_identifier) {
      window.analytics.identify(gon.user_identifier, _traits());
    }
  };

  var _traits = function () {
    return {
      name: gon.name, // Required by Zendesk
      firstName: gon.firstName,
      lastName: gon.lastName,
      email: gon.email,
      age: gon.age,
      gender: gon.gender,
      height: gon.height,
      ethnicity: gon.ethnicity,
      education: gon.education,
      title: gon.title,
      company: gon.company,
      phone: gon.phone,
      city: gon.city,
      facebookID: gon.facebookID,
      tags: gon.tags,
      signUpDate: gon.signUpDate,
      notes: gon.notes, // Used by Zendesk

      grouvlerType: gon.grouvlerType,
      acceptanceDate: gon.acceptanceDate,
      totalGrouvlyBooked: gon.totalGrouvlyBooked,
      totalGrouvlyCompleted: gon.totalGrouvlyCompleted,
      nextGrouvlyDate: gon.nextGrouvlyDate,
      lastGrouvlyDate: gon.lastGrouvlyDate,

      referred: gon.referred,
      membership: gon.membership,
      sessionCount: gon.sessionCount,

      acquisitionSource: gon.acquisitionSource,
      acquisitionChannel: gon.acquisitionChannel,
      acquisitionMedium: gon.acquisitionMedium
    }
  };

  return { initialize: init, trackEvent: trackEvent };
});
