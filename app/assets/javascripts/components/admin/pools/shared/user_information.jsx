modulejs.define('userInformation', ['react', 'immutableRenderMixin'], function(React, ImmutableRenderMixin) {
  var component = React.createClass({
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
        user_info =  <div className='block-user-information row'>
          <div className='container-fluid'>
            <div className='block-user-column'>
              <span>{user.age}</span>
              <span className='label label-primary'>{user.membership_type}</span>

              <span>
                <a href={userLink} target='_blank'>{user.name}</a>
              </span>
            </div>

            <div className='block-user-column'>
              <span>{wing1.age}</span>
              <span className='label label-primary'>{wings[0]}</span>
              <span>{wing1.name}</span>
            </div>
          </div>
        </div>
      }else {
        user_info =  <div className='block-user-information row'>
          <div className='container-fluid'>
            <div className='block-user-column'>
              <span>{user.age}</span>
              <span className='label label-primary'>{user.membership_type}</span>

              <span>
                <a href={userLink} target='_blank'>{user.name}</a>
              </span>
            </div>

            <div className='block-user-column'>
              <span>{wing1.age}</span>
              <span className='label label-primary'>{wings[0]}</span>
              <span>{wing1.name}</span>
            </div>

            <div className='block-user-column'>
              <span>{wing2.age}</span>
              <span className='label label-primary'>{wings[1]}</span>
              <span>{wing2.name}</span>
            </div>
          </div>
        </div>
      }

      return (
        user_info
      );
    }
  });

  return component;
});
