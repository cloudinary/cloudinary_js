###*
 * Creates the namespace for Cloudinary
###
((root, factory) ->
  if (typeof define == 'function') && define.amd
    define ['jquery'], factory
  else if typeof exports == 'object'
    module.exports = factory(require('jquery'))
  else
    root.cloudinary ||= {}
    root.cloudinary = factory(jQuery)
    root.cloudinary
)(this,  (jQuery)->
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