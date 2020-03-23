import getHeadersFromURL from "../../xhr/getHeadersFromURL";

/**
 * @param videoURL {string} a full URL for a video asset in cloudinary
 * @param {number} max_timeout_ms - Time to elapse before promise is rejected
 * @return {Promise<boolean>} - Whether the videoURL has built in transparency, or is "two videos" with alpha channel
 */
function checkSupportForTransparency(videoURL, max_timeout_ms) {
  return new Promise((resolve, reject) => {
    return getHeadersFromURL(videoURL, max_timeout_ms).then(({payload}) => {
      let isNativeTransparent = !payload.hasOwnProperty('X-Cld-Vmuxed-Alpha');
      resolve(isNativeTransparent);
    }).catch((err) => {
      reject(err);
    });
  });
}

export default checkSupportForTransparency;
