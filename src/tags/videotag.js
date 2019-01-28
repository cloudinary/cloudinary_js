/**
 * Video Tag
 * Depends on 'tags/htmltag', 'util', 'cloudinary'
 */

import {
  DEFAULT_VIDEO_PARAMS,
  DEFAULT_IMAGE_PARAMS
} from '../constants';

import url from '../url';

import {
  defaults,
  isPlainObject,
  contains,
  isArray
} from '../util';

import HtmlTag from './htmltag';


const VIDEO_TAG_PARAMS = ['source_types', 'source_transformation', 'fallback_content', 'poster'];

const DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv'];

const DEFAULT_POSTER_OPTIONS = {
  format: 'jpg',
  resource_type: 'video'
};

const VideoTag = class VideoTag extends HtmlTag {
  /**
   * Creates an HTML (DOM) Video tag using Cloudinary as the source.
   * @constructor VideoTag
   * @extends HtmlTag
   * @param {string} [publicId]
   * @param {Object} [options]
   */
  constructor(publicId, options = {}) {
    options = defaults({}, options, DEFAULT_VIDEO_PARAMS);
    super("video", publicId.replace(/\.(mp4|ogv|webm)$/, ''), options);
  }

  /**
   * Set the transformation to apply on each source
   * @function VideoTag#setSourceTransformation
   * @param {Object} an object with pairs of source type and source transformation
   * @returns {VideoTag} Returns this instance for chaining purposes.
   */
  setSourceTransformation(value) {
    this.transformation().sourceTransformation(value);
    return this;
  }

  /**
   * Set the source types to include in the video tag
   * @function VideoTag#setSourceTypes
   * @param {Array<string>} an array of source types
   * @returns {VideoTag} Returns this instance for chaining purposes.
   */
  setSourceTypes(value) {
    this.transformation().sourceTypes(value);
    return this;
  }

  /**
   * Set the poster to be used in the video tag
   * @function VideoTag#setPoster
   * @param {string|Object} value
   * - string: a URL to use for the poster
   * - Object: transformation parameters to apply to the poster. May optionally include a public_id to use instead of the video public_id.
   * @returns {VideoTag} Returns this instance for chaining purposes.
   */
  setPoster(value) {
    this.transformation().poster(value);
    return this;
  }

  /**
   * Set the content to use as fallback in the video tag
   * @function VideoTag#setFallbackContent
   * @param {string} value - the content to use, in HTML format
   * @returns {VideoTag} Returns this instance for chaining purposes.
   */
  setFallbackContent(value) {
    this.transformation().fallbackContent(value);
    return this;
  }

  content() {
    var fallback, innerTags, type, sourceTransformation, sourceTypes, src, srcType, transformation, videoType;
    sourceTypes = this.transformation().getValue('source_types');
    sourceTransformation = this.transformation().getValue('source_transformation');
    fallback = this.transformation().getValue('fallback_content');
    if (isArray(sourceTypes)) {
      let options = this.getOptions();
      innerTags = (function () {
        var i, len, results;
        results = [];
        for (i = 0, len = sourceTypes.length; i < len; i++) {
          srcType = sourceTypes[i];
          transformation = sourceTransformation[srcType] || {};
          src = url(`${this.publicId}`, defaults({}, transformation, {
            resource_type: 'video',
            format: srcType
          }, options));
          videoType = srcType === 'ogv' ? 'ogg' : srcType;
          type = 'video/' + videoType;
          results.push(`<source ${this.htmlAttrs({src, type})}>`);
        }
        return results;
      }).call(this);
    } else {
      innerTags = [];
    }
    return innerTags.join('') + fallback;
  }

  attributes() {
    var a, attr, defaultOptions, i, len, poster, ref, ref1, sourceTypes;
    sourceTypes = this.getOption('source_types');
    poster = (ref = this.getOption('poster')) != null ? ref : {};
    if (isPlainObject(poster)) {
      defaultOptions = poster.public_id != null ? DEFAULT_IMAGE_PARAMS : DEFAULT_POSTER_OPTIONS;
      poster = url((ref1 = poster.public_id) != null ? ref1 : this.publicId, defaults({}, poster, defaultOptions, this.getOptions()));
    }
    attr = super.attributes() || [];
    for (i = 0, len = attr.length; i < len; i++) {
      a = attr[i];
      if (!contains(VIDEO_TAG_PARAMS)) {
        attr = a;
      }
    }
    if (!isArray(sourceTypes)) {
      attr["src"] = url(this.publicId, this.getOptions(), {
        resource_type: 'video',
        format: sourceTypes
      });
    }
    if (poster != null) {
      attr["poster"] = poster;
    }
    return attr;
  }

};

export default VideoTag;
