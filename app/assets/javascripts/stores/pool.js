modulejs.define('poolStore', ['underscore', 'eventEmitter', 'immutable', 'appDispatcher', 'poolConstants'],
  function(_, EventEmitter, Immutable, AppDispatcher, PoolConstants) {

  var FETCHED_POSSIBLE_MATCHES_EVENT = 'fetched_possible_matches_pool';
  var FETCHED_OTHER_POSSIBLE_MATCHES_EVENT = 'fetched_other_possible_matches_pool';
  var FETCHED_OTHER_RESERVATIONS_EVENT = 'fetched_other_reservations_pool';

  var _pools = Immutable.OrderedMap();
  var _possiblePools = Immutable.OrderedMap();
  var _chosenReservation = null;

  function create(params) {
    _pools = _pools.set(params.id, Immutable.fromJS(params));
  }

  function createPossibleMatch(params) {
    _possiblePools = _possiblePools.set(params.id, Immutable.fromJS(params));
  }

  function createPossibleMatches(matches) {
    _.each(matches, function(pool) { createPossibleMatch(pool); });
  }

  var PoolStore = _.extend({}, EventEmitter.prototype, {
    getAll: function() {
      if (_pools.size < 1) {
        var collection = $.parseJSON($('#ReservationsData').html());
        if (collection.length > 0) _.each(collection, function(values) { create(values); });
      }

      return _pools;
    },

    getAllPossibleMatches: function() { return _possiblePools; },

    getChosenReservation: function() { return _chosenReservation; },

    emitFetchedPossibleMatches: function() { this.emit(FETCHED_POSSIBLE_MATCHES_EVENT); },

    emitFetchedOtherPossibleMatches: function() { this.emit(FETCHED_OTHER_POSSIBLE_MATCHES_EVENT); },

    emitFetchedOtherReservations: function() { this.emit(FETCHED_OTHER_RESERVATIONS_EVENT); },

    addFetchedPossibleMatchesListener: function(callback) { this.on(FETCHED_POSSIBLE_MATCHES_EVENT, callback); },

    addFetchedOtherPossibleMatchesListener: function(callback) { this.on(FETCHED_OTHER_POSSIBLE_MATCHES_EVENT, callback); },

    addFetchedOtherReservationsListener: function(callback) { this.on(FETCHED_OTHER_RESERVATIONS_EVENT, callback); },

    removeFetchedPossibleMatchesListener: function(callback) { this.removeListener(FETCHED_POSSIBLE_MATCHES_EVENT, callback); },

    removeFetchedOtherPossibleMatchesListener: function(callback) { this.removeListener(FETCHED_OTHER_POSSIBLE_MATCHES_EVENT, callback); },

    removeFetchedOtherReservationsListener: function(callback) { this.removeListener(FETCHED_OTHER_RESERVATIONS_EVENT, callback); }
  });

  AppDispatcher.register(function(payload) {
    console.log("PAYLOAD", payload);

    switch(payload.actionType) {
      case PoolConstants.POOL_POSSIBLE_MATCHES_FETCH:
        _possiblePools = Immutable.OrderedMap();
        _chosenReservation = payload.values.slug;
        createPossibleMatches(payload.values.matches);
        PoolStore.emitFetchedPossibleMatches();
        break;

      case PoolConstants.POOL_FETCHED_OTHER_RESERVATIONS:
        _.each(payload.values, function(pool) { create(pool); });
        PoolStore.emitFetchedOtherReservations();
        break;

      case PoolConstants.POOL_FETCHED_OTHER_POSSIBLE_MATCHES:
        if (payload.values.matches) {
          createPossibleMatches(payload.values.matches);
          PoolStore.emitFetchedOtherPossibleMatches();
        }

        break;
    };

    return true;
  });

  return PoolStore;
});
