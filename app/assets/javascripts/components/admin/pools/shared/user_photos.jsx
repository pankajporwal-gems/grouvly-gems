modulejs.define('userPhotos', ['jquery', 'react', 'immutableRenderMixin'], function($, React,
  ImmutableRenderMixin) {

  var component = React.createClass({
    mixins: [ImmutableRenderMixin],

    componentDidMount: function() {
      var leadClass = 'user-' + this.props.lead.slug;
      $('.' + leadClass).colorbox({ rel: leadClass });
    },

    render: function() {
      var lead = this.props.lead;
      var leadInfo = lead.user_info;
      var leadClass = 'img-colorbox user-' + lead.slug;
      var wing1 = this.props.wings[0];
      var wing2 = this.props.wings[1];
      var wing_count = this.props.wing_count;
      var user_photos;

      if (wing1 == undefined){
        wing1 = lead;
      }
      if (wing2 == undefined){
        wing2 = lead;
      }
      var wing1Info = wing1.user_info;
      var wing2Info = wing2.user_info;

      if (wing_count == 1){
        user_photos = <div>
          <a href={leadInfo.large_profile_picture} className={leadClass}>
            <img src={leadInfo.normal_profile_picture} width='100%' />
          </a>

          {leadInfo.photos.map(function(photo, index) {
            return <a href={photo} className={leadClass} key={'lead-photos' + lead.slug + '-' + index}></a>;
          })}
          <a href={wing1Info.large_profile_picture} className={leadClass}>
            <img src={wing1Info.small_profile_picture} width='100%' />
          </a>

        </div>
      }else{
        user_photos = <div>
          <a href={leadInfo.large_profile_picture} className={leadClass}>
            <img src={leadInfo.normal_profile_picture} width='100%' />
          </a>

          {leadInfo.photos.map(function(photo, index) {
            return <a href={photo} className={leadClass} key={'lead-photos' + lead.slug + '-' + index}></a>;
          })}
          <a href={wing1Info.large_profile_picture} className={leadClass}>
            <img src={wing1Info.small_profile_picture} width='50%' className='pull-left' />
          </a>
          <a href={wing2Info.large_profile_picture} className={leadClass}>
            <img src={wing2Info.small_profile_picture} width='50%' className='pull-right' />
          </a>
        </div>
      }

      return (
        user_photos
      );
    }
  });

  return component;
});
