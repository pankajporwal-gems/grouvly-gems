modulejs.define('userQualities', ['react', 'immutableRenderMixin', 'i18n'], function(React,
  ImmutableRenderMixin, i18n) {

  var component = React.createClass({displayName: "component",
    mixins: [ImmutableRenderMixin],

    render: function() {
      var userInfo = this.props.user.user_info;

      return (
        React.createElement("table", {className: "table table-bordered"},
          React.createElement("thead", null,
            React.createElement("tr", null,
              React.createElement("th", {className: "background-gray", width: "25%"}, i18n.t('admin.pools.show.religion')),
              React.createElement("th", {width: "25%"}, i18n.t('admin.pools.show.neighborhood')),
              React.createElement("th", {className: "background-gray", width: "25%"}, i18n.t('admin.pools.show.ethnicity')),
              React.createElement("th", {width: "25%"}, i18n.t('admin.pools.show.height'))
            )
          ),

          React.createElement("tbody", null,
            React.createElement("tr", null,
              React.createElement("td", {className: "background-gray"}, userInfo.religion),
              React.createElement("td", null, userInfo.neighborhoods),
              React.createElement("td", {className: "background-gray"}, userInfo.ethnicity),
              React.createElement("td", null, userInfo.height)
            ),

            React.createElement("tr", null,
              React.createElement("td", {className: "background-gray text-lowercase"}, userInfo.importance_of_religion),
              React.createElement("td", null),
              React.createElement("td", {className: "background-gray text-lowercase"}, userInfo.importance_of_ethnicity),
              React.createElement("td", null)
            )
          )
        )
      );
    }
  });

  return component;
});
