modulejs.define('userQualities', ['react', 'immutableRenderMixin', 'i18n'], function(React,
  ImmutableRenderMixin, i18n) {

  var component = React.createClass({
    mixins: [ImmutableRenderMixin],

    render: function() {
      var userInfo = this.props.user.user_info;

      return (
        <table className='table table-bordered'>
          <thead>
            <tr>
              <th className='background-gray' width='25%'>{i18n.t('admin.pools.show.religion')}</th>
              <th width='25%'>{i18n.t('admin.pools.show.neighborhood')}</th>
              <th className='background-gray' width='25%'>{i18n.t('admin.pools.show.ethnicity')}</th>
              <th width='25%'>{i18n.t('admin.pools.show.height')}</th>
            </tr>
          </thead>

          <tbody>
            <tr>
              <td className='background-gray'>{userInfo.religion}</td>
              <td>{userInfo.neighborhoods}</td>
              <td className='background-gray'>{userInfo.ethnicity}</td>
              <td>{userInfo.height}</td>
            </tr>

            <tr>
              <td className='background-gray text-lowercase'>{userInfo.importance_of_religion}</td>
              <td></td>
              <td className='background-gray text-lowercase'>{userInfo.importance_of_ethnicity}</td>
              <td></td>
            </tr>
          </tbody>
        </table>
      );
    }
  });

  return component;
});
