
toAttribute = (key, value) ->
  if !value
    undefined
  else if value == true
    key
  else
    "#{key}=\"#{value}\""

###*
* combine key and value from the `attr` to generate an HTML tag attributes string.
* `Transformation::toHtmlTagOptions` is used to filter out transformation and configuration keys.
* @param {Object} attr
* @return {String} the attributes in the format `'key1="value1" key2="value2"'`
###
html_attrs = (attrs) ->
  pairs = _.map(attrs, (value, key) -> toAttribute( key, value))
  pairs.sort()
  pairs.filter((pair) ->
                 pair
              ).join ' '

###*
  * Represents an HTML (DOM) tag
###
class HtmlTag
  ###*
    * Represents an HTML (DOM) tag
    * Usage: tag = new HtmlTag( 'div', { 'width': 10})
    * @param {String} name - the name of the tag
    * @param {String} [publicId]
    * @param {Object} options
  ###
  constructor: (name, publicId, options)->
    @name = name
    @publicId = publicId
    if !options?
      if _.isPlainObject(publicId)
        options = publicId
        @publicId = undefined
      else
        options = {}
    transformation = new Transformation(options)
    transformation.setParent(this)
    @transformation = ()->
      transformation

  ###*
   * Convenience constructor
   * Creates a new instance of an HTML (DOM) tag
   * Usage: tag = HtmlTag.new( 'div', { 'width': 10})
   * @param {String} name - the name of the tag
   * @param {String} [publicId]
   * @param {Object} options
  ###
  @new = (name, publicId, options)->
    new @(name, publicId, options)

  ###*
   * Get all options related to this tag.
   * @returns {Object} the options
   *
  ###
  getOptions: ()-> @transformation().toOptions()

  ###*
   * Get the value of option `name`
   * @param {String} name - the name of the option
   * @returns the value of the option
   *
  ###
  getOption: (name)-> @transformation().getValue(name)

  ###*
   * Get the attributes of the tag.
   * The attributes are be computed from the options every time this method is invoked.
   * @returns {Object} attributes
  ###
  attributes: ()->
    @transformation().toHtmlAttributes()

  setAttr: ( name, value)->
    @transformation().set( name, value)
    this

  getAttr: (name)->
    @attributes()[name]

  removeAttr: (name)->
    delete @attributes()[name]

  content: ()->
    ""

  openTag: ()->
    "<#{@name} #{html_attrs(@attributes())}>"

  closeTag:()->
    "</#{@name}>"

  content: ()->
    ""

  toHtml: ()->
    @openTag() + @content()+ @closeTag()

###*
* Creates an HTML (DOM) Image tag using Cloudinary as the source.
###
class ImageTag extends HtmlTag

  ###*
  * Creates an HTML (DOM) Image tag using Cloudinary as the source.
  * @param {String} [publicId]
  * @param {Object} [options]
  ###
  constructor: (publicId, options={})->
    super("img", publicId, options)

  closeTag: ()->
    ""

  attributes: ()->
    attr = super() || []
    attr['src'] ?= new Cloudinary(@getOptions()).url( @publicId)
    attr

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
    options = _.defaults({}, options, Cloudinary.DEFAULT_VIDEO_PARAMS)

    super("video", publicId.replace(/\.(mp4|ogv|webm)$/, ''), options)

#    @whitelist.push("source_transformation", "source_types", "poster")
#    @fromOptions(options)

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

    if _.isArray(sourceTypes)
      cld = new Cloudinary(@getOptions())
      innerTags = for srcType in sourceTypes
        transformation = sourceTransformation[srcType] or {}
        src = cld.url( "#{@publicId }", _.defaults({}, transformation, { resource_type: 'video', format: srcType}))
        videoType = if srcType == 'ogv' then 'ogg' else srcType
        mimeType = 'video/' + videoType
        "<source #{html_attrs(src: src, type: mimeType)}>"
    else
      innerTags = []
    innerTags.join('') + fallback

  attributes: ()->
    sourceTypes = @getOption('source_types')
    poster = @getOption('poster')

    if poster?
      if _.isPlainObject(poster)
        if poster.public_id?
          poster = new Cloudinary(@getOptions()).url( "#{poster.public_id }", _.defaults({}, poster, Cloudinary.DEFAULT_IMAGE_PARAMS))
        else
          poster = new Cloudinary(@getOptions()).url( @publicId, _.defaults( {}, poster, DEFAULT_POSTER_OPTIONS))
    else
      poster = new Cloudinary(@getOptions()).url(@publicId, DEFAULT_POSTER_OPTIONS)

    attr = super() || []
    attr = _.omit(attr, VIDEO_TAG_PARAMS)
    unless  _.isArray(sourceTypes)
      attr["src"] = new Cloudinary(@getOptions()).url(@publicId,
                                                 _.defaults({ resource_type: 'video', format: sourceTypes},
                                                            @getOptions()))
    if poster?
      attr["poster"] = poster
    attr

# unless running on server side, export to the windows object
unless module?.exports? || exports?
  exports = window

exports.Cloudinary ?= {}
exports.Cloudinary::imageTag = (publicId, options)->
  options = _.defaults({}, options, @config())
  new ImageTag(publicId, options)
exports.Cloudinary::videoTag = (publicId, options)->
  options = _.defaults({}, options, @config())
  new VideoTag(publicId, options)

exports.Cloudinary.HtmlTag = HtmlTag
exports.Cloudinary.ImageTag = ImageTag
exports.Cloudinary.VideoTag = VideoTag
