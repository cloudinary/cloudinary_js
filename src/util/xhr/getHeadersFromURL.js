/**
 * @description Returns an object hash of header->value
 * @param {string} url
 * @return {Promise<{
 *   status: 'success' | 'error'
 *   message?: string
 *   payload: object,
 * }>}
 */
function getHeadersFromURL(url, maxTimeout) {
  return new Promise((resolve, reject) => {
    let xhr = new XMLHttpRequest();

    let timeoutID = setErrorHandling(xhr, maxTimeout, reject);

    xhr.onreadystatechange = function () {
      if (this.readyState === this.HEADERS_RECEIVED) {
        // clear the time-out rejection
        clearTimeout(timeoutID); // clear timeout reject error
        // Get the raw header string
        let headers = xhr.getAllResponseHeaders();
        let headerMap = headerStringToMap(headers);

        resolve({
          status: 'success',
          payload: headerMap
        });
      }
    };

    xhr.open('HEAD', url, true);
    xhr.send();
  });
}

/**
 * Convert the Header string to a map of key:value
 * @param {string} headers
 * @return {{}}
 */
function headerStringToMap(headers) {
  // Convert the header string into an array
  // of individual headers
  let arr = headers.trim().split(/[\r\n]+/);

  // Create a map of header names to values
  let headerMap = {};
  arr.forEach(function (line) {
    let parts = line.split(': ');
    let header = parts.shift();
    let value = parts.join(': ');
    headerMap[header] = value;
  });

  return headerMap;
}

/**
 *
 * @param {XMLHttpRequest} xhr
 * @param {number} maxTimeout
 * @param {Function} rejectCb
 * @return {number};
 */
function setErrorHandling(xhr, maxTimeout, rejectCb) {
  let timeoutID = setTimeout(() => {
    rejectCb({
      status: 'error',
      message: 'Timeout reading headers from server'
    });
  }, maxTimeout);

  xhr.onerror = function () {
    clearTimeout(timeoutID); // clear timeout reject error
    rejectCb({
      status: 'error',
      message: 'Error reading headers from server'
    });
  };

  return timeoutID;
}


export default getHeadersFromURL;
