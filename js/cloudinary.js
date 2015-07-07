/*
 * Cloudinary's jQuery library - v1.0.24
 * Copyright Cloudinary
 * see https://github.com/cloudinary/cloudinary_js
 */

(function (factory) {
    'use strict';
    if (typeof define === 'function' && define.amd) {
        // Register as an anonymous AMD module:
        define([
            'lodash'
        ], factory);
    } else {
        // Browser globals:
        factory(_);
    }
}(function (_) {
;

/*
  Main Cloudinary class

  Backward compatibility:
  Must provide public keys
   * CF_SHARED_CDN
   * OLD_AKAMAI_SHARED_CDN
   * AKAMAI_SHARED_CDN
   * SHARED_CDN
   * config
   * url
   * video_url
   * video_thumbnail_url
   * transformation_string
   * image
   * video_thumbnail
   * facebook_profile_image
   * twitter_profile_image
   * twitter_name_profile_image
   * gravatar_image
   * fetch_image
   * video
   * sprite_css
   * responsive
   * calc_stoppoint
   * device_pixel_ratio
   * supported_dpr_values
 */
var ArrayParam, Cloudinary, CloudinaryConfiguration, HtmlTag, ImageTag, Param, RangeParam, RawParam, Transformation, TransformationBase, TransformationParam, VideoTag, cloudinary_config, config, crc32, exports, process_video_params, transformationParams, utf8_encode,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Cloudinary = (function() {
  var AKAMAI_SHARED_CDN, CF_SHARED_CDN, DEFAULT_IMAGE_PARAMS, DEFAULT_POSTER_OPTIONS, DEFAULT_VIDEO_PARAMS, DEFAULT_VIDEO_SOURCE_TYPES, OLD_AKAMAI_SHARED_CDN, SHARED_CDN, absolutize, cdn_subdomain_number, closest_above, cloudinary_url, cloudinary_url_prefix, default_stoppoints, device_pixel_ratio_cache, finalizeResourceType, html_attrs, join_pair, unsigned_upload_tag;

  CF_SHARED_CDN = "d3jpl91pxevbkh.cloudfront.net";

  OLD_AKAMAI_SHARED_CDN = "cloudinary-a.akamaihd.net";

  AKAMAI_SHARED_CDN = "res.cloudinary.com";

  SHARED_CDN = AKAMAI_SHARED_CDN;

  DEFAULT_POSTER_OPTIONS = {
    format: 'jpg',
    resource_type: 'video'
  };

  DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv'];

  device_pixel_ratio_cache = {};


  /**
   * Defaults values for parameters.
   *
   * (Previously defined using option_consume() )
   */

  DEFAULT_IMAGE_PARAMS = {
    resource_type: "image",
    transformation: [],
    type: 'upload'
  };


  /**
   * Defaults values for parameters.
   *
   * (Previously defined using option_consume() )
   */

  DEFAULT_VIDEO_PARAMS = {
    fallback_content: '',
    resource_type: "video",
    source_transformation: {},
    source_types: DEFAULT_VIDEO_SOURCE_TYPES,
    transformation: [],
    type: 'upload'
  };


  /**
   * Return the resource type and action type based on the given configuration
   * @param resource_type
   * @param type
   * @param url_suffix
   * @param use_root_path
   * @param shorten
   * @returns {string} resource_type/type
   */

  finalizeResourceType = function(resourceType, type, urlSuffix, useRootPath, shorten) {
    var options;
    if (_.isPlainObject(resourceType)) {
      options = resourceType;
      resourceType = options.resource_type;
      type = options.type;
      urlSuffix = options.url_suffix;
      useRootPath = options.use_root_path;
      shorten = options.shorten;
    }
    if (type == null) {
      type = 'upload';
    }
    if (urlSuffix != null) {
      if (resourceType === 'image' && type === 'upload') {
        resourceType = "images";
        type = null;
      } else if (resourceType === 'raw' && type === 'upload') {
        resourceType = 'files';
        type = null;
      } else {
        throw new Error("URL Suffix only supported for image/upload and raw/upload");
      }
    }
    if (useRootPath) {
      if (resourceType === 'image' && type === 'upload' || resourceType === "images") {
        resourceType = null;
        type = null;
      } else {
        throw new Error("Root path only supported for image/upload");
      }
    }
    if (shorten && resourceType === 'image' && type === 'upload') {
      resourceType = 'iu';
      type = null;
    }
    return [resourceType, type].join("/");
  };

  absolutize = function(url) {
    var prefix;
    if (!url.match(/^https?:\//)) {
      prefix = document.location.protocol + '//' + document.location.host;
      if (url[0] === '?') {
        prefix += document.location.pathname;
      } else if (url[0] !== '/') {
        prefix += document.location.pathname.replace(/\/[^\/]*$/, '/');
      }
      url = prefix + url;
    }
    return url;
  };

  cloudinary_url = function(publicId, options) {
    var prefix, ref, resource_type_and_type, transformation, transformation_string, url, version;
    if (options == null) {
      options = {};
    }
    _.defaults(options, this.configuration.defaults(), DEFAULT_IMAGE_PARAMS);
    if (options.type === 'fetch') {
      options.fetch_format = options.fetch_format || options.format;
      publicId = absolutize(publicId);
    }
    transformation = new Transformation(options);
    transformation_string = transformation.flatten();
    if (!options.cloud_name) {
      throw 'Unknown cloud_name';
    }
    if (options.url_suffix && !options.private_cdn) {
      throw 'URL Suffix only supported in private CDN';
    }
    if (publicId.search('/') >= 0 && !publicId.match(/^v[0-9]+/) && !publicId.match(/^https?:\//) && !((ref = options.version) != null ? ref.toString() : void 0)) {
      options.version = 1;
    }
    if (publicId.match(/^https?:/)) {
      if (options.type === 'upload' || options.type === 'asset') {
        url = publicId;
      } else {
        publicId = encodeURIComponent(publicId).replace(/%3A/g, ':').replace(/%2F/g, '/');
      }
    } else {
      publicId = encodeURIComponent(decodeURIComponent(publicId)).replace(/%3A/g, ':').replace(/%2F/g, '/');
      if (options.url_suffix) {
        if (options.url_suffix.match(/[\.\/]/)) {
          throw 'url_suffix should not include . or /';
        }
        publicId = publicId + '/' + options.url_suffix;
      }
      if (options.format) {
        if (!options.trust_public_id) {
          publicId = publicId.replace(/\.(jpg|png|gif|webp)$/, '');
        }
        publicId = publicId + '.' + options.format;
      }
    }
    prefix = cloudinary_url_prefix(publicId, options);
    resource_type_and_type = finalizeResourceType(options.resource_type, options.type, options.url_suffix, options.use_root_path, options.shorten);
    version = options.version ? 'v' + options.version : '';
    return url || _.filter([prefix, resource_type_and_type, transformation_string, version, publicId], null).join('/').replace(/([^:])\/+/g, '$1/');
  };

  function Cloudinary(options) {
    this.configuration = new CloudinaryConfiguration(options);
  }

  Cloudinary.prototype.config = function(newConfig, newValue) {
    return this.configuration.config(newConfig, newValue);
  };

  Cloudinary.prototype.url = function(publicId, options) {
    options = _.cloneDeep(options);
    return cloudinary_url.call(this, publicId, options);
  };

  Cloudinary.prototype.video_url = function(publicId, options) {
    options = _.merge({
      resource_type: 'video'
    }, options);
    return cloudinary_url.call(this, publicId, options);
  };

  Cloudinary.prototype.video_thumbnail_url = function(publicId, options) {
    options = _.merge({}, DEFAULT_POSTER_OPTIONS, options);
    return cloudinary_url.call(this, publicId, options);
  };

  Cloudinary.prototype.url_internal = cloudinary_url;

  Cloudinary.prototype.transformation_string = function(options) {
    options = _.cloneDeep(options);
    return new Transformation(options).flatten();
  };

  Cloudinary.prototype.image = function(public_id, options) {
    var src;
    if (options == null) {
      options = {};
    }
    options = _.defaults(_.cloneDeep(options), this.configuration.defaults(), DEFAULT_IMAGE_PARAMS);
    src = cloudinary_url.call(this, public_id, options);
    options["src"] = src;
    return new ImageTag(options).toHtml();
  };

  Cloudinary.prototype.video_thumbnail = function(public_id, options) {
    return image(public_id, _.extend({}, DEFAULT_POSTER_OPTIONS, options));
  };

  Cloudinary.prototype.facebook_profile_image = function(public_id, options) {
    return this.image(public_id, _.merge({
      type: 'facebook'
    }, options));
  };

  Cloudinary.prototype.twitter_profile_image = function(public_id, options) {
    return this.image(public_id, _.merge({
      type: 'twitter'
    }, options));
  };

  Cloudinary.prototype.twitter_name_profile_image = function(public_id, options) {
    return this.image(public_id, _.merge({
      type: 'twitter_name'
    }, options));
  };

  Cloudinary.prototype.gravatar_image = function(public_id, options) {
    return this.image(public_id, _.merge({
      type: 'gravatar'
    }, options));
  };

  Cloudinary.prototype.fetch_image = function(public_id, options) {
    return this.image(public_id, _.merge({
      type: 'fetch'
    }, options));
  };

  Cloudinary.prototype.video = function(publicId, options) {
    var attributes, fallback, html, i, mimeType, source, sourceTransformation, sourceTypes, source_type, src, transformation, videoOptions, videoType;
    if (options == null) {
      options = {};
    }
    options = _.defaults(_.cloneDeep(options), this.configuration.defaults(), DEFAULT_VIDEO_PARAMS);
    publicId = publicId.replace(/\.(mp4|ogv|webm)$/, '');
    sourceTypes = options['source_types'];
    sourceTransformation = options['source_transformation'];
    fallback = options['fallback_content'];
    videoOptions = _.cloneDeep(options);
    if (videoOptions.hasOwnProperty('poster')) {
      if (_.isPlainObject(videoOptions.poster)) {
        if (videoOptions.poster.hasOwnProperty('public_id')) {
          videoOptions.poster = cloudinary_url.call(this, videoOptions.poster.public_id, videoOptions.poster);
        } else {
          videoOptions.poster = cloudinary_url.call(this, publicId, _.defaults(videoOptions.poster, DEFAULT_POSTER_OPTIONS));
        }
      }
    } else {
      videoOptions.poster = cloudinary_url.call(this, publicId, _.defaults(options, DEFAULT_POSTER_OPTIONS));
    }
    if (!videoOptions.poster) {
      delete videoOptions.poster;
    }
    source = publicId;
    if (!_.isArray(sourceTypes)) {
      videoOptions.src = this.url(source + "." + sourceTypes, videoOptions);
    }
    attributes = new Transformation(videoOptions).toHtmlAttributes();
    html = '<video ' + html_attrs(attributes) + '>';
    if (_.isArray(sourceTypes)) {
      i = 0;
      while (i < sourceTypes.length) {
        source_type = sourceTypes[i];
        transformation = sourceTransformation[source_type] || {};
        src = this.url("" + source, _.defaults({
          resource_type: 'video',
          format: source_type
        }, options, transformation));
        videoType = source_type === 'ogv' ? 'ogg' : source_type;
        mimeType = 'video/' + videoType;
        html = html + '<source ' + html_attrs({
          src: src,
          type: mimeType
        }) + '>';
        i++;
      }
    }
    html = html + fallback;
    html = html + '</video>';
    return html;
  };

  Cloudinary.prototype.sprite_css = function(public_id, options) {
    options = _.merge({
      type: 'sprite'
    }, options);
    if (!public_id.match(/.css$/)) {
      options.format = 'css';
    }
    return this.url(public_id, options);
  };

  Cloudinary.prototype.responsive = function(options) {
    var responsive_config, responsive_resize, responsive_resize_initialized, timeout;
    responsive_config = _.merge(responsive_config || {}, options);
    $('img.cld-responsive, img.cld-hidpi').cloudinary_update(responsive_config);
    responsive_resize = get_config('responsive_resize', responsive_config, true);
    if (responsive_resize && !responsive_resize_initialized) {
      responsive_config.resizing = responsive_resize_initialized = true;
      timeout = null;
      $(window).on('resize', function() {
        var debounce, reset, run, wait;
        debounce = get_config('responsive_debounce', responsive_config, 100);
        reset = function() {
          if (timeout) {
            clearTimeout(timeout);
            timeout = null;
          }
        };
        run = function() {
          $('img.cld-responsive').cloudinary_update(responsive_config);
        };
        wait = function() {
          reset();
          setTimeout((function() {
            reset();
            run();
          }), debounce);
        };
        if (debounce) {
          wait();
        } else {
          run();
        }
      });
    }
  };

  Cloudinary.prototype.calc_stoppoint = function(element, width) {
    var stoppoints;
    stoppoints = $(element).data('stoppoints') || this.config().stoppoints || default_stoppoints;
    if (typeof stoppoints === 'function') {
      return stoppoints(width);
    }
    if (typeof stoppoints === 'string') {
      stoppoints = _.map(stoppoints.split(','), function(val) {
        return parseInt(val);
      });
    }
    return closest_above(stoppoints, width);
  };

  Cloudinary.prototype.device_pixel_ratio = function() {
    var dpr, dpr_string, dpr_used;
    dpr = window.devicePixelRatio || 1;
    dpr_string = device_pixel_ratio_cache[dpr];
    if (!dpr_string) {
      dpr_used = closest_above(this.supported_dpr_values, dpr);
      dpr_string = dpr_used.toString();
      if (dpr_string.match(/^\d+$/)) {
        dpr_string += '.0';
      }
      device_pixel_ratio_cache[dpr] = dpr_string;
    }
    return dpr_string;
  };

  Cloudinary.prototype.supported_dpr_values = [0.75, 1.0, 1.3, 1.5, 2.0, 3.0];

  default_stoppoints = function(width) {
    return 10 * Math.ceil(width / 10);
  };

  closest_above = function(list, value) {
    var i;
    i = list.length - 2;
    while (i >= 0 && list[i] >= value) {
      i--;
    }
    return list[i + 1];
  };

  cdn_subdomain_number = function(public_id) {
    return crc32(public_id) % 5 + 1;
  };

  cloudinary_url_prefix = function(public_id, options) {
    var cdn_part, host, path, protocol, ref, ref1, subdomain;
    if (((ref = options.cloud_name) != null ? ref.indexOf("/") : void 0) === 0) {
      return '/res' + options.cloud_name;
    }
    protocol = "http://";
    cdn_part = "";
    subdomain = "res";
    host = ".cloudinary.com";
    path = "/" + options.cloud_name;
    if (options.protocol) {
      protocol = options.protocol + '//';
    } else if ((typeof window !== "undefined" && window !== null ? (ref1 = window.location) != null ? ref1.protocol : void 0 : void 0) === 'file:') {
      protocol = 'file://';
    }
    if (options.private_cdn) {
      cdn_part = options.cloud_name + "-";
      path = "";
    }
    if (options.cdn_subdomain) {
      subdomain = "res-" + cdn_subdomain_number(public_id);
    }
    if (options.secure) {
      protocol = "https://";
      if (options.secure_cdn_subdomain === false) {
        subdomain = "res";
      }
      if ((options.secure_distribution != null) && options.secure_distribution !== OLD_AKAMAI_SHARED_CDN && options.secure_distribution !== SHARED_CDN) {
        cdn_part = "";
        subdomain = "";
        host = options.secure_distribution;
      }
    } else if (options.cname) {
      protocol = "http://";
      cdn_part = "";
      subdomain = options.cdn_subdomain ? 'a' + ((crc32(public_id) % 5) + 1) + '.' : '';
      host = options.cname;
    }
    return [protocol, cdn_part, subdomain, host, path].join("");
  };

  join_pair = function(key, value) {
    if (!value) {
      return void 0;
    } else if (value === true) {
      return key;
    } else {
      return key + '="' + value + '"';
    }
  };


  /**
   * combine key and value from the `attr` to generate an HTML tag attributes string.
   * `Transformation::toHtmlTagOptions` is used to filter out transformation and configuration keys.
   * @param {Object} attr
   * @return {String} the attributes in the format `'key1="value1" key2="value2"'`
   */

  html_attrs = function(attrs) {
    var pairs;
    pairs = _.map(attrs, function(value, key) {
      return join_pair(key, value);
    });
    pairs.sort();
    return pairs.filter(function(pair) {
      return pair;
    }).join(' ');
  };

  unsigned_upload_tag = function(upload_preset, upload_params, options) {
    return $('<input/>').attr({
      type: 'file',
      name: 'file'
    }).unsigned_cloudinary_upload(upload_preset, upload_params, options);
  };

  return Cloudinary;

})();

if (typeof module !== "undefined" && module !== null ? module.exports : void 0) {
  exports.Cloudinary = Cloudinary;
} else {
  window.Cloudinary = Cloudinary;
}

crc32 = function(str) {
  var crc, i, iTop, table, x, y;
  str = utf8_encode(str);
  table = '00000000 77073096 EE0E612C 990951BA 076DC419 706AF48F E963A535 9E6495A3 0EDB8832 79DCB8A4 E0D5E91E 97D2D988 09B64C2B 7EB17CBD E7B82D07 90BF1D91 1DB71064 6AB020F2 F3B97148 84BE41DE 1ADAD47D 6DDDE4EB F4D4B551 83D385C7 136C9856 646BA8C0 FD62F97A 8A65C9EC 14015C4F 63066CD9 FA0F3D63 8D080DF5 3B6E20C8 4C69105E D56041E4 A2677172 3C03E4D1 4B04D447 D20D85FD A50AB56B 35B5A8FA 42B2986C DBBBC9D6 ACBCF940 32D86CE3 45DF5C75 DCD60DCF ABD13D59 26D930AC 51DE003A C8D75180 BFD06116 21B4F4B5 56B3C423 CFBA9599 B8BDA50F 2802B89E 5F058808 C60CD9B2 B10BE924 2F6F7C87 58684C11 C1611DAB B6662D3D 76DC4190 01DB7106 98D220BC EFD5102A 71B18589 06B6B51F 9FBFE4A5 E8B8D433 7807C9A2 0F00F934 9609A88E E10E9818 7F6A0DBB 086D3D2D 91646C97 E6635C01 6B6B51F4 1C6C6162 856530D8 F262004E 6C0695ED 1B01A57B 8208F4C1 F50FC457 65B0D9C6 12B7E950 8BBEB8EA FCB9887C 62DD1DDF 15DA2D49 8CD37CF3 FBD44C65 4DB26158 3AB551CE A3BC0074 D4BB30E2 4ADFA541 3DD895D7 A4D1C46D D3D6F4FB 4369E96A 346ED9FC AD678846 DA60B8D0 44042D73 33031DE5 AA0A4C5F DD0D7CC9 5005713C 270241AA BE0B1010 C90C2086 5768B525 206F85B3 B966D409 CE61E49F 5EDEF90E 29D9C998 B0D09822 C7D7A8B4 59B33D17 2EB40D81 B7BD5C3B C0BA6CAD EDB88320 9ABFB3B6 03B6E20C 74B1D29A EAD54739 9DD277AF 04DB2615 73DC1683 E3630B12 94643B84 0D6D6A3E 7A6A5AA8 E40ECF0B 9309FF9D 0A00AE27 7D079EB1 F00F9344 8708A3D2 1E01F268 6906C2FE F762575D 806567CB 196C3671 6E6B06E7 FED41B76 89D32BE0 10DA7A5A 67DD4ACC F9B9DF6F 8EBEEFF9 17B7BE43 60B08ED5 D6D6A3E8 A1D1937E 38D8C2C4 4FDFF252 D1BB67F1 A6BC5767 3FB506DD 48B2364B D80D2BDA AF0A1B4C 36034AF6 41047A60 DF60EFC3 A867DF55 316E8EEF 4669BE79 CB61B38C BC66831A 256FD2A0 5268E236 CC0C7795 BB0B4703 220216B9 5505262F C5BA3BBE B2BD0B28 2BB45A92 5CB36A04 C2D7FFA7 B5D0CF31 2CD99E8B 5BDEAE1D 9B64C2B0 EC63F226 756AA39C 026D930A 9C0906A9 EB0E363F 72076785 05005713 95BF4A82 E2B87A14 7BB12BAE 0CB61B38 92D28E9B E5D5BE0D 7CDCEFB7 0BDBDF21 86D3D2D4 F1D4E242 68DDB3F8 1FDA836E 81BE16CD F6B9265B 6FB077E1 18B74777 88085AE6 FF0F6A70 66063BCA 11010B5C 8F659EFF F862AE69 616BFFD3 166CCF45 A00AE278 D70DD2EE 4E048354 3903B3C2 A7672661 D06016F7 4969474D 3E6E77DB AED16A4A D9D65ADC 40DF0B66 37D83BF0 A9BCAE53 DEBB9EC5 47B2CF7F 30B5FFE9 BDBDF21C CABAC28A 53B39330 24B4A3A6 BAD03605 CDD70693 54DE5729 23D967BF B3667A2E C4614AB8 5D681B02 2A6F2B94 B40BBE37 C30C8EA1 5A05DF1B 2D02EF8D';
  crc = 0;
  x = 0;
  y = 0;
  crc = crc ^ -1;
  i = 0;
  iTop = str.length;
  while (i < iTop) {
    y = (crc ^ str.charCodeAt(i)) & 0xFF;
    x = '0x' + table.substr(y * 9, 8);
    crc = crc >>> 8 ^ x;
    i++;
  }
  crc = crc ^ -1;
  if (crc < 0) {
    crc += 4294967296;
  }
  return crc;
};

if (typeof module !== "undefined" && module.exports) {
  exports.crc32 = crc32;
} else {
  window.crc32 = crc32;
}

utf8_encode = function(argString) {
  var c1, enc, end, n, start, string, stringl, utftext;
  if (argString === null || typeof argString === 'undefined') {
    return '';
  }
  string = argString + '';
  utftext = '';
  start = void 0;
  end = void 0;
  stringl = 0;
  start = end = 0;
  stringl = string.length;
  n = 0;
  while (n < stringl) {
    c1 = string.charCodeAt(n);
    enc = null;
    if (c1 < 128) {
      end++;
    } else if (c1 > 127 && c1 < 2048) {
      enc = String.fromCharCode(c1 >> 6 | 192, c1 & 63 | 128);
    } else {
      enc = String.fromCharCode(c1 >> 12 | 224, c1 >> 6 & 63 | 128, c1 & 63 | 128);
    }
    if (enc !== null) {
      if (end > start) {
        utftext += string.slice(start, end);
      }
      utftext += enc;
      start = end = n + 1;
    }
    n++;
  }
  if (end > start) {
    utftext += string.slice(start, stringl);
  }
  return utftext;
};

if (typeof module !== "undefined" && module.exports) {
  exports.utf8_encode = utf8_encode;
} else {
  window.utf8_encode = utf8_encode;
}

cloudinary_config = void 0;

CloudinaryConfiguration = (function() {

  /**
   * Defaults configuration.
   *
   * (Previously defined using option_consume() )
   */
  var DEFAULT_CONFIGURATION_PARAMS, ref;

  DEFAULT_CONFIGURATION_PARAMS = {
    secure: (typeof window !== "undefined" && window !== null ? (ref = window.location) != null ? ref.protocol : void 0 : void 0) === 'https:'
  };

  CloudinaryConfiguration.CONFIG_PARAMS = ["api_key", "api_secret", "cdn_subdomain", "cloud_name", "cname", "private_cdn", "protocol", "resource_type", "responsive_width", "secure", "secure_cdn_subdomain", "secure_distribution", "shorten", "type", "url_suffix", "use_root_path", "version"];

  function CloudinaryConfiguration(options) {
    if (options == null) {
      options = {};
    }
    this.configuration = _.cloneDeep(options);
    _.defaults(this.configuration, DEFAULT_CONFIGURATION_PARAMS);
  }

  CloudinaryConfiguration.prototype.set = function(config, value) {
    if (_.isUndefined(value)) {
      if (_.isPlainObject(config)) {
        this.merge(config);
      }
    } else {
      this.config[config] = value;
    }
    return this;
  };

  CloudinaryConfiguration.prototype.get = function(name) {
    return this.configuration[name];
  };

  CloudinaryConfiguration.prototype.merge = function(config) {
    if (config == null) {
      config = {};
    }
    return _.assign(this.configuration, config);
  };

  CloudinaryConfiguration.prototype.fromDocument = function() {
    var el, j, len, meta_elements;
    meta_elements = typeof document !== "undefined" && document !== null ? document.getElementsByTagName("meta") : void 0;
    if (meta_elements) {
      for (j = 0, len = meta_elements.length; j < len; j++) {
        el = meta_elements[j];
        this.cloudinary[el.getAttribute('name').replace('cloudinary_', '')] = el.getAttribute('content');
      }
    }
    return this;
  };

  CloudinaryConfiguration.prototype.fromEnvironment = function() {
    var cloudinary, cloudinary_url, k, ref1, ref2, uri, v;
    cloudinary_url = typeof process !== "undefined" && process !== null ? (ref1 = process.env) != null ? ref1.CLOUDINARY_URL : void 0 : void 0;
    if (cloudinary_url != null) {
      uri = require('url').parse(cloudinary_url, true);
      cloudinary = {
        cloud_name: uri.host,
        api_key: uri.auth && uri.auth.split(":")[0],
        api_secret: uri.auth && uri.auth.split(":")[1],
        private_cdn: uri.pathname != null,
        secure_distribution: uri.pathname && uri.pathname.substring(1)
      };
      if (uri.query != null) {
        ref2 = uri.query;
        for (k in ref2) {
          v = ref2[k];
          cloudinary[k] = v;
        }
      }
    }
    return this;
  };

  CloudinaryConfiguration.prototype.config = function(new_config, new_value) {
    if ((this.configuration == null) || new_config === true) {
      this.fromEnvironment();
      if (!this.configuration) {
        this.fromDocument();
      }
    }
    if (!_.isUndefined(new_value)) {
      this.set(new_config, new_value);
      return this.configuration;
    } else if (_.isString(new_config)) {
      return this.get(new_config);
    } else if (_.isObject(new_config)) {
      this.merge(new_config);
      return this.configuration;
    } else {
      return this.configuration;
    }
  };

  CloudinaryConfiguration.prototype.defaults = function() {
    return _.pick(this.configuration, ["cdn_subdomain", "cloud_name", "cname", "dpr", "fallback_content", "private_cdn", "protocol", "resource_type", "responsive_width", "secure", "secure_cdn_subdomain", "secure_distribution", "shorten", "source_transformation", "source_types", "transformation", "type", "use_root_path"]);
  };

  return CloudinaryConfiguration;

})();

if (typeof module !== "undefined" && module !== null ? module.exports : void 0) {
  exports.CloudinaryConfiguration = CloudinaryConfiguration;
} else {
  window.CloudinaryConfiguration = CloudinaryConfiguration;
}

config = config || function() {
  return {};
};


/**
 * Defaults values for parameters.
 *
 * (Previously defined using option_consume() )
 */

Param = (function() {
  function Param(name1, short, process1) {
    this.name = name1;
    this.short = short;
    this.process = process1 != null ? process1 : _.identity;
  }

  Param.prototype.set = function(value1) {
    this.value = value1;
    return this;
  };

  Param.prototype.flatten = function() {
    var val;
    val = this.process(this.value);
    if ((this.short != null) && (val != null)) {
      return this.short + "_" + val;
    } else {
      return null;
    }
  };

  Param.norm_range_value = function(value) {
    var modifier, offset;
    offset = String(value).match(new RegExp('^' + offset_any_pattern + '$'));
    if (offset) {
      modifier = offset[5] != null ? 'p' : '';
      value = (offset[1] || offset[4]) + modifier;
    }
    return value;
  };

  Param.norm_color = function(value) {
    return value != null ? value.replace(/^#/, 'rgb:') : void 0;
  };

  Param.prototype.build_array = function(arg) {
    if (arg == null) {
      arg = [];
    }
    if (_.isArray(arg)) {
      return arg;
    } else {
      return [arg];
    }
  };

  return Param;

})();

ArrayParam = (function(superClass) {
  extend(ArrayParam, superClass);

  function ArrayParam(name1, short, sep1, process1) {
    this.name = name1;
    this.short = short;
    this.sep = sep1 != null ? sep1 : '.';
    this.process = process1 != null ? process1 : _.identity;
    ArrayParam.__super__.constructor.call(this, this.name, this.short, this.process);
  }

  ArrayParam.prototype.flatten = function() {
    var flat, t;
    if (this.short != null) {
      flat = (function() {
        var j, len, ref, results;
        ref = this.value;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          t = ref[j];
          if (_.isFunction(t.flatten)) {
            results.push(t.flatten());
          } else {
            results.push(t);
          }
        }
        return results;
      }).call(this);
      return this.short + "_" + (flat.join(this.sep));
    } else {
      return null;
    }
  };

  ArrayParam.prototype.set = function(value1) {
    this.value = value1;
    if (_.isArray(this.value)) {
      return ArrayParam.__super__.set.call(this, this.value);
    } else {
      return ArrayParam.__super__.set.call(this, [this.value]);
    }
  };

  return ArrayParam;

})(Param);

TransformationParam = (function(superClass) {
  extend(TransformationParam, superClass);

  function TransformationParam(name1, short, sep1, process1) {
    this.name = name1;
    this.short = short != null ? short : "t";
    this.sep = sep1 != null ? sep1 : '.';
    this.process = process1 != null ? process1 : _.identity;
    TransformationParam.__super__.constructor.call(this, this.name, this.short, this.process);
  }

  TransformationParam.prototype.flatten = function() {
    var result, t;
    result = (function() {
      var j, len, ref, results;
      if (_.isEmpty(this.value)) {
        return null;
      } else if (_.all(this.value, _.isString)) {
        return [this.short + "_" + (this.value.join(this.sep))];
      } else {
        ref = this.value;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          t = ref[j];
          if (t != null) {
            if (_.isString(t)) {
              results.push(this.short + "_" + t);
            } else if (_.isFunction(t.flatten)) {
              results.push(t.flatten());
            } else if (_.isPlainObject(t)) {
              results.push(new Transformation(t).flatten());
            } else {
              results.push(void 0);
            }
          }
        }
        return results;
      }
    }).call(this);
    return _.compact(result);
  };

  TransformationParam.prototype.set = function(value1) {
    this.value = value1;
    if (_.isArray(this.value)) {
      return TransformationParam.__super__.set.call(this, this.value);
    } else {
      return TransformationParam.__super__.set.call(this, [this.value]);
    }
  };

  return TransformationParam;

})(Param);

RangeParam = (function(superClass) {
  extend(RangeParam, superClass);

  function RangeParam(name1, short, process1) {
    this.name = name1;
    this.short = short;
    this.process = process1 != null ? process1 : this.norm_range_value;
    RangeParam.__super__.constructor.call(this, this.name, this.short, this.process);
  }

  return RangeParam;

})(Param);

RawParam = (function(superClass) {
  extend(RawParam, superClass);

  function RawParam(name1, short, process1) {
    this.name = name1;
    this.short = short;
    this.process = process1 != null ? process1 : _.identity;
    RawParam.__super__.constructor.call(this, this.name, this.short, this.process);
  }

  RawParam.prototype.flatten = function() {
    return this.value;
  };

  return RawParam;

})(Param);


/**
 * A video codec parameter can be either a String or a Hash.
 * @param {Object} param <code>vc_<codec>[ : <profile> : [<level>]]</code>
 *                       or <code>{ codec: 'h264', profile: 'basic', level: '3.1' }</code>
 * @return {String} <code><codec> : <profile> : [<level>]]</code> if a Hash was provided
 *                   or the param if a String was provided.
 *                   Returns null if param is not a Hash or String
 */

process_video_params = function(param) {
  var video;
  switch (param.constructor) {
    case Object:
      video = "";
      if ('codec' in param) {
        video = param['codec'];
        if ('profile' in param) {
          video += ":" + param['profile'];
          if ('level' in param) {
            video += ":" + param['level'];
          }
        }
      }
      return video;
    case String:
      return param;
    default:
      return null;
  }
};


/**
 * Parameters that are filtered out before passing the options to an HTML tag
 */

transformationParams = ["angle", "audio_codec", "audio_frequency", "background", "bit_rate", "border", "cdn_subdomain", "cloud_name", "cname", "color", "color_space", "crop", "default_image", "delay", "density", "dpr", "dpr", "duration", "effect", "end_offset", "fallback_content", "fetch_format", "format", "flags", "gravity", "height", "offset", "opacity", "overlay", "page", "prefix", "private_cdn", "protocol", "quality", "radius", "raw_transformation", "resource_type", "responsive_width", "secure", "secure_cdn_subdomain", "secure_distribution", "shorten", "size", "source_transformation", "source_types", "start_offset", "transformation", "type", "underlay", "url_suffix", "use_root_path", "version", "video_codec", "video_sampling", "width", "x", "y", "zoom"];

TransformationBase = (function() {
  function TransformationBase(options) {
    var trans;
    if (options == null) {
      options = {};
    }
    trans = {};
    this.whitelist = _.functions(TransformationBase.prototype);
    this.toOptions = function() {
      return _.mapValues(trans, function(t) {
        return t.value;
      });
    };
    this.param = function(value, name, abbr, defaultValue, process) {
      if (process == null) {
        if (_.isFunction(defaultValue)) {
          process = defaultValue;
        } else {
          process = _.identity;
        }
      }
      trans[name] = new Param(name, abbr, process).set(value);
      return this;
    };
    this.rawParam = function(value, name, abbr, defaultValue, process) {
      if (process == null) {
        process = _.identity;
      }
      if (_.isFunction(defaultValue) && (process == null)) {
        process = defaultValue;
      }
      trans[name] = new RawParam(name, abbr, process).set(value);
      return this;
    };
    this.rangeParam = function(value, name, abbr, defaultValue, process) {
      if (process == null) {
        process = _.identity;
      }
      if (_.isFunction(defaultValue) && (process == null)) {
        process = defaultValue;
      }
      trans[name] = new RangeParam(name, abbr, process).set(value);
      return this;
    };
    this.arrayParam = function(value, name, abbr, sep, defaultValue, process) {
      if (sep == null) {
        sep = ":";
      }
      if (defaultValue == null) {
        defaultValue = [];
      }
      if (process == null) {
        process = _.identity;
      }
      if (_.isFunction(defaultValue) && (process == null)) {
        process = defaultValue;
      }
      trans[name] = new ArrayParam(name, abbr, sep, process).set(value);
      return this;
    };
    this.transformationParam = function(value, name, abbr, sep, defaultValue, process) {
      if (sep == null) {
        sep = ".";
      }
      if (process == null) {
        process = _.identity;
      }
      if (_.isFunction(defaultValue) && (process == null)) {
        process = defaultValue;
      }
      trans[name] = new TransformationParam(name, abbr, sep, process).set(value);
      return this;
    };
    this.getValue = function(name) {
      var ref;
      return (ref = trans[name]) != null ? ref.value : void 0;
    };
    this.get = function(name) {
      return trans[name];
    };
    this.remove = function(name) {
      var temp;
      temp = trans[name];
      delete trans[name];
      return temp;
    };
    this.keys = function() {
      return _.keys(trans).sort();
    };
    this.toPlainObject = function() {
      var hash, key;
      hash = {};
      for (key in trans) {
        hash[key] = trans[key].value;
      }
      return hash;
    };
  }

  TransformationBase.prototype.angle = function(value) {
    return this.arrayParam(value, "angle", "a", ".");
  };

  TransformationBase.prototype.audio_codec = function(value) {
    return this.param(value, "audio_codec", "ac");
  };

  TransformationBase.prototype.audio_frequency = function(value) {
    return this.param(value, "audio_frequency", "af");
  };

  TransformationBase.prototype.background = function(value) {
    return this.param(value, "background", "b", Param.norm_color);
  };

  TransformationBase.prototype.bit_rate = function(value) {
    return this.param(value, "bit_rate", "br");
  };

  TransformationBase.prototype.border = function(value) {
    return this.param(value, "border", "bo", function(border) {
      if (_.isPlainObject(border)) {
        border = _.assign({}, {
          color: "black",
          width: 2
        }, border);
        return border.width + "px_solid_" + (Param.norm_color(border.color));
      } else {
        return border;
      }
    });
  };

  TransformationBase.prototype.color = function(value) {
    return this.param(value, "color", "co", Param.norm_color);
  };

  TransformationBase.prototype.color_space = function(value) {
    return this.param(value, "color_space", "cs");
  };

  TransformationBase.prototype.crop = function(value) {
    return this.param(value, "crop", "c");
  };

  TransformationBase.prototype.default_image = function(value) {
    return this.param(value, "default_image", "d");
  };

  TransformationBase.prototype.delay = function(value) {
    return this.param(value, "delay", "l");
  };

  TransformationBase.prototype.density = function(value) {
    return this.param(value, "density", "dn");
  };

  TransformationBase.prototype.duration = function(value) {
    return this.rangeParam(value, "duration", "du");
  };

  TransformationBase.prototype.dpr = function(value) {
    return this.param(value, "dpr", "dpr", function(dpr) {
      dpr = dpr.toString();
      if (dpr === "auto") {
        return "1.0";
      } else if (dpr != null ? dpr.match(/^\d+$/) : void 0) {
        return dpr + ".0";
      } else {
        return dpr;
      }
    });
  };

  TransformationBase.prototype.effect = function(value) {
    return this.arrayParam(value, "effect", "e", ":");
  };

  TransformationBase.prototype.end_offset = function(value) {
    return this.rangeParam(value, "end_offset", "eo");
  };

  TransformationBase.prototype.fetch_format = function(value) {
    return this.param(value, "fetch_format", "f");
  };

  TransformationBase.prototype.format = function(value) {
    return this.param(value, "format");
  };

  TransformationBase.prototype.flags = function(value) {
    return this.arrayParam(value, "flags", "fl", ".");
  };

  TransformationBase.prototype.gravity = function(value) {
    return this.param(value, "gravity", "g");
  };

  TransformationBase.prototype.height = function(value) {
    return this.param(value, "height", "h", (function(_this) {
      return function() {
        if (_.any([_this.getValue("crop"), _this.getValue("overlay"), _this.getValue("underlay")])) {
          return value;
        } else {
          return null;
        }
      };
    })(this));
  };

  TransformationBase.prototype.html_height = function(value) {
    return this.param(value, "html_height");
  };

  TransformationBase.prototype.html_width = function(value) {
    return this.param(value, "html_width");
  };

  TransformationBase.prototype.offset = function(value) {
    var end_o, ref, start_o;
    ref = _.isFunction(value != null ? value.split : void 0) ? value.split('..') : _.isArray(value) ? value : [null, null], start_o = ref[0], end_o = ref[1];
    if (start_o != null) {
      this.start_offset(start_o);
    }
    if (end_o != null) {
      return this.end_offset(end_o);
    }
  };

  TransformationBase.prototype.opacity = function(value) {
    return this.param(value, "opacity", "o");
  };

  TransformationBase.prototype.overlay = function(value) {
    return this.param(value, "overlay", "l");
  };

  TransformationBase.prototype.page = function(value) {
    return this.param(value, "page", "pg");
  };

  TransformationBase.prototype.prefix = function(value) {
    return this.param(value, "prefix", "p");
  };

  TransformationBase.prototype.quality = function(value) {
    return this.param(value, "quality", "q");
  };

  TransformationBase.prototype.radius = function(value) {
    return this.param(value, "radius", "r");
  };

  TransformationBase.prototype.raw_transformation = function(value) {
    return this.rawParam(value, "raw_transformation");
  };

  TransformationBase.prototype.size = function(value) {
    var height, ref, width;
    if (_.isFunction(value != null ? value.split : void 0)) {
      ref = value.split('x'), width = ref[0], height = ref[1];
      this.width(width);
      return this.height(height);
    }
  };

  TransformationBase.prototype.start_offset = function(value) {
    return this.rangeParam(value, "start_offset", "so");
  };

  TransformationBase.prototype.transformation = function(value) {
    return this.transformationParam(value, "transformation");
  };

  TransformationBase.prototype.underlay = function(value) {
    return this.param(value, "underlay", "u");
  };

  TransformationBase.prototype.video_codec = function(value) {
    return this.param(value, "video_codec", "vc", process_video_params);
  };

  TransformationBase.prototype.video_sampling = function(value) {
    return this.param(value, "video_sampling", "vs");
  };

  TransformationBase.prototype.width = function(value) {
    return this.param(value, "width", "w", (function(_this) {
      return function() {
        if (_.any([_this.getValue("crop"), _this.getValue("overlay"), _this.getValue("underlay")])) {
          return value;
        } else {
          return null;
        }
      };
    })(this));
  };

  TransformationBase.prototype.x = function(value) {
    return this.param(value, "x", "x");
  };

  TransformationBase.prototype.y = function(value) {
    return this.param(value, "y", "y");
  };

  TransformationBase.prototype.zoom = function(value) {
    return this.param(value, "zoom", "z");
  };

  return TransformationBase;

})();


/**
 *  A single transformation.
 *
 *  Usage:
 *
 *      t = new Transformation();
 *      t.angle(20).crop("scale").width("auto");
 *
 *  or
 *      t = new Transformation( {angle: 20, crop: "scale", width: "auto"});
 */

Transformation = (function(superClass) {
  extend(Transformation, superClass);

  function Transformation(options) {
    var parent;
    if (options == null) {
      options = {};
    }
    parent = null;
    this.otherOptions = {};
    Transformation.__super__.constructor.call(this);
    this.fromOptions(options);
    this.setParent = function(object) {
      return parent = object;
    };
    this.getParent = function() {
      return parent;
    };
  }

  Transformation.prototype.fromOptions = function(options) {
    var j, k, len, ref;
    if (options == null) {
      options = {};
    }
    options = _.cloneDeep(options);
    if (_.isString(options) || _.isArray(options)) {
      options = {
        transformation: options
      };
    }
    ref = _.keys(options);
    for (j = 0, len = ref.length; j < len; j++) {
      k = ref[j];
      if (_.includes(this.whitelist, k)) {
        this[k](options[k]);
      } else {
        console.log("setting otherOptions[%s] = %o", k, options[k]);
        this.otherOptions[k] = options[k];
      }
    }
    return this;
  };

  Transformation["new"] = function(args) {
    return new Transformation(args);
  };

  Transformation.prototype.hasLayer = function() {
    return this.getValue("overlay") || this.getValue("underlay") || this.getValue("angle");
  };

  Transformation.prototype.flatten = function() {
    var resultArray, t, transformationString, transformations;
    resultArray = [];
    transformations = this.remove("transformation");
    if (transformations) {
      resultArray = resultArray.concat(transformations.flatten());
    }
    transformationString = (function() {
      var j, len, ref, ref1, results;
      ref = this.keys();
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        t = ref[j];
        results.push((ref1 = this.get(t)) != null ? ref1.flatten() : void 0);
      }
      return results;
    }).call(this);
    transformationString = _.filter(transformationString, function(value) {
      return _.isArray(value) && !_.isEmpty(value) || !_.isArray(value) && value;
    }).join(',');
    if (!_.isEmpty(transformationString)) {
      resultArray.push(transformationString);
    }
    return _.compact(resultArray).join('/');
  };

  Transformation.prototype.listNames = function() {
    return this.whitelist;
  };


  /**
   * Returns an options object with attributes for an HTML tag.
   * @return Object
   */

  Transformation.prototype.toHtmlAttributes = function() {
    var height, j, k, key, len, options, ref, v, width;
    options = _.omit(this.otherOptions, transformationParams);
    ref = _.difference(this.keys(), transformationParams);
    for (j = 0, len = ref.length; j < len; j++) {
      key = ref[j];
      options[key] = this.get(key).value;
    }
    for (k in options) {
      v = options[k];
      if (!(/^html_/.exec(k))) {
        continue;
      }
      options[k.substr(5)] = v;
      delete options[k];
    }
    if (!(this.hasLayer() || _.contains(["fit", "limit", "lfill"], this.getValue("crop")))) {
      width = this.getValue("width");
      height = this.getValue("height");
      if (parseFloat(width) >= 1.0) {
        if (options['width'] == null) {
          options['width'] = width;
        }
      }
      if (parseFloat(height) >= 1.0) {
        if (options['height'] == null) {
          options['height'] = height;
        }
      }
    }
    return options;
  };

  Transformation.prototype.isValidParamName = function(name) {
    return this.whitelist.indexOf(name) >= 0;
  };

  return Transformation;

})(TransformationBase);

if (!(((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) || (typeof exports !== "undefined" && exports !== null))) {
  exports = window;
}

if (exports.Cloudinary == null) {
  exports.Cloudinary = {};
}

exports.Cloudinary.Transformation = Transformation;

exports.Cloudinary.transformationParams = transformationParams;

HtmlTag = (function() {
  var html_attrs, toAttribute;

  toAttribute = function(key, value) {
    if (!value) {
      return void 0;
    } else if (value === true) {
      return key;
    } else {
      return key + "=\"" + value + " \"";
    }
  };


  /**
   * combine key and value from the `attr` to generate an HTML tag attributes string.
   * `Transformation::toHtmlTagOptions` is used to filter out transformation and configuration keys.
   * @param {Object} attr
   * @return {String} the attributes in the format `'key1="value1" key2="value2"'`
   */

  html_attrs = function(attrs) {
    var pairs;
    pairs = _.map(attrs, function(value, key) {
      return toAttribute(key, value);
    });
    pairs.sort();
    return pairs.filter(function(pair) {
      return pair;
    }).join(' ');
  };

  function HtmlTag(name, public_id, options) {
    var transformation;
    this.name = name;
    this.public_id = public_id;
    if (options == null) {
      if (_.isPlainObject(public_id)) {
        options = public_id;
        this.public_id = void 0;
      } else {
        options = {};
      }
    }
    this.options = _.cloneDeep(options);
    transformation = new Transformation(options);
    transformation.setParent(this);
    this.getTransformation = function() {
      return transformation;
    };
  }

  HtmlTag.prototype.getOptions = function() {
    return this.options;
  };

  HtmlTag.prototype.attributes = function() {
    var height, k, options, v, width;
    options = _.omit(this.options, _.union(Cloudinary.transformationParams, CloudinaryConfiguration.CONFIG_PARAMS));
    for (k in options) {
      v = options[k];
      if (!(/^html_/.exec(k))) {
        continue;
      }
      options[k.substr(5)] = v;
      delete options[k];
    }
    if (!(this.hasLayer() || _.contains(["fit", "limit", "lfill"], this.getValue("crop")))) {
      width = this.getValue("width");
      height = this.getValue("height");
      if (parseFloat(width) >= 1.0) {
        if (options['width'] == null) {
          options['width'] = width;
        }
      }
      if (parseFloat(height) >= 1.0) {
        if (options['height'] == null) {
          options['height'] = height;
        }
      }
    }
    return options;
  };

  HtmlTag.prototype.content = function() {
    return "";
  };

  HtmlTag.prototype.openTag = function() {
    return "<" + this.name + " " + (html_attrs(this.attributes())) + ">";
  };

  HtmlTag.prototype.closeTag = function() {
    return "</" + this.name + ">";
  };

  HtmlTag.prototype.content = function() {
    return "";
  };

  HtmlTag.prototype.toHtml = function() {
    return this.openTag() + this.content() + this.closeTag();
  };

  return HtmlTag;

})();

ImageTag = (function(superClass) {
  extend(ImageTag, superClass);

  function ImageTag(public_id1, options) {
    this.public_id = public_id1;
    if (options == null) {
      options = {};
    }
    ImageTag.__super__.constructor.call(this, "img", this.public_id, options);
  }

  ImageTag.prototype.toHtml = function() {
    return this.openTag();
  };

  return ImageTag;

})(HtmlTag);

VideoTag = (function(superClass) {

  /**
   * Defaults values for parameters.
   *
   * (Previously defined using option_consume() )
   */
  var DEFAULT_POSTER_OPTIONS, DEFAULT_VIDEO_PARAMS, DEFAULT_VIDEO_SOURCE_TYPES, VIDEO_TAG_PARAMS;

  extend(VideoTag, superClass);

  DEFAULT_VIDEO_PARAMS = {
    fallback_content: '',
    resource_type: "video",
    source_transformation: {},
    source_types: DEFAULT_VIDEO_SOURCE_TYPES,
    transformation: [],
    type: 'upload'
  };

  VIDEO_TAG_PARAMS = ['source_types', 'source_transformation', 'fallback_content', 'poster'];

  DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv'];

  DEFAULT_POSTER_OPTIONS = {
    format: 'jpg',
    resource_type: 'video'
  };

  function VideoTag(publicId, options) {
    if (options == null) {
      options = {};
    }
    VideoTag.__super__.constructor.call(this, "video", publicId.replace(/\.(mp4|ogv|webm)$/, ''), options);
    _.defaults(this.options, DEFAULT_VIDEO_PARAMS);
  }

  VideoTag.prototype.setSourceTransformation = function(value) {
    this.sourceTransformation = value;
    return this;
  };

  VideoTag.prototype.setSourceTypes = function(value) {
    this.sourceType = value;
    return this;
  };

  VideoTag.prototype.setPoster = function(value) {
    return this.poster = value;
  };

  VideoTag.prototype.content = function() {
    var fallback, innerTags, mimeType, sourceTransformation, sourceTypes, source_type, src, transformation, videoType;
    sourceTypes = options['source_types'];
    sourceTransformation = options['source_transformation'];
    fallback = options['fallback_content'];
    if (_.isArray(sourceTypes)) {
      innerTags = (function() {
        var j, len, results;
        results = [];
        for (j = 0, len = sourceTypes.length; j < len; j++) {
          source_type = sourceTypes[j];
          transformation = sourceTransformation[source_type] || {};
          src = this.url("" + this.public_id, _.defaults({
            resource_type: 'video',
            format: source_type
          }, options, transformation));
          videoType = source_type === 'ogv' ? 'ogg' : source_type;
          mimeType = 'video/' + videoType;
          results.push('<source ' + html_attrs({
            src: src,
            type: mimeType
          }) + '>');
        }
        return results;
      }).call(this);
    } else {
      innerTags = [];
    }
    return innerTags.join("\n") + fallback;
  };

  VideoTag.prototype.attributes = function() {
    var attr, sourceTypes;
    sourceTypes = this.options['source_types'];
    attr = VideoTag.__super__.attributes.call(this) || [];
    attr = _.omit(attr, VIDEO_TAG_PARAMS);
    if (!_.isArray(sourceTypes)) {
      attr["src"] = new Cloudinary(this.options).url(this.public_id + "." + sourceTypes);
    }
    return attr;
  };

  return VideoTag;

})(HtmlTag);

if (!(((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) || (exports != null))) {
  exports = window;
}

if (exports.Cloudinary == null) {
  exports.Cloudinary = {};
}

exports.Cloudinary.ImageTag = ImageTag;

exports.Cloudinary.VideoTag = VideoTag;


}));
;
