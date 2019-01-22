export var VERSION = "2.5.0";

export var CF_SHARED_CDN = "d3jpl91pxevbkh.cloudfront.net";

export var OLD_AKAMAI_SHARED_CDN = "cloudinary-a.akamaihd.net";

export var AKAMAI_SHARED_CDN = "res.cloudinary.com";

export var SHARED_CDN = AKAMAI_SHARED_CDN;

export var DEFAULT_POSTER_OPTIONS = {
  format: 'jpg',
  resource_type: 'video'
};

export var DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv'];

export var SEO_TYPES = {
  "image/upload": "images",
  "image/private": "private_images",
  "image/authenticated": "authenticated_images",
  "raw/upload": "files",
  "video/upload": "videos"
};

/**
* @const {Object} Cloudinary.DEFAULT_IMAGE_PARAMS
* Defaults values for image parameters.
*
* (Previously defined using option_consume() )
 */
export var DEFAULT_IMAGE_PARAMS = {
  resource_type: "image",
  transformation: [],
  type: 'upload'
};

/**
* Defaults values for video parameters.
* @const {Object} Cloudinary.DEFAULT_VIDEO_PARAMS
* (Previously defined using option_consume() )
 */
export var DEFAULT_VIDEO_PARAMS = {
  fallback_content: '',
  resource_type: "video",
  source_transformation: {},
  source_types: DEFAULT_VIDEO_SOURCE_TYPES,
  transformation: [],
  type: 'upload'
};
