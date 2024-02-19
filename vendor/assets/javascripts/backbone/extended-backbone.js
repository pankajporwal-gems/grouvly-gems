// Router callbacks
Backbone.Router.prototype.before = function () {};
Backbone.Router.prototype.after = function () {};

Backbone.Router.prototype.route = function (route, name, callback) {
  if (!_.isRegExp(route)) route = this._routeToRegExp(route);

  if (_.isFunction(name)) {
    callback = name;
    name = '';
  }

  if (!callback) callback = this[name];

  var router = this;

  Backbone.history.route(route, function(fragment) {
    var args = router._extractParameters(route, fragment);

    router.before.apply(router, arguments);
    callback && callback.apply(router, args);
    router.after.apply(router, arguments);

    router.trigger.apply(router, ['route:' + name].concat(args));
    router.trigger('route', name, args);
    Backbone.history.trigger('route', router, name, args);
  });
  return this;
};


Backbone._sync = Backbone.sync;

Backbone.RailsJSON = {
  _name : function() {
    return this.name;
  },

  isWrapped : function(object) {
    return (object.hasOwnProperty(this._name()) && (typeof(object[this._name()]) == "object"));
  },

  unwrappedAttributes : function(object) {
    return object[this._name()];
  },

  wrappedAttributes : function() {
    var object = new Object;
    object[this._name()] = _.clone(this.attributes);

    if (this._name() == "ordered_control") object[this._name()]["root_control"] = _.clone(this.attributes);

    object.id = object[this._name()].id;

    return object;
  },

  maybeUnwrap : function(args) {
    if (this.isWrapped(args)) {
      this.set(this.unwrappedAttributes(args), { silent: true });
      this.unset(this._name(), { silent: true });
      this._previousAttributes = _.clone(this.attributes);
    }
  }
};

_.extend(Backbone.Model.prototype, Backbone.RailsJSON, {
  parse : function(resp) { return this.unwrappedAttributes(resp); },

  toJSON : function() {
    var object = this.wrappedAttributes();
    var csrfName = $("meta[name='csrf-param']").attr('content');
    var csrfValue = $("meta[name='csrf-token']").attr('content');
    object[csrfName] = csrfValue;

    return object;
  },

  initialize : function(args) {
    args = args || {};
    this.maybeUnwrap(args);
  }
});

Backbone.sync = function(method, model, options) {
  if (method == 'create' || method == 'update' || method == 'delete') {
    options.headers = {};
    options.headers["X-CSRF-Token"] = $("meta[name='csrf-token']").attr('content');
  }

  return Backbone._sync(method, model, options);
}
