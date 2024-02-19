modulejs.define('moveGrouvly', ['react', 'immutableRenderMixin'], function(React, ImmutableRenderMixin) {
  var component = React.createClass({displayName: "component",
    mixins: [ImmutableRenderMixin],

    render: function() {
      return (
        <div className='block-work row'>
          <div className='container-fluid'>
            <input type="checkbox" name="move_to" value={this.props.roll_count}>Move To</input>
          </div>
        </div>
      );
    }
  });
  return component;
});
