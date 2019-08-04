
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

/**
 * Create the URL prefix for Cloudinary resources.
 * @param {string} publicId the resource public ID
 * @param {object} options additional options
 * @param {string} options.cloud_name - the cloud name.
 * @param {boolean} [options.cdn_subdomain=false] - Whether to automatically build URLs with
 *  multiple CDN sub-domains.
 * @param {string} [options.private_cdn] - Boolean (default: false). Should be set to true for Advanced plan's users
 *  that have a private CDN distribution.
 * @param {string} [options.protocol="http://"] - the URI protocol to use. If options.secure is true,
 *  the value is overridden to "https://"
 * @param {string} [options.secure_distribution] - The domain name of the CDN distribution to use for building HTTPS URLs.
 *  Relevant only for Advanced plan's users that have a private CDN distribution.
 * @param {string} [options.cname] - Custom domain name to use for building HTTP URLs.
 *  Relevant only for Advanced plan's users that have a private CDN distribution and a custom CNAME.
 * @param {boolean} [options.secure_cdn_subdomain=true] - When options.secure is true and this parameter is false,
 *  the subdomain is set to "res".
 * @param {boolean} [options.secure=false] - Force HTTPS URLs of images even if embedded in non-secure HTTP pages.
 *  When this value is true, options.secure_distribution will be used as host if provided, and options.protocol is set
 *  to "https://".
 * @returns {string} the URL prefix for the resource.
 * @private
*/
function cloudinaryUrlPrefix(publicId, options) {
  if (options.cloud_name && options.cloud_name[0] === '/') {
    return '/res' + options.cloud_name;
  }
  // defaults
  let protocol = "http://";
  let cdnPart = "";
  let subdomain = "res";
  let host = ".cloudinary.com";
  let path = "/" + options.cloud_name;
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
  var options;
  resourceType = resourceType == null ? "image" : resourceType;
  type = type == null ? "upload" : type;
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
      throw new Error(`URL Suffix only supported for ${Object.keys(SEO_TYPES).join(', ')}`);
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
 * Generates a URL for any asset in your Media library.
 * @function url
 * @ignore
 * @param {string} publicId - The public ID of the media asset.
 * @param {Object} [options={}] - The {@link Transformation} parameters to include in the URL.
 * @param {object} [config={}] - URL configuration parameters
 * @param {type} [options.type='upload'] - The asset's storage type.
 *  For details on all fetch types, see
 * <a href="https://cloudinary.com/documentation/image_transformations#fetching_images_from_remote_locations"
 *  target="_blank">Fetch types</a>. 
 * @param {Object} [options.resource_type='image'] - The type of asset. <p>Possible values:<br/> 
 *  - `image`<br/>
 *  - `video`<br/>
 *  - `raw` 
 * @return {string} The media asset URL.
 * @see <a href="https://cloudinary.com/documentation/image_transformation_reference" target="_blank">
 *  Available image transformations</a>
 * @see <a href="https://cloudinary.com/documentation/video_transformation_reference" target="_blank">
 *  Available video transformations</a>   
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
  // if publicId has a '/' and doesn't begin with v<number> and doesn't start with http[s]:/ and version is empty and force_version is truthy or undefined
  if ((options.force_version || typeof options.force_version === 'undefined') && publicId.search('/') >= 0 && !publicId.match(/^v[0-9]+/) && !publicId.match(/^https?:\//) && !((ref = options.version) != null ? ref.toString() : void 0)) {
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
