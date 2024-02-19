modulejs.define('poolActions', ['api', 'poolConstants'], function(Api, PoolConstants) {
  var API_URL = '/admin/pools/';

  return {
    fetchPossibleMatches: function(slug) {
      var url = API_URL + slug + '/possible_matches';
      var key = PoolConstants.POOL_POSSIBLE_MATCHES_FETCH;
      var api = new Api(url, null, key);
      api.get();
    },

    fetchedOtherReservations: function(reservations) {
      var key = PoolConstants.POOL_FETCHED_OTHER_RESERVATIONS;
      var api = new Api(null, reservations, key);
      api.post();
    },

    fetchedOtherPossibleMatches: function(reservations) {
      var key = PoolConstants.POOL_FETCHED_OTHER_POSSIBLE_MATCHES;
      var api = new Api(null, reservations, key);
      api.post();
    }
  };
});

function arrayIds(){
  var serializedArray = $("input:checked").serializeArray();
  var itemIdsArray = _.map(serializedArray, function(item){
    return item["value"];
  });
  return itemIdsArray;
}


function acceptUser(){
  var ids = arrayIds();
  $.ajax({
    type: "GET",
    url: "/admin/applicants/accept_selected",
    data: {user_ids: ids},
    success:function() {
      location.reload();
    }
  });
}

function rejectUser(){
  var r = confirm("Are you sure?");
  if (r == true) {
    var ids = arrayIds();
    $.ajax({
      type: "GET",
      url: "/admin/applicants/reject_selected",
      data: {user_ids: ids},
      success:function(){
        location.reload();
      }
    });
  }
}

function grouvlyBooking(record){
  var user_id = record.attr("data-id");
  var schedule = $("#reservation_schedule_"+user_id).val();
  $("#user_id").val(user_id);
  $("#schedule").val(schedule);
  if(record.val()){
    $("#grouvly_booking_btn_"+user_id).removeClass('disabled');
  }
  else {
    $("#grouvly_booking_btn_"+user_id).addClass('disabled');
  }
}

function onChange(e){
  if($("#available_date").val()){
    $(".confirm-move-to").removeClass('disabled');
  }
  else {
    $(".confirm-move-to").addClass('disabled');
  }
}

function fbMessage(){
  var url = $("#referral-url").attr('href');
  FB.ui({
    method: 'send',
    link: url,
  });
}

function getReservationIds(){
  var ids = arrayIds();
  $("#move_reservaton_ids").val(ids);
}

