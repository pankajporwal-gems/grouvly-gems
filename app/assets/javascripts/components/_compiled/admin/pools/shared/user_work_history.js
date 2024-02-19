modulejs.define('userWorkHistory', ['underscore', 'react', 'immutableRenderMixin'], function(_, React,
  ImmutableRenderMixin) {

  var showWorkHistory = function(info) {
    var workHistory = info.work_history;
    var strArr = [];
    var str = '';

    if (info.current_employer) str += info.current_employer;

    if (info.current_work) str += '(' + info.current_work + ')';

    if (workHistory) {
      str = str + ' / ';

      _.each(workHistory, function(work) {
        var temp = work.employer.name;

        if (work.position) temp = temp + ' (' + work.position.name + ')';

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
        React.createElement("div", {className: "block-work row"}, 
          React.createElement("div", {className: "container-fluid"}, 
            React.createElement("p", null, showWorkHistory(this.props.user.user_info))
          )
        )
      );
    }
  });

  return component;
});
