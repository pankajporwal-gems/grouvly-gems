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

  var component = React.createClass({
    mixins: [ImmutableRenderMixin],

    render: function() {
      return (
        <div className='block-education row'>
          <div className='container-fluid'>
            <p>{showEducationHistory(this.props.user.user_info)}</p>
          </div>
        </div>
      );
    }
  });

  return component;
});
