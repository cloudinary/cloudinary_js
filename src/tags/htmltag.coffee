((root, factory) ->
  if (typeof define == 'function') && define.amd
    define ['transformation', 'util'], factory
  else if typeof exports == 'object'
    module.exports = factory(require('transformation'), require('util'))
  else
    root.cloudinary ||= {}
    root.cloudinary.HtmlTag = factory(root.cloudinary.Transformation, root.cloudinary.Util)

)(this,  (Transformation, Util)->
  ###*
    * Represents an HTML (DOM) tag
  ###
  class HtmlTag
    ###*
     * Represents an HTML (DOM) tag
     * @constructor HtmlTag
     * @example tag = new HtmlTag( 'div', { 'width': 10})
     * @param {String} name - the name of the tag
     * @param {String} [publicId]
     * @param {Object} options
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
     * @example tag = HtmlTag.new( 'div', { 'width': 10})
     * @param {String} name - the name of the tag
     * @param {String} [publicId]
     * @param {Object} options
     * @return {HtmlTag}
    ###
    @new = (name, publicId, options)->
      new @(name, publicId, options)


    ###*
     * Represent the given key and value as an HTML attribute.
     * @function HtmlTag#toAttribute
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
      pairs = (toAttribute( key, value) for key, value of attrs when value).sort().join(' ')

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
      @transformation().remove(name)

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

    toDOM: ()->
      throw "Can't create DOM if document is not present!" unless Util.isFunction( document?.createElement)
      element = document.createElement(@name)
      element[name] = value for name, value of @attributes()
      element

  HtmlTag
)