modulejs.define('api', ['jquery', 'appDispatcher', 'apiConstants'], function($, AppDispatcher, ApiConstants) {
  var PENDING_KEY = ApiConstants.API_PENDING;
  var TIMEOUT = 10000;

  var _pendingRequests = {};

  function abortPendingRequests(key) {
    if (_pendingRequests[key]) {
      _pendingRequests[key].abort();
      _pendingRequests[key] = null;
    }
  }

  function dispatch(key, params) {
    AppDispatcher.dispatch({
      actionType: key,
      values: params
    });
  }

  function processRequest(data, textStatus, key) {
    var val;

    if (textStatus == 'timeout') {
      return dispatch(ApiConstants.API_TIMEOUT, data);
    } else if (textStatus == 'error') {
      return dispatch(ApiConstants.API_ERROR, data);
    } else if (textStatus == 'success') {
      return dispatch(key, data);
    }
  }

  function ajaxCall(requestType, url, params, key) {
    return (
      $.ajax({
        type: requestType,
        url: url,
        data: params,
        dataType: 'json',
        timeout: TIMEOUT
      }).always(function(data, textStatus) {
        processRequest(data, textStatus, key);
      })
    );
  }

  function get(url, params, key) { return ajaxCall('GET', url, params, key); }

  function post(url, params, key) {
    if (url) {
      return ajaxCall('POST', url, params, key);
    } else {
      processRequest(params, 'success', key);
    }
  }

  var Api = function(apiUrl, params, key) {
    abortPendingRequests(key);

    this.get = function() { _pendingRequests[key] = get(apiUrl, params, key); };

    this.post = function() { _pendingRequests[key] = post(apiUrl, params, key); };
  };

  return Api;
});
