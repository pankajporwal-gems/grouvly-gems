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

  var component = React.createClass({
    mixins: [ImmutableRenderMixin],

    render: function() {
      return (
        <div className='block-work row'>
          <div className='container-fluid'>
            <p>{showWorkHistory(this.props.user.user_info)}</p>
          </div>
        </div>
      );
    }
  });

  return component;
});
