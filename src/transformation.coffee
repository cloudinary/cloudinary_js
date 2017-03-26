###*
 * TransformationBase
 * Depends on 'configuration', 'parameters','util'
 * @internal
###

class TransformationBase
  VAR_NAME_RE = /^\$[a-zA-Z0-9]+$/
  trans_separator: '/'
  param_separator: ','
  lastArgCallback = (args)->
    callback = args?[args.length - 1]
    if(Util.isFunction(callback))
      callback
    else
      undefined

  ###*
   * The base class for transformations.
   * Members of this class are documented as belonging to the {@link Transformation} class for convenience.
   * @class TransformationBase
  ###
  constructor: (options = {}) ->
    ###* @private ###
    parent = undefined
    ###* @private ###
    trans = {}



    ###*
     * Return an options object that can be used to create an identical Transformation
     * @function Transformation#toOptions
     * @return {Object} Returns a plain object representing this transformation
    ###
    @toOptions ||= (withChain = true)->
      opt= {}
      for key, value of trans
        opt[key]= value.origValue
      for key, value of @otherOptions when value != undefined
        opt[key]= value
      if withChain && !Util.isEmpty(@chained)
        list = for tr in @chained
          tr.toOptions()
        list.push(opt)
        opt = {}
        for key, value of @otherOptions when value != undefined
          opt[key]= value
        opt.transformation= list
      opt

    ###*
     * Set a parent for this object for chaining purposes.
     *
     * @function Transformation#setParent
     * @param {Object} object - the parent to be assigned to
     * @returns {Transformation} Returns this instance for chaining purposes.
    ###
    @setParent ||= (object)->
      parent = object
      @fromOptions( object.toOptions?()) if object?
      this

    ###*
     * Returns the parent of this object in the chain
     * @function Transformation#getParent
     * @protected
     * @return {Object} Returns the parent of this object if there is any
    ###
    @getParent ||= ()->
      parent

    #
    # Helper methods to create parameter methods
    # These methods are defined here because they access `trans` which is
    # a private member of `TransformationBase`
    #

    ###* @protected ###
    @param ||= (value, name, abbr, defaultValue, process) ->
      unless process?
        if Util.isFunction(defaultValue)
          process = defaultValue
        else
          process = Util.identity
      trans[name] = new Param(name, abbr, process).set(value)
      @

    ###* @protected ###
    @rawParam ||= (value, name, abbr, defaultValue, process = Util.identity) ->
      process = lastArgCallback(arguments)
      trans[name] = new RawParam(name, abbr, process).set(value)
      @

    ###* @protected ###
    @rangeParam ||= (value, name, abbr, defaultValue, process = Util.identity) ->
      process = lastArgCallback(arguments)
      trans[name] = new RangeParam(name, abbr, process).set(value)
      @

    ###* @protected ###
    @arrayParam ||= (value, name, abbr, sep = ":", defaultValue = [], process = Util.identity) ->
      process = lastArgCallback(arguments)
      trans[name] = new ArrayParam(name, abbr, sep, process).set(value)
      @

    ###* @protected ###
    @transformationParam ||= (value, name, abbr, sep = ".", defaultValue, process = Util.identity) ->
      process = lastArgCallback(arguments)
      trans[name] = new TransformationParam(name, abbr, sep, process).set(value)
      @

    @layerParam ||= (value, name, abbr) ->
       trans[name] = new LayerParam(name, abbr).set(value)
       @

    #
    # End Helper methods
    #

    ###*
     * Get the value associated with the given name.
     * @function Transformation#getValue
     * @param {string} name - the name of the parameter
     * @return {*} the processed value associated with the given name
     * @description Use {@link get}.origValue for the value originally provided for the parameter
    ###
    @getValue ||= (name)->
      trans[name]?.value() ? @otherOptions[name]

    ###*
     * Get the parameter object for the given parameter name
     * @function Transformation#get
     * @param {string} name the name of the transformation parameter
     * @returns {Param} the param object for the given name, or undefined
    ###
    @get ||= (name)->
      trans[name]

    ###*
     * Remove a transformation option from the transformation.
     * @function Transformation#remove
     * @param {string} name - the name of the option to remove
     * @return {*} Returns the option that was removed or null if no option by that name was found. The type of the
     *              returned value depends on the value.
    ###
    @remove ||= (name)->
      switch
        when trans[name]?
          temp = trans[name]
          delete trans[name]
          temp.origValue
        when @otherOptions[name]?
          temp = @otherOptions[name]
          delete @otherOptions[name]
          temp
        else
          null

    ###*
     * Return an array of all the keys (option names) in the transformation.
     * @return {Array<string>} the keys in snakeCase format
    ###
    @keys ||= ()->
      ((if key.match(VAR_NAME_RE) then key else Util.snakeCase(key)) for key of trans when key?).sort()

    ###*
     * Returns a plain object representation of the transformation. Values are processed.
     * @function Transformation#toPlainObject
     * @return {Object} the transformation options as plain object
    ###
    @toPlainObject ||= ()->
      hash = {}
      for key of trans
        hash[key] = trans[key].value()
        hash[key] = Util.cloneDeep(hash[key]) if Util.isPlainObject(hash[key])
      unless Util.isEmpty(@chained)
        list = for tr in @chained
          tr.toPlainObject()
        list.push(hash)
        hash = {transformation: list}
      hash

    ###*
     * Complete the current transformation and chain to a new one.
     * In the URL, transformations are chained together by slashes.
     * @function Transformation#chain
     * @return {Transformation} Returns this transformation for chaining
     * @example
     * var tr = cloudinary.Transformation.new();
     * tr.width(10).crop('fit').chain().angle(15).serialize()
     * // produces "c_fit,w_10/a_15"
    ###
    @chain ||= ()->
      names = Object.getOwnPropertyNames(trans)
      unless names.length == 0
        tr = new @constructor(@toOptions(false))
        @resetTransformations()
        @chained.push(tr)
      @


    @resetTransformations ||= ()->
      trans = {}
      @

    @otherOptions ||= {}

    @chained = []

    # Finished constructing the instance, now process the options

    @fromOptions(options) unless Util.isEmpty(options)

  ###*
   * Merge the provided options with own's options
   * @param {Object} [options={}] key-value list of options
   * @returns {Transformation} Returns this instance for chaining
  ###
  fromOptions: (options) ->
    if options instanceof TransformationBase
      @fromTransformation(options)
    else
      options or= {}
      options = {transformation: options } if Util.isString(options) || Util.isArray(options)
      options = Util.cloneDeep(options, (value) ->
        if value instanceof TransformationBase
          new value.constructor( value.toOptions())
      )
      # Handling of "if" statements precedes other options as it creates a chained transformation
      if options["if"]
        @set "if", options["if"]
        delete options["if"]
      for key, opt of options
        if key.match(VAR_NAME_RE)
          @set( 'variable', key, opt) unless key == '$attr'
        else
          @set key, opt
    this

  fromTransformation: (other) ->
    if other instanceof TransformationBase
      for key in other.keys()
        @set(key, other.get(key).origValue)
    this

  ###*
   * Set a parameter.
   * The parameter name `key` is converted to
   * @param {string} key - the name of the parameter
   * @param {*} value - the value of the parameter
   * @returns {Transformation} Returns this instance for chaining
  ###
  set: (key, values...)->
    camelKey = Util.camelCase( key)
    if Util.contains( Transformation.methods, camelKey)
      this[camelKey].apply(this, values)
    else
      @otherOptions[key] = values[0]
    this

  hasLayer: ()->
    @getValue("overlay") || @getValue("underlay")


  ###*
   * Generate a string representation of the transformation.
   * @function Transformation#serialize
   * @return {string} Returns the transformation as a string
  ###
  serialize: ->
    resultArray = for tr in @chained
        tr.serialize()
    paramList = @keys()
    transformations = @get("transformation")?.serialize()
    ifParam = @get("if")?.serialize()
    variables = processVar(@get("variables")?.value())
    paramList = Util.difference(paramList, ["transformation", "if", "variables"])
    vars = []
    transformationList = []
    for t in paramList
      if t.match(VAR_NAME_RE)
        vars.push(t + "_" + Expression.normalize(@get(t)?.value()))
      else
        transformationList.push(@get(t)?.serialize())

    switch
      when Util.isString(transformations)
        transformationList.push( transformations)
      when Util.isArray( transformations)
        resultArray = resultArray.concat(transformations)
    transformationList = (
      for value in transformationList when Util.isArray(value) &&!Util.isEmpty(value) || !Util.isArray(value) && value
        value
    )

    transformationList = vars.sort().concat(variables).concat(transformationList.sort())

    if ifParam == "if_end"
      transformationList.push(ifParam)
    else if !Util.isEmpty(ifParam)
      transformationList.unshift(ifParam)

    transformationString = Util.compact(transformationList).join(@param_separator)
    resultArray.push(transformationString) unless Util.isEmpty(transformationString)
    Util.compact(resultArray).join(@trans_separator)

  ###*
   * Provide a list of all the valid transformation option names
   * @function Transformation#listNames
   * @private
   * @return {Array<string>} a array of all the valid option names
  ###
  listNames: ->
    Transformation.methods


  ###*
   * Returns attributes for an HTML tag.
   * @function Cloudinary.toHtmlAttributes
   * @return PlainObject
  ###
  toHtmlAttributes: ()->
    options = {}
    for key, value of @otherOptions when  !Util.contains(Transformation.PARAM_NAMES, Util.snakeCase(key))
      attrName = if /^html_/.test(key) then key.slice(5) else key
      options[attrName] = value
    # convert all "html_key" to "key" with the same value
    for key in @keys() when /^html_/.test(key)
      options[Util.camelCase(key.slice(5))] = @getValue(key)

    unless @hasLayer()|| @getValue("angle") || Util.contains( ["fit", "limit", "lfill"],@getValue("crop"))
      width = @get("width")?.origValue
      height = @get("height")?.origValue
      if parseFloat(width) >= 1.0
        options['width'] ?= width
      if parseFloat(height) >= 1.0
        options['height'] ?= height
    options

  isValidParamName: (name) ->
    Transformation.methods.indexOf(Util.camelCase(name)) >= 0

  ###*
   * Delegate to the parent (up the call chain) to produce HTML
   * @function Transformation#toHtml
   * @return {string} HTML representation of the parent if possible.
   * @example
   * tag = cloudinary.ImageTag.new("sample", {cloud_name: "demo"})
   * // ImageTag {name: "img", publicId: "sample"}
   * tag.toHtml()
   * // <img src="http://res.cloudinary.com/demo/image/upload/sample">
   * tag.transformation().crop("fit").width(300).toHtml()
   * // <img src="http://res.cloudinary.com/demo/image/upload/c_fit,w_300/sample">
  ###

  toHtml: ()->
    @getParent()?.toHtml?()

  toString: ()->
    @serialize()


  processVar = (varArray)->
    if Util.isArray(varArray)
      "#{name}_#{Expression.normalize(v)}" for [name,v] in varArray
    else
      varArray

    ###*
     * Transformation Class methods.
     * This is a list of the parameters defined in Transformation.
     * Values are camelCased.
     * @const Transformation.methods
     * @private
     * @ignore
     * @type {Array<string>}
    ###

    ###*
     * Parameters that are filtered out before passing the options to an HTML tag.
     *
     * The list of parameters is a combination of `Transformation::methods` and `Configuration::CONFIG_PARAMS`
     * @const {Array<string>} Transformation.PARAM_NAMES
     * @private
     * @ignore
     * @see toHtmlAttributes
    ###

class Transformation  extends TransformationBase

  ###*
   *  Represents a single transformation.
   *  @class Transformation
   *  @example
   *  t = new cloudinary.Transformation();
   * t.angle(20).crop("scale").width("auto");
   *
   * // or
   *
   * t = new cloudinary.Transformation( {angle: 20, crop: "scale", width: "auto"});
  ###
  constructor: (options = {})->
    super(options)
    @

  ###*
   * Convenience constructor
   * @param {Object} options
   * @return {Transformation}
   * @example cl = cloudinary.Transformation.new( {angle: 20, crop: "scale", width: "auto"})
  ###
  @new = (args)-> new Transformation(args)

  ###
    Transformation Parameters
  ###

  angle: (value)->                @arrayParam value, "angle", "a", ".", Expression.normalize
  audioCodec: (value)->           @param value, "audio_codec", "ac"
  audioFrequency: (value)->       @param value, "audio_frequency", "af"
  aspectRatio: (value)->          @param value, "aspect_ratio", "ar", Expression.normalize
  background: (value)->           @param value, "background", "b", Param.norm_color
  bitRate: (value)->              @param value, "bit_rate", "br"
  border: (value)->               @param value, "border", "bo", (border) ->
    if (Util.isPlainObject(border))
      border = Util.assign({}, {color: "black", width: 2}, border)
      "#{border.width}px_solid_#{Param.norm_color(border.color)}"
    else
      border
  color: (value)->                @param value, "color", "co", Param.norm_color
  colorSpace: (value)->           @param value, "color_space", "cs"
  crop: (value)->                 @param value, "crop", "c"
  defaultImage: (value)->         @param value, "default_image", "d"
  delay: (value)->                @param value, "delay", "dl"
  density: (value)->              @param value, "density", "dn"
  duration: (value)->             @rangeParam value, "duration", "du"
  dpr: (value)->                  @param value, "dpr", "dpr", (dpr) =>
    dpr = dpr.toString()
    if (dpr?.match(/^\d+$/))
      dpr + ".0"
    else
      Expression.normalize(dpr)
  effect: (value)->               @arrayParam value,  "effect", "e", ":", Expression.normalize
  else: ()->                      @if('else')
  endIf: ()->                     @if('end')
  endOffset: (value)->            @rangeParam value,  "end_offset", "eo"
  fallbackContent: (value)->      @param value,   "fallback_content"
  fetchFormat: (value)->          @param value,       "fetch_format", "f"
  format: (value)->               @param value,       "format"
  flags: (value)->                @arrayParam value,  "flags", "fl", "."
  gravity: (value)->              @param value,       "gravity", "g"
  height: (value)->               @param value,       "height", "h", =>
    if ( @getValue("crop") || @getValue("overlay") || @getValue("underlay"))
      Expression.normalize(value)
    else
      null
  htmlHeight: (value)->           @param value, "html_height"
  htmlWidth:(value)->             @param value, "html_width"
  if: (value = "")->
    switch value
      when "else"
        @chain()
        @param value, "if", "if"
      when "end"
        @chain()
        for i in [@chained.length-1..0] by -1
          ifVal = @chained[i].getValue("if")
          if ifVal == "end"
            break
          else if ifVal?
            trIf = Transformation.new().if(ifVal)
            @chained[i].remove("if")
            trRest = @chained[i]
            @chained[i] = Transformation.new().transformation([trIf, trRest])
            break unless ifVal == "else"
        @param value, "if", "if"
      when ""
        Condition.new().setParent(this)
      else
        @param value, "if", "if", (value)->
          Condition.new(value).toString()
  keyframeInterval: (value)->     @param value, "keyframe_interval",  "ki"
  offset: (value)->
    [start_o, end_o] = if( Util.isFunction(value?.split))
      value.split('..')
    else if Util.isArray(value)
      value
    else
      [null,null]
    @startOffset(start_o) if start_o?
    @endOffset(end_o) if end_o?
  opacity: (value)->              @param value, "opacity",  "o", Expression.normalize
  overlay: (value)->              @layerParam value, "overlay",  "l"
  page: (value)->                 @param value, "page",     "pg"
  poster: (value)->               @param value, "poster"
  prefix: (value)->               @param value, "prefix",   "p"
  quality: (value)->              @param value, "quality",  "q", Expression.normalize
  radius: (value)->               @param value, "radius",   "r", Expression.normalize
  rawTransformation: (value)->    @rawParam value, "raw_transformation"
  size: (value)->
    if( Util.isFunction(value?.split))
      [width, height] = value.split('x')
      @width(width)
      @height(height)
  sourceTypes: (value)->          @param value, "source_types"
  sourceTransformation: (value)-> @param value, "source_transformation"
  startOffset: (value)->          @rangeParam value, "start_offset", "so"
  streamingProfile: (value)->     @param value, "streaming_profile",  "sp"
  transformation: (value)->       @transformationParam value, "transformation", "t"
  underlay: (value)->             @layerParam value, "underlay", "u"
  variable: (name, value)->       @param value, name, name
  variables: (values)->           @arrayParam values, "variables"
  videoCodec: (value)->           @param value, "video_codec", "vc", Param.process_video_params
  videoSampling: (value)->        @param value, "video_sampling", "vs"
  width: (value)->                @param value, "width", "w", =>
    if ( @getValue("crop") || @getValue("overlay") || @getValue("underlay"))
      Expression.normalize(value)
    else
      null
  x: (value)->                    @param value, "x", "x", Expression.normalize
  y: (value)->                    @param value, "y", "y", Expression.normalize
  zoom: (value)->                 @param value, "zoom", "z", Expression.normalize

###*
 * Transformation Class methods.
 * This is a list of the parameters defined in Transformation.
 * Values are camelCased.
###
Transformation.methods ||= Util.difference(Util.functions(Transformation.prototype), Util.functions(TransformationBase.prototype))

###*
 * Parameters that are filtered out before passing the options to an HTML tag.
 *
 * The list of parameters is a combination of `Transformation::methods` and `Configuration::CONFIG_PARAMS`
###
Transformation.PARAM_NAMES ||= (Util.snakeCase(m) for m in Transformation.methods).concat( Configuration.CONFIG_PARAMS)
