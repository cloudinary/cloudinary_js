export VERSION = "2.5.0"
export CF_SHARED_CDN = "d3jpl91pxevbkh.cloudfront.net"
export OLD_AKAMAI_SHARED_CDN = "cloudinary-a.akamaihd.net"
export AKAMAI_SHARED_CDN = "res.cloudinary.com"
export SHARED_CDN = AKAMAI_SHARED_CDN
export DEFAULT_POSTER_OPTIONS = { format: 'jpg', resource_type: 'video' }
export DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv']
export SEO_TYPES =
  "image/upload": "images",
  "image/private": "private_images",
  "image/authenticated": "authenticated_images",
  "raw/upload": "files",
  "video/upload": "videos"

###*
* @const {Object} Cloudinary.DEFAULT_IMAGE_PARAMS
* Defaults values for image parameters.
*
* (Previously defined using option_consume() )
###
export DEFAULT_IMAGE_PARAMS =
  resource_type: "image"
  transformation: []
  type: 'upload'

###*
* Defaults values for video parameters.
* @const {Object} Cloudinary.DEFAULT_VIDEO_PARAMS
* (Previously defined using option_consume() )
###
export DEFAULT_VIDEO_PARAMS =
  fallback_content: ''
  resource_type: "video"
  source_transformation: {}
  source_types: DEFAULT_VIDEO_SOURCE_TYPES
  transformation: []
  type: 'upload'

