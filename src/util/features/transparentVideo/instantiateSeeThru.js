/**
 * @param {HTMLVideoElement} videoElement
 * @param {number} max_timeout_ms
 * @param {string} customClass
 * @param {boolean} autoPlay
 * @return {Promise<any>} SeeThru instance or rejection error
 */
function instantiateSeeThru(videoElement, max_timeout_ms, customClass, autoPlay) {
  let {seeThru, setTimeout, clearTimeout} = window;

  return new Promise((resolve, reject) => {
    let timerID = setTimeout(() => {
      reject({status: 'error', message: 'Timeout instantiating seeThru instance'});
    }, max_timeout_ms);

    if (seeThru) {
      let seeThruInstance = seeThru.create(videoElement).ready(() => {
        clearTimeout(timerID); // clear timeout reject error
        let canvasElement = seeThruInstance.getCanvas();
        // force container size, else the canvas can overflow out
        canvasElement.style.width = '100%';
        canvasElement.className += ' ' + customClass;
        if (autoPlay) {
          seeThruInstance.play();
        }
        resolve(seeThruInstance);
      });
    } else {
      reject({status: 'error', message: 'Error instantiating seeThru instance'});
    }
  });
}

export default instantiateSeeThru;
