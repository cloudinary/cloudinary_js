
###*
* Creates an HTML (DOM) Video tag using Cloudinary as the source.
###
class VideoTag extends HtmlTag

  VIDEO_TAG_PARAMS = ['source_types','source_transformation','fallback_content', 'poster']
  DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv']
  DEFAULT_POSTER_OPTIONS = { format: 'jpg', resource_type: 'video' }


  ###*
   * Creates an HTML (DOM) Video tag using Cloudinary as the source.
   * @param {String} [publicId]
   * @param {Object} [options]
  ###
  constructor: (publicId, options={})->
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
    sourceTypes = @getOption('source_types')
    poster = @getOption('poster') ? {}

    if _.isPlainObject(poster)
      defaults = if poster.public_id? then Cloudinary.DEFAULT_IMAGE_PARAMS else DEFAULT_POSTER_OPTIONS
      poster = new Cloudinary(@getOptions()).url(
        poster.public_id ? @publicId,
        Util.defaults({}, poster, defaults))

    attr = super() || []
    attr = _.omit(attr, VIDEO_TAG_PARAMS)
    unless  Util.isArray(sourceTypes)
      attr["src"] = new Cloudinary(@getOptions())
        .url(@publicId, {resource_type: 'video', format: sourceTypes})
    if poster?
      attr["poster"] = poster
    attr

# unless running on server side, export to the windows object
unless module?.exports? || exports?
  exports = window

exports.Cloudinary ?= {}
exports.Cloudinary::videoTag = (publicId, options)->
  options = Util.defaults({}, options, @config())
  new VideoTag(publicId, options)

exports.Cloudinary.VideoTag = VideoTag
