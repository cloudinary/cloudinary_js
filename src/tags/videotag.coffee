###*
 * Video Tag
 * Depends on 'tags/htmltag', 'util', 'cloudinary'
###
class VideoTag extends HtmlTag

  VIDEO_TAG_PARAMS = ['source_types', 'source_transformation', 'fallback_content', 'poster']
  DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv']
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

    if Util.isArray(sourceTypes)
      cld = new Cloudinary(@getOptions())
      innerTags = for srcType in sourceTypes
        transformation = sourceTransformation[srcType] or {}
        src = cld.url("#{@publicId }", Util.defaults({}, transformation, {resource_type: 'video', format: srcType}))
        videoType = if srcType == 'ogv' then 'ogg' else srcType
        mimeType = 'video/' + videoType
        "<source #{@htmlAttrs(src: src, type: mimeType)}>"
    else
      innerTags = []
    innerTags.join('') + fallback

  attributes: ()->
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
