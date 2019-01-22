/**
 * Image Tag
 * Depends on 'tags/htmltag', 'cloudinary'
 */
var ImageTag;

import HtmlTag from './htmltag';

import url from '../url';

export default ImageTag = class ImageTag extends HtmlTag {
  /**
   * Creates an HTML (DOM) Image tag using Cloudinary as the source.
   * @constructor ImageTag
   * @extends HtmlTag
   * @param {string} [publicId]
   * @param {Object} [options]
   */
  constructor(publicId, options = {}) {
    super("img", publicId, options);
  }

  /** @override */
  closeTag() {
    return "";
  }

  /** @override */
  attributes() {
    var attr, options, srcAttribute;
    attr = super.attributes() || [];
    options = this.getOptions();
    srcAttribute = options.responsive && !options.client_hints ? 'data-src' : 'src';
    if (attr[srcAttribute] == null) {
      attr[srcAttribute] = url(this.publicId, this.getOptions());
    }
    return attr;
  }

};
