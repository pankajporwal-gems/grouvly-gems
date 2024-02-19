modulejs.define('userInformation', ['react', 'immutableRenderMixin'], function(React, ImmutableRenderMixin) {
  var component = React.createClass({displayName: "component",
    mixins: [ImmutableRenderMixin],

    render: function() {
      var user = this.props.user;
      var userLink = '/admin/members/' + user.slug;
      var wings = ['Wing Man 1', 'Wing Man 2'];
      var wing1 = this.props.wings[0];
      var wing2 = this.props.wings[1];
      var wing_count = this.props.wing_count;
      var user_info;

      if (wing1 == undefined){
        wing1 = user;
      }
      if (wing2 == undefined){
        wing2 = user;
      }

      if (wing_count == 1) {
        user_info = React.createElement("div", {className: "block-user-information row"},
          React.createElement("div", {className: "container-fluid"},
            React.createElement("div", {className: "block-user-column"},
              React.createElement("span", null, user.age),
              React.createElement("span", {className: "label label-primary"}, user.membership_type),

              React.createElement("span", null,
                React.createElement("a", {href: userLink, target: "_blank"}, user.name)
              )
            ),

            React.createElement("div", {className: "block-user-column"},
              React.createElement("span", null, wing1.age),
              React.createElement("span", {className: "label label-primary"}, wings[0]),
              React.createElement("span", null, wing1.name)
            )
          )
        )
      }else {
        user_info = React.createElement("div", {className: "block-user-information row"},
          React.createElement("div", {className: "container-fluid"},
            React.createElement("div", {className: "block-user-column"},
              React.createElement("span", null, user.age),
              React.createElement("span", {className: "label label-primary"}, user.membership_type),

              React.createElement("span", null,
                React.createElement("a", {href: userLink, target: "_blank"}, user.name)
              )
            ),

            React.createElement("div", {className: "block-user-column"},
              React.createElement("span", null, wing1.age),
              React.createElement("span", {className: "label label-primary"}, wings[0]),
              React.createElement("span", null, wing1.name)
            ),

            React.createElement("div", {className: "block-user-column"},
              React.createElement("span", null, wing2.age),
              React.createElement("span", {className: "label label-primary"}, wings[1]),
              React.createElement("span", null, wing2.name)
            )
          )
        )
      }

      return (
        user_info
      );
    }
  });

  return component;
});
