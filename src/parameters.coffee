###*
 * Transformation parameters
 * Depends on 'util', 'transformation'
###
class Param
  ###*
   * Represents a single parameter
   * @class Param
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} shortName - The name of the serialized form of the parameter.
   *                         If a value is not provided, the parameter will not be serialized.
   * @param {function} [process=cloudinary.Util.identity ] - Manipulate origValue when value is called
   * @ignore
  ###
  constructor: (name, shortName, process = cloudinary.Util.identity)->
    ###*
     * The name of the parameter in snake_case
     * @member {string} Param#name
    ###
    @name = name
    ###*
     * The name of the serialized form of the parameter
     * @member {string} Param#shortName
    ###
    @shortName = shortName
    ###*
     * Manipulate origValue when value is called
     * @member {function} Param#process
    ###
    @process = process

  ###*
   * Set a (unprocessed) value for this parameter
   * @function Param#set
   * @param {*} origValue - the value of the parameter
   * @return {Param} self for chaining
  ###
  set: (origValue)->
    @origValue = origValue
    this

  ###*
   * Generate the serialized form of the parameter
   * @function Param#serialize
   * @return {string} the serialized form of the parameter
  ###
  serialize: ->
    val = @value()
    valid = if cloudinary.Util.isArray(val) || cloudinary.Util.isPlainObject(val) || cloudinary.Util.isString(val)
        !cloudinary.Util.isEmpty(val)
      else
        val?
    if @shortName? && valid
      "#{@shortName}_#{val}"
    else
      ''

  ###*
   * Return the processed value of the parameter
   * @function Param#value
  ###
  value: ->
    @process(@origValue)

  @norm_color: (value) -> value?.replace(/^#/, 'rgb:')

  build_array: (arg = []) ->
    if cloudinary.Util.isArray(arg)
      arg
    else
      [arg]
  ###*
  * Covert value to video codec string.
  *
  * If the parameter is an object,
  * @param {(string|Object)} param - the video codec as either a String or a Hash
  * @return {string} the video codec string in the format codec:profile:level
  * @example
  * vc_[ :profile : [level]]
  * or
    { codec: 'h264', profile: 'basic', level: '3.1' }
  * @ignore
  ###
  @process_video_params = (param) ->
    switch param.constructor
      when Object
        video = ""
        if 'codec' of param
          video = param['codec']
          if 'profile' of param
            video += ":" + param['profile']
            if 'level' of param
              video += ":" + param['level']
        video
      when String
        param
      else
        null

class ArrayParam extends Param
  ###*
   * A parameter that represents an array
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} shortName - The name of the serialized form of the parameter
   *                         If a value is not provided, the parameter will not be serialized.
   * @param {string} [sep='.'] - The separator to use when joining the array elements together
   * @param {function} [process=cloudinary.Util.identity ] - Manipulate origValue when value is called
   * @class ArrayParam
   * @extends Param
   * @ignore
  ###
  constructor: (name, shortName, sep = '.', process) ->
    @sep = sep
    super(name, shortName, process)

  serialize: ->
    if @shortName?
      arrayValue = @value()
      if cloudinary.Util.isEmpty(arrayValue)
        ''
      else if cloudinary.Util.isString(arrayValue)
        "#{@shortName}_#{arrayValue}"
      else
        flat = for t in arrayValue
          if cloudinary.Util.isFunction( t.serialize)
            t.serialize() # Param or Transformation
          else
            t
        "#{@shortName}_#{flat.join(@sep)}"
    else
      ''

  value: ()->
    if cloudinary.Util.isArray(@origValue)
      @process(v) for v in @origValue
    else
      @process(@origValue)

  set: (origValue)->
    if !origValue? || cloudinary.Util.isArray(origValue)
      super(origValue)
    else
      super([origValue])

class TransformationParam extends Param
  ###*
   * A parameter that represents a transformation
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} [shortName='t'] - The name of the serialized form of the parameter
   * @param {string} [sep='.'] - The separator to use when joining the array elements together
   * @param {function} [process=cloudinary.Util.identity ] - Manipulate origValue when value is called
   * @class TransformationParam
   * @extends Param
   * @ignore
  ###
  constructor: (name, shortName = "t", sep = '.', process) ->
    @sep = sep
    super(name, shortName, process)

  serialize: ->
    if cloudinary.Util.isEmpty(@value())
      ''
    else if cloudinary.Util.allStrings(@value())
      joined = @value().join(@sep)
      if !cloudinary.Util.isEmpty(joined)
        "#{@shortName}_#{joined}"
      else
        ''
    else
      result = for t in @value() when t?
        if cloudinary.Util.isString( t) && !cloudinary.Util.isEmpty(t)
          "#{@shortName}_#{t}"
        else if cloudinary.Util.isFunction( t.serialize)
          t.serialize()
        else if cloudinary.Util.isPlainObject(t) && !cloudinary.Util.isEmpty(t)
          new Transformation(t).serialize()
      cloudinary.Util.compact(result)

  set: (@origValue)->
    if cloudinary.Util.isArray(@origValue)
      super(@origValue)
    else
      super([@origValue])

class RangeParam extends Param
  ###*
   * A parameter that represents a range
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} shortName - The name of the serialized form of the parameter
   *                         If a value is not provided, the parameter will not be serialized.
   * @param {function} [process=norm_range_value ] - Manipulate origValue when value is called
   * @class RangeParam
   * @extends Param
   * @ignore
  ###
  constructor: (name, shortName, process = @norm_range_value)->
    super(name, shortName, process)

  @norm_range_value: (value) ->
    offset = String(value).match(new RegExp('^' + offset_any_pattern + '$'))
    if offset
      modifier = if offset[5]? then 'p' else ''
      value = (offset[1] or offset[4]) + modifier
    value

class RawParam extends Param
  constructor: (name, shortName, process = cloudinary.Util.identity)->
    super(name, shortName, process)
  serialize: ->
    @value()

class LayerParam extends Param

  # Parse layer options
  # @return [string] layer transformation string
  # @private
  value: ()->
    layerOptions = @origValue
    
    if cloudinary.Util.isPlainObject(layerOptions)
      layerOptions = Util.withCamelCaseKeys(layerOptions)
      if layerOptions.resourceType == "text" || layerOptions.text?
        result = new cloudinary.TextLayer(layerOptions).toString()
      else if layerOptions.resourceType == "subtitles"
        result = new cloudinary.SubtitlesLayer(layerOptions).toString()
      else if layerOptions.resourceType == "fetch" || layerOptions.url?
        result = new cloudinary.FetchLayer(layerOptions).toString()
      else
        result = new cloudinary.Layer(layerOptions).toString()
    else if /^fetch:.+/.test(layerOptions)
      result = new FetchLayer(layerOptions.substr(6)).toString()
    else
      result = layerOptions
    result

  LAYER_KEYWORD_PARAMS =[
    ["font_weight", "normal"],
    ["font_style", "normal"],
    ["text_decoration", "none"],
    ["text_align", null],
    ["stroke", "none"],
    ["letter_spacing", null],
    ["line_spacing", null]
  ]

  textStyle: (layer)->
    (new cloudinary.TextLayer(layer)).textStyleIdentifier()

class ExpressionParam extends Param
  serialize: ()->
    Expression.normalize(super())

parameters = {}
parameters.Param = Param
parameters.ArrayParam = ArrayParam
parameters.RangeParam = RangeParam
parameters.RawParam = RawParam
parameters.TransformationParam = TransformationParam
parameters.LayerParam = LayerParam
parameters.ExpressionParam = ExpressionParam

