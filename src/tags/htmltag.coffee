###*
 * Generic HTML tag
 * Depends on 'transformation', 'util'
###
class HtmlTag
  ###*
   * Represents an HTML (DOM) tag
   * @constructor HtmlTag
   * @param {string} name - the name of the tag
   * @param {string} [publicId]
   * @param {Object} options
   * @example tag = new HtmlTag( 'div', { 'width': 10})
  ###
  constructor: (name, publicId, options)->
    @name = name
    @publicId = publicId
    if !options?
      if Util.isPlainObject(publicId)
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
   * @function HtmlTag.new
   * @param {string} name - the name of the tag
   * @param {string} [publicId]
   * @param {Object} options
   * @return {HtmlTag}
   * @example tag = HtmlTag.new( 'div', { 'width': 10})
  ###
  @new = (name, publicId, options)->
    new @(name, publicId, options)

  ###*
   * Represent the given key and value as an HTML attribute.
   * @function HtmlTag#toAttribute
   * @protected
   * @param {string} key - attribute name
   * @param {*|boolean} value - the value of the attribute. If the value is boolean `true`, return the key only.
   * @returns {string} the attribute  
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
   * @protected
   * @param {Object} attrs
   * @return {string} the attributes in the format `'key1="value1" key2="value2"'`
   * @ignore
  ###
  htmlAttrs: (attrs) ->
    pairs = (toAttribute( key, value) for key, value of attrs when value).sort().join(' ')

  ###*
   * Get all options related to this tag.
   * @function HtmlTag#getOptions
   * @returns {Object} the options
   *
  ###
  getOptions: ()-> @transformation().toOptions()

  ###*
   * Get the value of option `name`
   * @function HtmlTag#getOption
   * @param {string} name - the name of the option
   * @returns {*} Returns the value of the option
   *
  ###
  getOption: (name)-> @transformation().getValue(name)

  ###*
   * Get the attributes of the tag.
   * @function HtmlTag#attributes
   * @returns {Object} attributes
  ###
  attributes: ()->
    # The attributes are be computed from the options every time this method is invoked.
    @transformation().toHtmlAttributes()

  ###*
   * Set a tag attribute named `name` to `value`
   * @function HtmlTag#setAttr
   * @param {string} name - the name of the attribute
   * @param {string} value - the value of the attribute
  ###
  setAttr: ( name, value)->
    @transformation().set( "html_#{name}", value)
    this

  ###*
   * Get the value of the tag attribute `name`
   * @function HtmlTag#getAttr
   * @param {string} name - the name of the attribute
   * @returns {*}
  ###
  getAttr: (name)->
    @attributes()["html_#{name}"] || @attributes()[name]

  ###*
   * Remove the tag attributed named `name`
   * @function HtmlTag#removeAttr
   * @param {string} name - the name of the attribute
   * @returns {*}
  ###
  removeAttr: (name)->
    @transformation().remove("html_#{name}") ? @transformation().remove(name)

  ###*
   * @function HtmlTag#content
   * @protected
   * @ignore
  ###
  content: ()->
    ""

  ###*
   * @function HtmlTag#openTag
   * @protected
   * @ignore
  ###
  openTag: ()->
    "<#{@name} #{@htmlAttrs(@attributes())}>"

  ###*
   * @function HtmlTag#closeTag
   * @protected
   * @ignore
  ###
  closeTag:()->
    "</#{@name}>"

  ###*
   * Generates an HTML representation of the tag.
   * @function HtmlTag#toHtml
   * @returns {string} Returns HTML in string format
  ###
  toHtml: ()->
    @openTag() + @content()+ @closeTag()

  ###*
   * Creates a DOM object representing the tag.
   * @function HtmlTag#toDOM
   * @returns {Element}
  ###
  toDOM: ()->
    throw "Can't create DOM if document is not present!" unless Util.isFunction( document?.createElement)
    element = document.createElement(@name)
    element[name] = value for name, value of @attributes()
    element

  @isResponsive: (tag, responsiveClass)->
    dataSrc = Util.getData(tag, 'src-cache') or Util.getData(tag, 'src')
    Util.hasClass(tag, responsiveClass) and /\bw_auto\b/.exec(dataSrc)