var applyBreakpoints, closestAbove, defaultBreakpoints, findContainerWidth, maxWidth, updateDpr;

import Configuration from './configuration';
import HtmlTag from './tags/htmltag';
import ImageTag from './tags/imagetag';
import PictureTag from './tags/picturetag';
import SourceTag from './tags/sourcetag';
import Transformation from './transformation';
import url from './url';
import VideoTag from './tags/videotag';
import * as constants from './constants';

import {
  addClass,
  assign,
  defaults,
  getData,
  isArray,
  isEmpty,
  isFunction,
  isString,
  merge,
  removeAttribute,
  setAttribute,
  setData,
  width
} from './util';

defaultBreakpoints = function(width, steps = 100) {
  return steps * Math.ceil(width / steps);
};

closestAbove = function(list, value) {
  var i;
  i = list.length - 2;
  while (i >= 0 && list[i] >= value) {
    i--;
  }
  return list[i + 1];
};

applyBreakpoints = function(tag, width, steps, options) {
  var ref, ref1, ref2, responsive_use_breakpoints;
  responsive_use_breakpoints = (ref = (ref1 = (ref2 = options['responsive_use_breakpoints']) != null ? ref2 : options['responsive_use_stoppoints']) != null ? ref1 : this.config('responsive_use_breakpoints')) != null ? ref : this.config('responsive_use_stoppoints');
  if ((!responsive_use_breakpoints) || (responsive_use_breakpoints === 'resize' && !options.resizing)) {
    return width;
  } else {
    return this.calc_breakpoint(tag, width, steps);
  }
};

findContainerWidth = function(element) {
  var containerWidth, style;
  containerWidth = 0;
  while (((element = element != null ? element.parentNode : void 0) instanceof Element) && !containerWidth) {
    style = window.getComputedStyle(element);
    if (!/^inline/.test(style.display)) {
      containerWidth = width(element);
    }
  }
  return containerWidth;
};

updateDpr = function(dataSrc, roundDpr) {
  return dataSrc.replace(/\bdpr_(1\.0|auto)\b/g, 'dpr_' + this.device_pixel_ratio(roundDpr));
};

maxWidth = function(requiredWidth, tag) {
  var imageWidth;
  imageWidth = getData(tag, 'width') || 0;
  if (requiredWidth > imageWidth) {
    imageWidth = requiredWidth;
    setData(tag, 'width', requiredWidth);
  }
  return imageWidth;
};

var Cloudinary = class Cloudinary {
  /**
   * Main Cloudinary class
   * @class Cloudinary
   * @param {Object} options - options to configure Cloudinary
   * @see Configuration for more details
   * @example
   *    var cl = new cloudinary.Cloudinary( { cloud_name: "mycloud"});
   *    var imgTag = cl.image("myPicID");
   */
  constructor(options) {
    var configuration;
    this.devicePixelRatioCache = {};
    this.responsiveConfig = {};
    this.responsiveResizeInitialized = false;
    configuration = new Configuration(options);
    // Provided for backward compatibility
    this.config = function(newConfig, newValue) {
      return configuration.config(newConfig, newValue);
    };
    /**
     * Use \<meta\> tags in the document to configure this Cloudinary instance.
     * @return {Cloudinary} this for chaining
     */
    this.fromDocument = function() {
      configuration.fromDocument();
      return this;
    };
    /**
     * Use environment variables to configure this Cloudinary instance.
     * @return {Cloudinary} this for chaining
     */
    this.fromEnvironment = function() {
      configuration.fromEnvironment();
      return this;
    };
    /**
     * Initialize configuration.
     * @function Cloudinary#init
     * @see Configuration#init
     * @return {Cloudinary} this for chaining
     */
    this.init = function() {
      configuration.init();
      return this;
    };
  }

  /**
   * Convenience constructor
   * @param {Object} options
   * @return {Cloudinary}
   * @example cl = cloudinary.Cloudinary.new( { cloud_name: "mycloud"})
   */
  static new(options) {
    return new this(options);
  }

  /**
   * Generate an resource URL.
   * @function Cloudinary#url
   * @param {string} publicId - the public ID of the resource
   * @param {Object} [options] - options for the tag and transformations, possible values include all {@link Transformation} parameters
   *                          and {@link Configuration} parameters
   * @param {string} [options.type='upload'] - the classification of the resource
   * @param {Object} [options.resource_type='image'] - the type of the resource
   * @return {string} The resource URL
   */
  url(publicId, options = {}) {
    return url(publicId, options, this.config());
  }

  /**
   * Generate an video resource URL.
   * @function Cloudinary#video_url
   * @param {string} publicId - the public ID of the resource
   * @param {Object} [options] - options for the tag and transformations, possible values include all {@link Transformation} parameters
   *                          and {@link Configuration} parameters
   * @param {string} [options.type='upload'] - the classification of the resource
   * @return {string} The video URL
   */
  video_url(publicId, options) {
    options = assign({
      resource_type: 'video'
    }, options);
    return this.url(publicId, options);
  }

  /**
   * Generate an video thumbnail URL.
   * @function Cloudinary#video_thumbnail_url
   * @param {string} publicId - the public ID of the resource
   * @param {Object} [options] - options for the tag and transformations, possible values include all {@link Transformation} parameters
   *                          and {@link Configuration} parameters
   * @param {string} [options.type='upload'] - the classification of the resource
   * @return {string} The video thumbnail URL
   */
  video_thumbnail_url(publicId, options) {
    options = assign({}, constants.DEFAULT_POSTER_OPTIONS, options);
    return this.url(publicId, options);
  }

  /**
   * Generate a string representation of the provided transformation options.
   * @function Cloudinary#transformation_string
   * @param {Object} options - the transformation options
   * @returns {string} The transformation string
   */
  transformation_string(options) {
    return new Transformation(options).serialize();
  }

  /**
   * Generate an image tag.
   * @function Cloudinary#image
   * @param {string} publicId - the public ID of the image
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} an image tag element
   */
  image(publicId, options = {}) {
    var client_hints, img, ref, ref1;
    img = this.imageTag(publicId, options);
    client_hints = (ref = (ref1 = options.client_hints) != null ? ref1 : this.config('client_hints')) != null ? ref : false;
    if (!((options.src != null) || client_hints)) {
      // src must be removed before creating the DOM element to avoid loading the image
      img.setAttr("src", '');
    }
    img = img.toDOM();
    if (!client_hints) {
      // cache the image src
      setData(img, 'src-cache', this.url(publicId, options));
      // set image src taking responsiveness in account
      this.cloudinary_update(img, options);
    }
    return img;
  }

  /**
   * Creates a new ImageTag instance, configured using this own's configuration.
   * @function Cloudinary#imageTag
   * @param {string} publicId - the public ID of the resource
   * @param {Object} options - additional options to pass to the new ImageTag instance
   * @return {ImageTag} An ImageTag that is attached (chained) to this Cloudinary instance
   */
  imageTag(publicId, options) {
    var tag;
    tag = new ImageTag(publicId, this.config());
    tag.transformation().fromOptions(options);
    return tag;
  }

  /**
   * Creates a new PictureTag instance, configured using this own's configuration.
   * @function Cloudinary#PictureTag
   * @param {string} publicId - the public ID of the resource
   * @param {Object} options - additional options to pass to the new ImageTag instance
   * @return {PictureTag} An PictureTag that is attached (chained) to this Cloudinary instance
   */
  pictureTag(publicId, options) {
    var tag;
    tag = new PictureTag(publicId, this.config());
    tag.transformation().fromOptions(options);
    return tag;
  }

  /**
   * Creates a new SourceTag instance, configured using this own's configuration.
   * @function Cloudinary#SourceTag
   * @param {string} publicId - the public ID of the resource
   * @param {Object} options - additional options to pass to the new ImageTag instance
   * @return {SourceTag} An PictureTag that is attached (chained) to this Cloudinary instance
   */
  sourceTag(publicId, options) {
    var tag;
    tag = new SourceTag(publicId, this.config());
    tag.transformation().fromOptions(options);
    return tag;
  }

  /**
   * Generate an image tag for the video thumbnail.
   * @function Cloudinary#video_thumbnail
   * @param {string} publicId - the public ID of the video
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} An image tag element
   */
  video_thumbnail(publicId, options) {
    return this.image(publicId, merge({}, constants.DEFAULT_POSTER_OPTIONS, options));
  }

  /**
   * @function Cloudinary#facebook_profile_image
   * @param {string} publicId - the public ID of the image
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} an image tag element
   */
  facebook_profile_image(publicId, options) {
    return this.image(publicId, assign({
      type: 'facebook'
    }, options));
  }

  /**
   * @function Cloudinary#twitter_profile_image
   * @param {string} publicId - the public ID of the image
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} an image tag element
   */
  twitter_profile_image(publicId, options) {
    return this.image(publicId, assign({
      type: 'twitter'
    }, options));
  }

  /**
   * @function Cloudinary#twitter_name_profile_image
   * @param {string} publicId - the public ID of the image
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} an image tag element
   */
  twitter_name_profile_image(publicId, options) {
    return this.image(publicId, assign({
      type: 'twitter_name'
    }, options));
  }

  /**
   * @function Cloudinary#gravatar_image
   * @param {string} publicId - the public ID of the image
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} an image tag element
   */
  gravatar_image(publicId, options) {
    return this.image(publicId, assign({
      type: 'gravatar'
    }, options));
  }

  /**
   * @function Cloudinary#fetch_image
   * @param {string} publicId - the public ID of the image
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} an image tag element
   */
  fetch_image(publicId, options) {
    return this.image(publicId, assign({
      type: 'fetch'
    }, options));
  }

  /**
   * @function Cloudinary#video
   * @param {string} publicId - the public ID of the image
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} an image tag element
   */
  video(publicId, options = {}) {
    return this.videoTag(publicId, options).toHtml();
  }

  /**
   * Creates a new VideoTag instance, configured using this own's configuration.
   * @function Cloudinary#videoTag
   * @param {string} publicId - the public ID of the resource
   * @param {Object} options - additional options to pass to the new VideoTag instance
   * @return {VideoTag} A VideoTag that is attached (chained) to this Cloudinary instance
   */
  videoTag(publicId, options) {
    options = defaults({}, options, this.config());
    return new VideoTag(publicId, options);
  }

  /**
   * Generate the URL of the sprite image
   * @function Cloudinary#sprite_css
   * @param {string} publicId - the public ID of the resource
   * @param {Object} [options] - options for the tag and transformations
   * @see {@link http://cloudinary.com/documentation/sprite_generation Sprite generation}
   */
  sprite_css(publicId, options) {
    options = assign({
      type: 'sprite'
    }, options);
    if (!publicId.match(/.css$/)) {
      options.format = 'css';
    }
    return this.url(publicId, options);
  }

  /**
  * Initialize the responsive behaviour.<br>
  * Calls {@link Cloudinary#cloudinary_update} to modify image tags.
   * @function Cloudinary#responsive
  * @param {Object} options
  * @param {String} [options.responsive_class='cld-responsive'] - provide an alternative class used to locate img tags
  * @param {number} [options.responsive_debounce=100] - the debounce interval in milliseconds.
  * @param {boolean} [bootstrap=true] if true processes the img tags by calling cloudinary_update. When false the tags will be processed only after a resize event.
  * @see {@link Cloudinary#cloudinary_update} for additional configuration parameters
   */
  responsive(options, bootstrap = true) {
    var ref, ref1, ref2, responsiveClass, responsiveResize, timeout;
    this.responsiveConfig = merge(this.responsiveConfig || {}, options);
    responsiveClass = (ref = this.responsiveConfig['responsive_class']) != null ? ref : this.config('responsive_class');
    if (bootstrap) {
      this.cloudinary_update(`img.${responsiveClass}, img.cld-hidpi`, this.responsiveConfig);
    }
    responsiveResize = (ref1 = (ref2 = this.responsiveConfig['responsive_resize']) != null ? ref2 : this.config('responsive_resize')) != null ? ref1 : true;
    if (responsiveResize && !this.responsiveResizeInitialized) {
      this.responsiveConfig.resizing = this.responsiveResizeInitialized = true;
      timeout = null;
      return window.addEventListener('resize', () => {
        var debounce, ref3, ref4, reset, run, wait, waitFunc;
        debounce = (ref3 = (ref4 = this.responsiveConfig['responsive_debounce']) != null ? ref4 : this.config('responsive_debounce')) != null ? ref3 : 100;
        reset = function() {
          if (timeout) {
            clearTimeout(timeout);
            return timeout = null;
          }
        };
        run = () => {
          return this.cloudinary_update(`img.${responsiveClass}`, this.responsiveConfig);
        };
        waitFunc = function() {
          reset();
          return run();
        };
        wait = function() {
          reset();
          return timeout = setTimeout(waitFunc, debounce);
        };
        if (debounce) {
          return wait();
        } else {
          return run();
        }
      });
    }
  }

  /**
   * @function Cloudinary#calc_breakpoint
   * @private
   * @ignore
   */
  calc_breakpoint(element, width, steps) {
    let breakpoints = getData(element, 'breakpoints') || getData(element, 'stoppoints') || this.config('breakpoints') || this.config('stoppoints') || defaultBreakpoints;
    if (isFunction(breakpoints)) {
      return breakpoints(width, steps);
    } else {
      if (isString(breakpoints)) {
        breakpoints = breakpoints.split(',').map(point=>parseInt(point)).sort((a, b) => a - b);
      }
      return closestAbove(breakpoints, width);
    }
  }

  /**
   * @function Cloudinary#calc_stoppoint
   * @deprecated Use {@link calc_breakpoint} instead.
   * @private
   * @ignore
   */
  calc_stoppoint(element, width, steps) {
    return this.calc_breakpoint(element, width, steps);
  }

  /**
   * @function Cloudinary#device_pixel_ratio
   * @private
   */
  device_pixel_ratio(roundDpr = true) {
    var dpr, dprString;
    dpr = (typeof window !== "undefined" && window !== null ? window.devicePixelRatio : void 0) || 1;
    if (roundDpr) {
      dpr = Math.ceil(dpr);
    }
    if (dpr <= 0 || dpr === (0/0)) {
      dpr = 1;
    }
    dprString = dpr.toString();
    if (dprString.match(/^\d+$/)) {
      dprString += '.0';
    }
    return dprString;
  }

  /**
  * Finds all `img` tags under each node and sets it up to provide the image through Cloudinary
  * @param {Element[]} nodes the parent nodes to search for img under
  * @param {Object} [options={}] options and transformations params
  * @function Cloudinary#processImageTags
   */
  processImageTags(nodes, options = {}) {
    var images, imgOptions, node, publicId;
    if (isEmpty(nodes)) {
      // similar to `$.fn.cloudinary`
      return this;
    }
    options = defaults({}, options, this.config());
    images = (function() {
      var j, len, ref, results;
      results = [];
      for (j = 0, len = nodes.length; j < len; j++) {
        node = nodes[j];
        if (!(((ref = node.tagName) != null ? ref.toUpperCase() : void 0) === 'IMG')) {
          continue;
        }
        imgOptions = assign({
          width: node.getAttribute('width'),
          height: node.getAttribute('height'),
          src: node.getAttribute('src')
        }, options);
        publicId = imgOptions['source'] || imgOptions['src'];
        delete imgOptions['source'];
        delete imgOptions['src'];
        url = this.url(publicId, imgOptions);
        imgOptions = new Transformation(imgOptions).toHtmlAttributes();
        setData(node, 'src-cache', url);
        node.setAttribute('width', imgOptions.width);
        node.setAttribute('height', imgOptions.height);
        results.push(node);
      }
      return results;
    }).call(this);
    this.cloudinary_update(images, options);
    return this;
  }

  /**
  * Update hidpi (dpr_auto) and responsive (w_auto) fields according to the current container size and the device pixel ratio.
  * Only images marked with the cld-responsive class have w_auto updated.
  * @function Cloudinary#cloudinary_update
  * @param {(Array|string|NodeList)} elements - the elements to modify
  * @param {Object} options
  * @param {boolean|string} [options.responsive_use_breakpoints=true]
  *  - when `true`, always use breakpoints for width
  * - when `"resize"` use exact width on first render and breakpoints on resize
  * - when `false` always use exact width
  * @param {boolean} [options.responsive] - if `true`, enable responsive on this element. Can be done by adding cld-responsive.
  * @param {boolean} [options.responsive_preserve_height] - if set to true, original css height is preserved.
  *   Should only be used if the transformation supports different aspect ratios.
   */
  cloudinary_update(elements, options = {}) {
    var containerWidth, dataSrc, j, len, match, ref, ref1, ref2, ref3, ref4, ref5, requiredWidth, responsive, responsiveClass, roundDpr, setUrl, tag;
    if (elements === null) {
      return this;
    }
    responsive = (ref = (ref1 = options.responsive) != null ? ref1 : this.config('responsive')) != null ? ref : false;
    elements = (function() {
      switch (false) {
        case !isArray(elements):
          return elements;
        case elements.constructor.name !== "NodeList":
          return elements;
        case !isString(elements):
          return document.querySelectorAll(elements);
        default:
          return [elements];
      }
    })();
    responsiveClass = (ref2 = (ref3 = this.responsiveConfig['responsive_class']) != null ? ref3 : options['responsive_class']) != null ? ref2 : this.config('responsive_class');
    roundDpr = (ref4 = options['round_dpr']) != null ? ref4 : this.config('round_dpr');
    for (j = 0, len = elements.length; j < len; j++) {
      tag = elements[j];
      if (!((ref5 = tag.tagName) != null ? ref5.match(/img/i) : void 0)) {
        continue;
      }
      setUrl = true;
      if (responsive) {
        addClass(tag, responsiveClass);
      }
      dataSrc = getData(tag, 'src-cache') || getData(tag, 'src');
      if (!isEmpty(dataSrc)) {
        // Update dpr according to the device's devicePixelRatio
        dataSrc = updateDpr.call(this, dataSrc, roundDpr);
        if (HtmlTag.isResponsive(tag, responsiveClass)) {
          containerWidth = findContainerWidth(tag);
          if (containerWidth !== 0) {
            switch (false) {
              case !/w_auto:breakpoints/.test(dataSrc):
                requiredWidth = maxWidth(containerWidth, tag);
                dataSrc = dataSrc.replace(/w_auto:breakpoints([_0-9]*)(:[0-9]+)?/, `w_auto:breakpoints$1:${requiredWidth}`);
                break;
              case !(match = /w_auto(:(\d+))?/.exec(dataSrc)):
                requiredWidth = applyBreakpoints.call(this, tag, containerWidth, match[2], options);
                requiredWidth = maxWidth(requiredWidth, tag);
                dataSrc = dataSrc.replace(/w_auto[^,\/]*/g, `w_${requiredWidth}`);
            }
            removeAttribute(tag, 'width');
            if (!options.responsive_preserve_height) {
              removeAttribute(tag, 'height');
            }
          } else {
            // Container doesn't know the size yet - usually because the image is hidden or outside the DOM.
            setUrl = false;
          }
        }
        if (setUrl) {
          setAttribute(tag, 'src', dataSrc);
        }
      }
    }
    return this;
  }

  /**
   * Provide a transformation object, initialized with own's options, for chaining purposes.
   * @function Cloudinary#transformation
   * @param {Object} options
   * @return {Transformation}
   */
  transformation(options) {
    return Transformation.new(this.config()).fromOptions(options).setParent(this);
  }

};
Object.assign(Cloudinary, constants);
export default Cloudinary;
