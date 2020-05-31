import getHeadersFromURL from "../../xhr/getHeadersFromURL";

/**
 * @param videoURL {string} a full URL for a video asset in cloudinary
 * @param {number} max_timeout_ms - Time to elapse before promise is rejected
 * @return {Promise<boolean>} - Whether the videoURL has built in transparency, or is "two videos" with alpha channel
 */
function checkSupportForTransparency(videoURL, max_timeout_ms) {
  return new Promise((resolve, reject) => {
    return getHeadersFromURL(videoURL, max_timeout_ms).then(({payload}) => {
      const serverTiming = payload['server-timing'];

      if (!serverTiming) {
        resolve(true); // we don't know what to do, we assume native transparency
      }

      // if this exact match exists, the video has an additional alpha-layer appended to it
      const includesSeparateAlphaChannel = serverTiming.indexOf('vmux-alpha=?1') >= 0;
      // if this additional layer exists, the video does not have transparency encoded within it
      const isNativeTransparent = !includesSeparateAlphaChannel;

      resolve(isNativeTransparent);
    }).catch((err) => {
      reject(err);
    });
  });
}

export default checkSupportForTransparency;
