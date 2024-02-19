modulejs.define('userEducationHistory', ['underscore', 'react', 'immutableRenderMixin'], function(_, React,
  ImmutableRenderMixin) {

  var showEducationHistory = function(info) {
    var str = info.studied_at;
    var educationHistory = info.education_history;
    var strArr = [];

    if (educationHistory) {
      str = str + ' / ';

      _.each(educationHistory, function(education) {
        var temp = education.school.name;

        if (education.concentration) temp = temp + ' (' + education['concentration'][0]['name'] + ')';

        if (education.type) temp = temp + '(' + education.type + ')';

        strArr.push(temp);
      });

      str = str + strArr.join(' / ');
    }

    return str;
  };

  var component = React.createClass({displayName: "component",
    mixins: [ImmutableRenderMixin],

    render: function() {
      return (
        React.createElement("div", {className: "block-education row"}, 
          React.createElement("div", {className: "container-fluid"}, 
            React.createElement("p", null, showEducationHistory(this.props.user.user_info))
          )
        )
      );
    }
  });

  return component;
});
