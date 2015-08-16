
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
    @options = _.cloneDeep(options)
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

  # REVIEW options and transformation will become out of sync. consider having one dynamically retrieved from the other.
  getOptions: ()-> @options

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
    attr['src'] ?= new Cloudinary(@options).url( @publicId)
    attr

###*
* Creates an HTML (DOM) Video tag using Cloudinary as the source.
###
class VideoTag extends HtmlTag

  VIDEO_TAG_PARAMS = ['source_types','source_transformation','fallback_content', 'poster']
  DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv']
  DEFAULT_POSTER_OPTIONS = { format: 'jpg', resource_type: 'video' }

  ###*
  * Defaults values for parameters.
  *
  * (Previously defined using option_consume() )
  ###
  DEFAULT_VIDEO_PARAMS ={
    fallback_content: ''
    resource_type: "video"
    source_transformation: {}
    source_types: DEFAULT_VIDEO_SOURCE_TYPES
    transformation: []
    type: 'upload'
  }

  ###*
  * Creates an HTML (DOM) Video tag using Cloudinary as the source.
  * @param {String} [publicId]
  * @param {Object} [options]
  ###
  constructor: (publicId, options={})->
    options = _.defaults(_.cloneDeep(options), DEFAULT_VIDEO_PARAMS)

    super("video", publicId.replace(/\.(mp4|ogv|webm)$/, ''), options)

#    @whitelist.push("source_transformation", "source_types", "poster")
#    @fromOptions(options)

  setSourceTransformation: (value)->
    @sourceTransformation = value
    this

  setSourceTypes: (value)->
    @sourceType = value
    this

  setPoster: (value)->
    @poster = value
    this

  content: ()->
    sourceTypes = @options['source_types']
    sourceTransformation = @options['source_transformation']
    fallback = @options['fallback_content']

    if _.isArray(sourceTypes)
      innerTags = for srcType in sourceTypes
        transformation = sourceTransformation[srcType] or {}
        src = new Cloudinary(@options).url( "#{@publicId }",
                    _.defaults({ resource_type: 'video', format: srcType},
                               transformation,
                               @options))
        videoType = if srcType == 'ogv' then 'ogg' else srcType
        mimeType = 'video/' + videoType
        '<source ' + html_attrs(
          src: src
          type: mimeType) + '>'
    else
      innerTags = []
    innerTags.join('') + fallback

  attributes: ()->
    sourceTypes = @options['source_types']
    poster = @options['poster']

    if poster?
      if _.isPlainObject(poster)
        if poster.publicId?
          poster = new Cloudinary(@options).url( "#{poster.public_id }", poster)
        else
          poster = new Cloudinary(@options).url( this, @publicId, _.defaults( @options.poster, DEFAULT_POSTER_OPTIONS))
    else
      poster = new Cloudinary(@options).url(@publicId, _.defaults( @options, DEFAULT_POSTER_OPTIONS))

    attr = super() || []
    attr = _.omit(attr, VIDEO_TAG_PARAMS)
    unless  _.isArray(sourceTypes)
      attr["src"] = new Cloudinary(@options).url(@publicId,
                                                 _.defaults({ resource_type: 'video', format: sourceTypes},
                                                            @options))
    if poster?
      attr["poster"] = poster
    attr

# unless running on server side, export to the windows object
unless module?.exports? || exports?
  exports = window

exports.Cloudinary ?= {}
exports.Cloudinary.HtmlTag = HtmlTag
exports.Cloudinary.ImageTag = ImageTag
exports.Cloudinary.VideoTag = VideoTag
