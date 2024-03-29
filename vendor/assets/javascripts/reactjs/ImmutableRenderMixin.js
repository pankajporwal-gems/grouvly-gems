modulejs.define('immutableRenderMixin', ['shallowEqualImmutable'], function(shallowEqualImmutable) {
  var ImmutableRenderMixin = {
    shouldComponentUpdate: function(nextProps, nextState) {
      return !shallowEqualImmutable(this.props, nextProps) || !shallowEqualImmutable(this.state, nextState);
    }
  };

  return ImmutableRenderMixin;
});
