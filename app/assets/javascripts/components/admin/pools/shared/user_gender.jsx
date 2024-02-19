modulejs.define('userGender', ['react', 'immutableRenderMixin', 'i18n'], function(React,
  ImmutableRenderMixin, i18n) {

  var showGender = function(info) {
    var likeGender = info.gender_to_match;
    var gender = info.gender;

    if (likeGender == 'female' && gender == 'male') {
      return i18n.t('admin.terms.straight_male');
    } else if (likeGender == 'male' && gender == 'female') {
      return i18n.t('admin.terms.straight_female');
    } else {
      return i18n.t('admin.terms.gay')
    }
  };

  var component = React.createClass({
    mixins: [ImmutableRenderMixin],

    render: function() {
      return (
        <div className='block-gender row'>
          <div className='container-fluid'>
            <p>{showGender(this.props.user.user_info)}</p>
          </div>
        </div>
      );
    }
  });

  return component;
});
