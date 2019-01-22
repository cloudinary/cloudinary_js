/**
 * Image Tag
 * Depends on 'tags/htmltag', 'cloudinary'
 */
var ClientHintsMetaTag;

import HtmlTag from './htmltag';

import {
  assign
} from '../util';

export default ClientHintsMetaTag = class ClientHintsMetaTag extends HtmlTag {
  /**
   * Creates an HTML (DOM) Meta tag that enables client-hints.
   * @constructor ClientHintsMetaTag
   * @extends HtmlTag
   */
  constructor(options) {
    super('meta', void 0, assign({
      "http-equiv": "Accept-CH",
      content: "DPR, Viewport-Width, Width"
    }, options));
  }

  /** @override */
  closeTag() {
    return "";
  }

};
