modulejs.define('appDispatcher', ['flux'], function(Flux) {
  var Dispatcher = Flux.Dispatcher;
  var AppDispatcher = new Dispatcher();

  return AppDispatcher;
});
