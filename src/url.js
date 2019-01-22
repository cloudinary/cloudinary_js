
import Transformation from './transformation';

import {
  DEFAULT_IMAGE_PARAMS,
  OLD_AKAMAI_SHARED_CDN,
  SHARED_CDN,
  SEO_TYPES
} from './constants';

import {
  defaults,
  compact,
  isPlainObject
} from './util';

import crc32 from './crc32';

function absolutize(url) {
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
}

// Produce a number between 1 and 5 to be used for cdn sub domains designation
function cdnSubdomainNumber(publicId) {
  return crc32(publicId) % 5 + 1;
}

//  * cdn_subdomain - Boolean (default: false). Whether to automatically build URLs with multiple CDN sub-domains. See this blog post for more details.
//  * private_cdn - Boolean (default: false). Should be set to true for Advanced plan's users that have a private CDN distribution.
//  * secure_distribution - The domain name of the CDN distribution to use for building HTTPS URLs. Relevant only for Advanced plan's users that have a private CDN distribution.
//  * cname - Custom domain name to use for building HTTP URLs. Relevant only for Advanced plan's users that have a private CDN distribution and a custom CNAME.
//  * secure - Boolean (default: false). Force HTTPS URLs of images even if embedded in non-secure HTTP pages.
function cloudinaryUrlPrefix(publicId, options) {
  var cdnPart, host, path, protocol, ref, subdomain;
  if (((ref = options.cloud_name) != null ? ref.indexOf("/") : void 0) === 0) {
    return '/res' + options.cloud_name;
  }
  // defaults
  protocol = "http://";
  cdnPart = "";
  subdomain = "res";
  host = ".cloudinary.com";
  path = "/" + options.cloud_name;
  // modifications
  if (options.protocol) {
    protocol = options.protocol + '//';
  }
  if (options.private_cdn) {
    cdnPart = options.cloud_name + "-";
    path = "";
  }
  if (options.cdn_subdomain) {
    subdomain = "res-" + cdnSubdomainNumber(publicId);
  }
  if (options.secure) {
    protocol = "https://";
    if (options.secure_cdn_subdomain === false) {
      subdomain = "res";
    }
    if ((options.secure_distribution != null) && options.secure_distribution !== OLD_AKAMAI_SHARED_CDN && options.secure_distribution !== SHARED_CDN) {
      cdnPart = "";
      subdomain = "";
      host = options.secure_distribution;
    }
  } else if (options.cname) {
    protocol = "http://";
    cdnPart = "";
    subdomain = options.cdn_subdomain ? 'a' + ((crc32(publicId) % 5) + 1) + '.' : '';
    host = options.cname;
  }
  return [protocol, cdnPart, subdomain, host, path].join("");
}

/**
 * Return the resource type and action type based on the given configuration
 * @function Cloudinary#finalizeResourceType
 * @param {Object|string} resourceType
 * @param {string} [type='upload']
 * @param {string} [urlSuffix]
 * @param {boolean} [useRootPath]
 * @param {boolean} [shorten]
 * @returns {string} resource_type/type
 * @ignore
 */
function finalizeResourceType(resourceType = "image", type = "upload", urlSuffix, useRootPath, shorten) {
  var key, options;
  if (isPlainObject(resourceType)) {
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
    resourceType = SEO_TYPES[`${resourceType}/${type}`];
    type = null;
    if (resourceType == null) {
      throw new Error(`URL Suffix only supported for ${((function () {
        var results;
        results = [];
        for (key in SEO_TYPES) {
          results.push(key);
        }
        return results;
      })()).join(', ')}`);
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
}

/**
 * Generate an resource URL.
 * @function Cloudinary#url
 * @param {string} publicId - the public ID of the resource
 * @param {Object} [options] - options for the tag and transformations, possible values include all {@link Transformation} parameters
 *                          and {@link Configuration} parameters
 * @param {string} [options.type='upload'] - the classification of the resource
 * @param {Object} [options.resource_type='image'] - the type of the resource
 * @param {Object} [config] URL configuration
 * @return {string} The resource URL
 */
export default function url(publicId, options = {}, config = {}) {
  var error, prefix, ref, resourceTypeAndType, transformation, transformationString, url, version;
  if (!publicId) {
    return publicId;
  }
  if (options instanceof Transformation) {
    options = options.toOptions();
  }
  options = defaults({}, options, config, DEFAULT_IMAGE_PARAMS);
  if (options.type === 'fetch') {
    options.fetch_format = options.fetch_format || options.format;
    publicId = absolutize(publicId);
  }
  transformation = new Transformation(options);
  transformationString = transformation.serialize();
  if (!options.cloud_name) {
    throw 'Unknown cloud_name';
  }
  // if publicId has a '/' and doesn't begin with v<number> and doesn't start with http[s]:/ and version is empty
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
    try {
      // Make sure publicId is URI encoded.
      publicId = decodeURIComponent(publicId);
    } catch (error1) {
      error = error1;
    }
    publicId = encodeURIComponent(publicId).replace(/%3A/g, ':').replace(/%2F/g, '/');
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
  prefix = cloudinaryUrlPrefix(publicId, options);
  resourceTypeAndType = finalizeResourceType(options.resource_type, options.type, options.url_suffix, options.use_root_path, options.shorten);
  version = options.version ? 'v' + options.version : '';
  return url || compact([prefix, resourceTypeAndType, transformationString, version, publicId]).join('/').replace(/([^:])\/+/g, '$1/');
};
