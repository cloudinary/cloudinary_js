/**
 * @description Converts a URL to a BLOB URL
 * @param {string} urlToLoad
 * @return {Promise<{
 *   status: 'success' | 'error'
 *   message?: string,
 *    payload: {
 *      url: string
 *    }
 * }>}
 */
function getBlobFromURL(urlToLoad, maxTimeout) {
  return new Promise((resolve, reject) => {
    let timerID = setTimeout(() => {
      reject({
        status: 'error',
        message: 'Timeout loading Blob URL'
      });
    }, maxTimeout);

    let xhr = new XMLHttpRequest();
    xhr.responseType = 'blob';
    xhr.onload = function (response) {
      clearTimeout(timerID); // clear timeout reject error
      resolve({
        status: 'success',
        payload: {
          url: URL.createObjectURL(xhr.response)
        }
      });
    };

    xhr.onerror = function () {
      clearTimeout(timerID); // clear timeout reject error
      reject({
        status: 'error',
        message: 'Error loading Blob URL'
      });
    };
    xhr.open('GET', urlToLoad, true);
    xhr.send();
  });
}

export default getBlobFromURL;
