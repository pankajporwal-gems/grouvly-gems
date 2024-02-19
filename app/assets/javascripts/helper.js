modulejs.define('helper', ['jquery'], function($) {
  var addColorbox = function() {
    var arr = [];

    $('.media [class*=user-]').each(function() {
      var userClass = $(this).attr('class').split(' ')[1];

      if (!~$.inArray(userClass, arr)) {
        arr.push(userClass);
        $('.' + userClass).colorbox({ rel: userClass });
      }
    });
  };

  return { addColorbox: addColorbox };
});
