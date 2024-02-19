modulejs.define('shallowEqualImmutable', ['immutable'], function(Immutable) {
  var shallowEqualImmutable = function(objA, objB) {
    if (Immutable.is(objA, objB)) return true;

    var key;

    // Test for A's keys different from B.
    for (key in objA) {
      if (objA.hasOwnProperty(key) && (!objB.hasOwnProperty(key) || !Immutable.is(objA[key], objB[key]))) {
        return false;
      }
    }

    // Test for B's keys missing from A.
    for (key in objB) {
      if (objB.hasOwnProperty(key) && !objA.hasOwnProperty(key)) return false;
    }

    return true;
  };

  return shallowEqualImmutable;
});
