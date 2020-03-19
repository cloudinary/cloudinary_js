/**
 * @param {HTMLElement} htmlElContainer
 * @param {Function} createVideoTagFn cloudinary.videoTag fn
 * @param {string} publicId
 * @param {object} options - TransformationOptions
 * @returns void
 */
function mountCloudinaryVideoTag(htmlElContainer, createVideoTagFn, publicId, options) {
  // VideoTag is really aggressive with how it picks arguments and will create <video seethruurl="...">
  let videoTagOptions = Object.assign({}, options);
  delete videoTagOptions.seeThruURL;
  delete videoTagOptions.max_timeout_ms;

  htmlElContainer.innerHTML = createVideoTagFn(publicId, videoTagOptions).toHtml();

  // All videos under the html container must have a width of 100%, or they might overflow from the container
  let element = htmlElContainer.querySelector('.cld-transparent-video');
  element.style.width = '100%';
}

export default mountCloudinaryVideoTag;
