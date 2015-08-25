
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
   * Represent the given key and value as an HTML attribute.
   * @param {String} key - attribute name
   * @param {*|boolean} value - the value of the attribute. If the value is boolean `true`, return the key only.
   * @returns {String} the attribute
   *
  ###
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
  htmlAttrs: (attrs) ->
    pairs = _.map(attrs, (value, key) -> toAttribute( key, value))
    pairs.sort()
    pairs.filter((pair) ->
                   pair
                ).join ' '

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
    "<#{@name} #{@htmlAttrs(@attributes())}>"

  closeTag:()->
    "</#{@name}>"

  content: ()->
    ""

  toHtml: ()->
    @openTag() + @content()+ @closeTag()

# unless running on server side, export to the windows object
unless module?.exports? || exports?
  exports = window

exports.Cloudinary ?= {}

exports.Cloudinary.HtmlTag = HtmlTag
