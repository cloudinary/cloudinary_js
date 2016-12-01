###*
 * Creates the namespace for Cloudinary
###
((root, factory) ->
  if (typeof define == 'function') && define.amd
    define ['utf8_encode', 'crc32', 'util', 'transformation', 'configuration', 'tags/htmltag', 'tags/imagetag', 'tags/videotag', 'cloudinary', 'cloudinaryjquery', 'jquery-file-upload'], factory
  else if typeof exports == 'object'
    module.exports = factory(require('./utf8_encode'), require('./crc32'), require('./util'), require('./transformation'), require('./configuration'), require('./tags/htmltag'), require('./tags/imagetag'), require('./tags/videotag'), require('./cloudinary'), require('./cloudinaryjquery'), require('jquery-file-upload'))
  else
    root.cloudinary ||= {}
    root.cloudinary = factory(root.cloudinary.utf8_encode, root.cloudinary.crc32, root.cloudinary.Util, root.cloudinary.Transformation, root.cloudinary.Configuration, root.cloudinary.HtmlTag, root.cloudinary.ImageTag, root.cloudinary.VideoTag, root.cloudinary.Cloudinary, root.cloudinary.CloudinaryJQuery)

)(this,  (utf8_encode, crc32, Util, Transformation, Configuration, HtmlTag, ImageTag, VideoTag, Cloudinary, CloudinaryJQuery )->
  utf8_encode: utf8_encode
  crc32: crc32
  Util: Util
  Transformation: Transformation
  Condition: Condition
  Configuration: Configuration
  HtmlTag: HtmlTag
  ImageTag: ImageTag
  VideoTag: VideoTag
  ClientHintsMetaTag: ClientHintsMetaTag
  Cloudinary: Cloudinary
  CloudinaryJQuery: CloudinaryJQuery
)
