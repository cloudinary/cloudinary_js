###*
 * Creates the namespace for Cloudinary
###
((root, factory) ->
  if (typeof define == 'function') && define.amd
    define  ['lodash'], factory
  else if typeof exports == 'object'
    module.exports = factory(require('lodash'))
  else
    root.cloudinary ||= {}
    root.cloudinary = factory(_)
)(this,  (_)->
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
  Layer: Layer
  TextLayer: TextLayer
  SubtitlesLayer: SubtitlesLayer
  Cloudinary: Cloudinary
)