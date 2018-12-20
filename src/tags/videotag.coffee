###*
 * Video Tag
 * Depends on 'tags/htmltag', 'util', 'cloudinary'
###
class VideoTag extends HtmlTag

  VIDEO_TAG_PARAMS = ['source_types', 'source_transformation', 'fallback_content', 'poster', 'sources']
  DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv']
  DEFAULT_VIDEO_SOURCES = [
    {
      type: "mp4",
      codecs: "hev1",
      transformations: {video_codec: "h265"}
    }
    {
      type: "webm",
      codecs: "vp9",
      transformations: {video_codec: "vp9"}
    }
    {
      type: "mp4",
      transformations: {video_codec: "auto"}
    }
    {
      type: "webm",
      transformations: {video_codec: "auto"}
    }
  ]
  DEFAULT_POSTER_OPTIONS = {format: 'jpg', resource_type: 'video'}

  ###*
   * Creates an HTML (DOM) Video tag using Cloudinary as the source.
   * @constructor VideoTag
   * @extends HtmlTag
   * @param {string} [publicId]
   * @param {Object} [options]
  ###
  constructor: (publicId, options = {})->
    options = Util.defaults({}, options, Cloudinary.DEFAULT_VIDEO_PARAMS)
    super("video", publicId.replace(/\.(mp4|ogv|webm)$/, ''), options)

  ###*
   * Set the transformation to apply on each source
   * @function VideoTag#setSourceTransformation
   * @param {Object} an object with pairs of source type and source transformation
   * @returns {VideoTag} Returns this instance for chaining purposes.
  ###
  setSourceTransformation: (value)->
    @transformation().sourceTransformation(value)
    this

  ###*
   * Set the source types to include in the video tag
   * @function VideoTag#setSourceTypes
   * @param {Array<string>} an array of source types
   * @returns {VideoTag} Returns this instance for chaining purposes.
  ###
  setSourceTypes: (value)->
    @transformation().sourceTypes(value)
    this

  ###*
   * Set the poster to be used in the video tag
   * @function VideoTag#setPoster
   * @param {string|Object} value
   * - string: a URL to use for the poster
   * - Object: transformation parameters to apply to the poster. May optionally include a public_id to use instead of the video public_id.
   * @returns {VideoTag} Returns this instance for chaining purposes.
  ###
  setPoster: (value)->
    @transformation().poster(value)
    this

  ###*
   * Set the content to use as fallback in the video tag
   * @function VideoTag#setFallbackContent
   * @param {string} value - the content to use, in HTML format
   * @returns {VideoTag} Returns this instance for chaining purposes.
  ###
  setFallbackContent: (value)->
    @transformation().fallbackContent(value)
    this

  content: ()->
    sourceTypes = @transformation().getValue('source_types')
    sourceTransformation = @transformation().getValue('source_transformation')
    fallback = @transformation().getValue('fallback_content')
    sources = @getOption('sources')
    cld = new Cloudinary(@getOptions())
    innerTags = []

    if Util.isArray(sources) and !Util.isEmpty(sources)
      innerTags = for sourceData in sources
        sourceType = sourceData.type
        codecs = sourceData.codecs
        transformations = sourceData.transformations or {}
        src = cld.url("#{@publicId}", Util.defaults({}, transformations, {resource_type: 'video', format: sourceType}))
        @createSourceTag(src, sourceType, codecs)
    else
      if Util.isEmpty(sourceTypes)
        sourceTypes = DEFAULT_VIDEO_SOURCE_TYPES

      if Util.isArray(sourceTypes)
        innerTags = for srcType in sourceTypes
          transformation = sourceTransformation[srcType] or {}
          src = cld.url("#{@publicId}", Util.defaults({}, transformation, {resource_type: 'video', format: srcType}))
          @createSourceTag(src, srcType)
    innerTags.join('') + fallback

  attributes: ()->
    sourceTypes = @getOption('source_types')
    sources = @getOption('sources')
    poster = @getOption('poster') ? {}

    if Util.isPlainObject(poster)
      defaults = if poster.public_id? then Cloudinary.DEFAULT_IMAGE_PARAMS else DEFAULT_POSTER_OPTIONS
      poster = new Cloudinary(@getOptions()).url(
        poster.public_id ? @publicId,
        Util.defaults({}, poster, defaults))

    attr = super() || {}
    attr = Util.omit(attr, VIDEO_TAG_PARAMS)

    # in case of empty sourceTypes - fallback to default source types is used.
    hasSourceTags = !Util.isEmpty(sources) or Util.isEmpty(sourceTypes) or Util.isArray(sourceTypes)
    unless hasSourceTags
      attr["src"] = new Cloudinary(@getOptions())
      .url(@publicId, {resource_type: 'video', format: sourceTypes})
    if poster?
      attr["poster"] = poster
    attr


  createSourceTag: (src, sourceType, codecs = null)->
    mimeType = null
    unless Util.isEmpty sourceType
      videoType = if sourceType == 'ogv' then 'ogg' else sourceType
      mimeType = 'video/' + videoType
      unless Util.isEmpty codecs
        codecsStr = if Util.isArray codecs then codecs.join ', ' else codecs
        mimeType += '; codecs=' + codecsStr
    "<source #{@htmlAttrs src: src, type: mimeType}>"

