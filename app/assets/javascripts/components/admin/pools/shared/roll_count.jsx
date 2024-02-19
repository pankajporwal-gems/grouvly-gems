modulejs.define('rollCount', ['react', 'immutableRenderMixin'], function(React, ImmutableRenderMixin) {
  var component = React.createClass({displayName: "component",
    mixins: [ImmutableRenderMixin],

    render: function() {
      return (
        <div className='block-work row'>
          <div className='container-fluid'>
            <p className='roll-count'>{'skip count:  ', this.props.roll_count}</p>
          </div>
        </div>
      );
    }
  });
  return component;
});
