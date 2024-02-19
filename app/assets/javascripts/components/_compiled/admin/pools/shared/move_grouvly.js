modulejs.define('moveGrouvly', ['react', 'immutableRenderMixin'], function(React, ImmutableRenderMixin) {
  var component = React.createClass({displayName: "component",
    mixins: [ImmutableRenderMixin],

    render: function() {
      return (
        React.createElement('div',{ className: 'block-work row' },
          React.createElement('div',{ className: 'container-fluid' },
            React.createElement('input',{ type: 'checkbox', name: 'move_to', value: this.props.reservation_id },'Move To')
          )
        )
      );
    }
  });

  return component;
});
