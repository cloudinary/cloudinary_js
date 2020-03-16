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

    xhr.onreadystatechange = function () {
      if (this.readyState === this.HEADERS_RECEIVED) {
        // clear the time-out rejection
        clearTimeout(timerID); // clear timeout reject error
        // Get the raw header string
        let headers = xhr.getAllResponseHeaders();

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

        resolve({
          status: 'success',
          payload: headerMap
        });
      }
    };

    let timerID = setTimeout(() => {
      reject({
        status: 'error',
        message: 'Timeout reading headers from server'
      });
    }, maxTimeout);

    xhr.onerror = function () {
      clearTimeout(timerID); // clear timeout reject error
      reject({
        status: 'error',
        message: 'Error reading headers from server'
      });
    };
    xhr.open('HEAD', url, true);
    xhr.send();
  });
}


export default getHeadersFromURL;
