((root, factory) ->
  if (typeof define == 'function') && define.amd
    define ['tags/htmltag', 'util', 'cloudinary', 'require'], factory
  else if typeof exports == 'object'
    module.exports = factory(require('tags/htmltag'), require('util'), require('cloudinary'), require)
  else
    root.cloudinary ||= {}
    root.cloudinary.VideoTag = factory(root.cloudinary.HtmlTag, root.cloudinary.Util, root.cloudinary.Cloudinary, ()-> root.cloudinary.Cloudinary)
)(this,  (HtmlTag, Util, Cloudinary, require)->

  ###*
  * Creates an HTML (DOM) Video tag using Cloudinary as the source.
  ###
  class VideoTag extends HtmlTag

    VIDEO_TAG_PARAMS = ['source_types','source_transformation','fallback_content', 'poster']
    DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv']
    DEFAULT_POSTER_OPTIONS = { format: 'jpg', resource_type: 'video' }

    ###*
     * Creates an HTML (DOM) Video tag using Cloudinary as the source.
     * @constructor VideoTag
     * @param {String} [publicId]
     * @param {Object} [options]
    ###
    constructor: (publicId, options={})->
      Cloudinary ||= require('cloudinary')
      options = Util.defaults({}, options, Cloudinary.DEFAULT_VIDEO_PARAMS)
      super("video", publicId.replace(/\.(mp4|ogv|webm)$/, ''), options)

    setSourceTransformation: (value)->
      @transformation().sourceTransformation(value)
      this

    setSourceTypes: (value)->
      @transformation().sourceTypes(value)
      this

    setPoster: (value)->
      @transformation().poster(value)
      this

    setFallbackContent: (value)->
      @transformation().fallbackContent(value)
      this

    content: ()->
      sourceTypes = @transformation().getValue('source_types')
      sourceTransformation = @transformation().getValue('source_transformation')
      fallback = @transformation().getValue('fallback_content')
      Cloudinary ||= require('cloudinary')

      if Util.isArray(sourceTypes)
        cld = new Cloudinary(@getOptions())
        innerTags = for srcType in sourceTypes
          transformation = sourceTransformation[srcType] or {}
          src = cld.url( "#{@publicId }", Util.defaults({}, transformation, { resource_type: 'video', format: srcType}))
          videoType = if srcType == 'ogv' then 'ogg' else srcType
          mimeType = 'video/' + videoType
          "<source #{@htmlAttrs(src: src, type: mimeType)}>"
      else
        innerTags = []
      innerTags.join('') + fallback

    attributes: ()->
      Cloudinary ||= require('cloudinary')
      sourceTypes = @getOption('source_types')
      poster = @getOption('poster') ? {}

      if Util.isPlainObject(poster)
        defaults = if poster.public_id? then Cloudinary.DEFAULT_IMAGE_PARAMS else DEFAULT_POSTER_OPTIONS
        poster = new Cloudinary(@getOptions()).url(
          poster.public_id ? @publicId,
          Util.defaults({}, poster, defaults))

      attr = super() || []
      attr = a for a in attr when !Util.contains(VIDEO_TAG_PARAMS)
      unless  Util.isArray(sourceTypes)
        attr["src"] = new Cloudinary(@getOptions())
          .url(@publicId, {resource_type: 'video', format: sourceTypes})
      if poster?
        attr["poster"] = poster
      attr

  VideoTag
)