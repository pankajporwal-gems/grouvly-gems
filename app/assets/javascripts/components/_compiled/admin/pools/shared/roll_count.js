modulejs.define('rollCount', ['react', 'immutableRenderMixin'], function(React, ImmutableRenderMixin) {
  var component = React.createClass({displayName: "component",
    mixins: [ImmutableRenderMixin],

    render: function() {
      return (
        React.createElement("div", {className: "block-work row"},
          React.createElement("div", {className: "container-fluid"},
            React.createElement('p',{className: "roll-count"},'skip count:  ', this.props.roll_count)
          )
        )
      );
    }
  });

  return component;
});
