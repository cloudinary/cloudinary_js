
###*
 *  A single transformation.
 *
 *  @example
 *  t = new Transformation();
 *  t.angle(20).crop("scale").width("auto");
 *
 *  // or
 *
 *  t = new Transformation( {angle: 20, crop: "scale", width: "auto"});
 *  @class
###
class TransformationBase
  # TODO add chains (slashes)

  constructor: (options = {}) ->
    chainedTo = undefined
    trans = {}

    ###*
     * Return an options object that can be used to create an identical Transformation
     * @return {Object} a plain object representing this transformation
    ###
    @toOptions = ()->
      opt= {}
      for key, value of trans
        opt[key]= value.origValue
      for key, value of @otherOptions when value != undefined
        opt[key]= value
      opt

    ###*
     * Set a parent for this object for chaining purposes.
     * @param {Object} object - the parent to be assigned to
     * @returns {Transformation} - returns this instance for chaining purposes.
    ###
    @setParent = (object)->
      chainedTo = object
      @fromOptions( object.toOptions?())
      this

    ###*
     * Returns the parent of this object in the chain
     * @return {Object} the parent of this object if any
    ###
    @getParent = ()->
      chainedTo

    ###
    # Helper methods to create parameter methods
    # These methods are required because `trans` is a private member of `TransformationBase`
    ###

    @param = (value, name, abbr, defaultValue, process) ->
      unless process?
        if Util.isFunction(defaultValue)
          process = defaultValue
        else
          process = Util.identity
      trans[name] = new Param(name, abbr, process).set(value)
      @

    @rawParam = (value, name, abbr, defaultValue, process = Util.identity) ->
      process = defaultValue if Util.isFunction(defaultValue) && !process?
      trans[name] = new RawParam(name, abbr, process).set(value)
      @

    @rangeParam = (value, name, abbr, defaultValue, process = Util.identity) ->
      process = defaultValue if Util.isFunction(defaultValue) && !process?
      trans[name] = new RangeParam(name, abbr, process).set(value)
      @

    @arrayParam = (value, name, abbr, sep = ":", defaultValue = [], process = Util.identity) ->
      process = defaultValue if Util.isFunction(defaultValue) && !process?
      trans[name] = new ArrayParam(name, abbr, sep, process).set(value)
      @

    @transformationParam = (value, name, abbr, sep = ".", defaultValue, process = Util.identity) ->
      process = defaultValue if Util.isFunction(defaultValue) && !process?
      trans[name] = new TransformationParam(name, abbr, sep, process).set(value)
      @

    ###*
     * Get the value associated with the given name.
     * @param {string} name - the name of the parameter
     * @return {*} the processed value associated with the given name
     * @description Use {@link get}.origValue for the value originally provided for the parameter
    ###
    @getValue = (name)->
      trans[name]?.value() ? @otherOptions[name]

    ###*
     * Get the parameter object for the given parameter name
     * @param {String} name the name of the transformation parameter
     * @returns {Param} the param object for the given name, or undefined
    ###
    @get = (name)->
      trans[name]

    @remove = (name)->
      switch
        when trans[name]?
          temp = trans[name]
          delete trans[name]
          temp
        when @otherOptions[name]?
          temp = @otherOptions[name]
          delete @otherOptions[name]
          temp
        else
          null


    @keys = ()->
      (Util.snakeCase(key) for key of trans).sort()


    @toPlainObject = ()-> # FIXME recursive
      hash = {}
      hash[key] = trans[key].value() for key of trans
      hash

    @chain = ()->
      tr = new @constructor( @toOptions())
      trans = []
      @otherOptions = {}
      @set("transformation", tr)

    @otherOptions = {}

    ###*
     * Transformation Class methods.
     * This is a list of the parameters defined in Transformation.
     * Values are camelCased.
     * @type {Array<String>}
    ###
    @methods = Util.difference(
      Util.functions(Transformation.prototype),
      Util.functions(TransformationBase.prototype)
    )

    ###*
     * Parameters that are filtered out before passing the options to an HTML tag.
     * The list of parameters is `Transformation::methods` and `Configuration::CONFIG_PARAMS`
     * @type {Array<string>}
     * @see toHtmlAttributes
    ###
    @PARAM_NAMES = (Util.snakeCase(m) for m in @methods).concat( Cloudinary.Configuration.CONFIG_PARAMS)


    # Finished constructing the instance, now process the options

    @fromOptions(options) unless Util.isEmpty(options)

  ###*
   * Merge the provided options with own's options
   * @param {Object} [options={}] key-value list of options
   * @returns {Transformation} this instance for chaining
  ###
  fromOptions: (options) ->
    options or= {}
    options = {transformation: options } if Util.isString(options) || Util.isArray(options) || options instanceof Transformation
    options = Util.cloneDeep(options, (value) ->
      if value instanceof Transformation
        new value.constructor( value.toOptions())
    )
    for key, opt of options
      @set key, opt
    this

  ###*
   * Set a parameter.
   * The parameter name `key` is converted to
   * @param {String} key - the name of the parameter
   * @param {*} value - the value of the parameter
   * @returns {Transformation} this instance for chaining
  ###
  set: (key, value)->
    camelKey = Util.camelCase( key)
    if Util.contains( @methods, camelKey)
      this[camelKey](value)
    else
      @otherOptions[key] = value
    this

  hasLayer: ()->
    @getValue("overlay") || @getValue("underlay")

  serialize: ->
    resultArray = []
    paramList = @keys()
    transformations = @get("transformation")?.serialize()
    paramList = Util.without(paramList, "transformation")
    transformationList = (@get(t)?.serialize() for t in paramList )
    switch
      when Util.isString(transformations)
        transformationList.push( transformations)
      when Util.isArray( transformations)
        resultArray = (transformations)
    transformationString = (
      for value in transformationList when Util.isArray(value) &&!Util.isEmpty(value) || !Util.isArray(value) && value
        value
    ).sort().join(',')
    resultArray.push(transformationString) unless Util.isEmpty(transformationString)
    Util.compact(resultArray).join('/')

  listNames: ->
    @methods


  ###*
   * Returns attributes for an HTML tag.
   * @return PlainObject
  ###
  toHtmlAttributes: ()->
    options = {}
    options[key] = value for key, value of @otherOptions when  !Util.contains(@PARAM_NAMES, key)
    options[key] = @get(key).value for key in Util.difference(@keys(), @PARAM_NAMES)
    # convert all "html_key" to "key" with the same value
    for k in @keys() when /^html_/.exec(k)
      options[k.substr(5)] = @getValue(k)

    unless @hasLayer()|| @getValue("angle") || Util.contains( ["fit", "limit", "lfill"],@getValue("crop"))
      width = @get("width")?.origValue
      height = @get("height")?.origValue
      if parseFloat(width) >= 1.0
        options['width'] ?= width
      if parseFloat(height) >= 1.0
        options['height'] ?= height
    options

  isValidParamName: (name) ->
    @methods.indexOf(Util.camelCase(name)) >= 0

  toHtml: ()->
    @getParent()?.toHtml?()

  toString: ()->
    @serialize()

class Transformation  extends TransformationBase

  @new = (args)-> new Transformation(args)

  constructor: (options = {})->
    super(options)

  ###
    Transformation Parameters
  ###

  angle: (value)->            @arrayParam value, "angle", "a", "."
  audioCodec: (value)->      @param value, "audio_codec", "ac"
  audioFrequency: (value)->  @param value, "audio_frequency", "af"
  background: (value)->       @param value, "background", "b", Param.norm_color
  bitRate: (value)->         @param value, "bit_rate", "br"
  border: (value)->           @param value, "border", "bo", (border) ->
    if (Util.isPlainObject(border))
      border = Util.assign({}, {color: "black", width: 2}, border)
      "#{border.width}px_solid_#{Param.norm_color(border.color)}"
    else
      border
  color: (value)->            @param value, "color", "co", Param.norm_color
  colorSpace: (value)->      @param value, "color_space", "cs"
  crop: (value)->             @param value, "crop", "c"
  defaultImage: (value)->    @param value, "default_image", "d"
  delay: (value)->            @param value, "delay", "l"
  density: (value)->          @param value, "density", "dn"
  duration: (value)->         @rangeParam value, "duration", "du"
  dpr: (value)->              @param value, "dpr", "dpr", (dpr) ->
    dpr = dpr.toString()
    if (dpr == "auto")
      "1.0"
    else if (dpr?.match(/^\d+$/))
      dpr + ".0"
    else
      dpr
  effect: (value)->           @arrayParam value,  "effect", "e", ":"
  endOffset: (value)->       @rangeParam value,  "end_offset", "eo"
  fallbackContent: (value)->     @param value,   "fallback_content"
  fetchFormat: (value)->     @param value,       "fetch_format", "f"
  format: (value)->           @param value,       "format"
  flags: (value)->            @arrayParam value,  "flags", "fl", "."
  gravity: (value)->          @param value,       "gravity", "g"
  height: (value)->           @param value,       "height", "h", =>
    if ( @getValue("crop") || @getValue("overlay") || @getValue("underlay"))
      value
    else
      null
  htmlHeight: (value)->      @param value, "html_height"
  htmlWidth:(value)->        @param value, "html_width"
  offset: (value)->
    [start_o, end_o] = if( Util.isFunction(value?.split))
      value.split('..')
    else if Util.isArray(value)
      value
    else
      [null,null]
    @startOffset(start_o) if start_o?
    @endOffset(end_o) if end_o?
  opacity: (value)->          @param value, "opacity",  "o"
  overlay: (value)->          @param value, "overlay",  "l"
  page: (value)->             @param value, "page",     "pg"
  poster: (value)->           @param value, "poster"
  prefix: (value)->           @param value, "prefix",   "p"
  quality: (value)->          @param value, "quality",  "q"
  radius: (value)->           @param value, "radius",   "r"
  rawTransformation: (value)-> @rawParam value, "raw_transformation"
  size: (value)->
    if( Util.isFunction(value?.split))
      [width, height] = value.split('x')
      @width(width)
      @height(height)
  sourceTypes: (value)->          @param value, "source_types"
  sourceTransformation: (value)->   @param value, "source_transformation"
  startOffset: (value)->     @rangeParam value, "start_offset", "so"
  transformation: (value)->   @transformationParam value, "transformation", "t"
  underlay: (value)->         @param value, "underlay", "u"
  videoCodec: (value)->      @param value, "video_codec", "vc", process_video_params
  videoSampling: (value)->   @param value, "video_sampling", "vs"
  width: (value)->            @param value, "width", "w", =>
    if ( @getValue("crop") || @getValue("overlay") || @getValue("underlay"))
      value
    else
      null
  x: (value)->                @param value, "x", "x"
  y: (value)->                @param value, "y", "y"
  zoom: (value)->             @param value, "zoom", "z"


# unless running on server side, export to the windows object
unless module?.exports? || exports?
  exports = window

exports.Cloudinary ?= {}
exports.Cloudinary.Transformation = Transformation
exports.Cloudinary.TransformationBase = TransformationBase
