import encodeVersion from "./encodeVersion.js";

/**
 * @description Gets the SDK signature by encoding the SDK version and tech version
 * @param analyticsOptions
 * @return {string} encodedSDK sdkVersionID
 */
export default function getSDKVersionID(analyticsOptions={}) {
  try {
    let twoPartVersion = removePatchFromSemver(analyticsOptions.techVersion);
    let encodedSDKVersion = encodeVersion(analyticsOptions.sdkSemver);
    let encodedTechVersion = encodeVersion(twoPartVersion);
    let featureCode = analyticsOptions.feature;
    let SDKCode = analyticsOptions.sdkCode;

    return `${SDKCode}${encodedSDKVersion}${encodedTechVersion}${featureCode}`;

  } catch (e) {
    // Either SDK or Node versions were unparsable
    return 'E';
  }
}

/**
 * @description Removes patch version from the semver if it exists
 *              Turns x.y.z OR x.y into x.y
 * @param {'x.y.z' || 'x.y' || string} semVerStr
 */
function removePatchFromSemver(semVerStr) {
  let parts = semVerStr.split('.');

  return `${parts[0]}.${parts[1]}`;
}
