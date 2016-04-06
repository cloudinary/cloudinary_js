###*
 * Transformation parameters
 * Depends on 'util', 'transformation'
###
class Param
  ###*
   * Represents a single parameter
   * @class Param
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} short - The name of the serialized form of the parameter.
   *                         If a value is not provided, the parameter will not be serialized.
   * @param {function} [process=cloudinary.Util.identity ] - Manipulate origValue when value is called
   * @ignore
  ###
  constructor: (name, short, process = cloudinary.Util.identity)->
    ###*
     * The name of the parameter in snake_case
     * @member {string} Param#name
    ###
    @name = name
    ###*
     * The name of the serialized form of the parameter
     * @member {string} Param#short
    ###
    @short = short
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
    if @short? && valid
      "#{@short}_#{val}"
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
   * @param {string} short - The name of the serialized form of the parameter
   *                         If a value is not provided, the parameter will not be serialized.
   * @param {string} [sep='.'] - The separator to use when joining the array elements together
   * @param {function} [process=cloudinary.Util.identity ] - Manipulate origValue when value is called
   * @class ArrayParam
   * @extends Param
   * @ignore
  ###
  constructor: (name, short, sep = '.', process) ->
    @sep = sep
    super(name, short, process)

  serialize: ->
    if @short?
      array = @value()
      if cloudinary.Util.isEmpty(array)
        ''
      else
        flat = for t in @value()
          if cloudinary.Util.isFunction( t.serialize)
            t.serialize() # Param or Transformation
          else
            t
        "#{@short}_#{flat.join(@sep)}"
    else
      ''

  set: (origValue)->
    if !origValue? || cloudinary.Util.isArray(origValue)
      super(origValue)
    else
      super([origValue])

class TransformationParam extends Param
  ###*
   * A parameter that represents a transformation
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} [short='t'] - The name of the serialized form of the parameter
   * @param {string} [sep='.'] - The separator to use when joining the array elements together
   * @param {function} [process=cloudinary.Util.identity ] - Manipulate origValue when value is called
   * @class TransformationParam
   * @extends Param
   * @ignore
  ###
  constructor: (name, short = "t", sep = '.', process) ->
    @sep = sep
    super(name, short, process)

  serialize: ->
    if cloudinary.Util.isEmpty(@value())
      ''
    else if cloudinary.Util.allStrings(@value())
      joined = @value().join(@sep)
      if !cloudinary.Util.isEmpty(joined)
        "#{@short}_#{joined}"
      else
        ''
    else
      result = for t in @value() when t?
        if cloudinary.Util.isString( t) && !cloudinary.Util.isEmpty(t)
          "#{@short}_#{t}"
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
   * @param {string} short - The name of the serialized form of the parameter
   *                         If a value is not provided, the parameter will not be serialized.
   * @param {function} [process=norm_range_value ] - Manipulate origValue when value is called
   * @class RangeParam
   * @extends Param
   * @ignore
  ###
  constructor: (name, short, process = @norm_range_value)->
    super(name, short, process)

  @norm_range_value: (value) ->
    offset = String(value).match(new RegExp('^' + offset_any_pattern + '$'))
    if offset
      modifier = if offset[5]? then 'p' else ''
      value = (offset[1] or offset[4]) + modifier
    value

class RawParam extends Param
  constructor: (name, short, process = cloudinary.Util.identity)->
    super(name, short, process)
  serialize: ->
    @value()

class LayerParam extends Param

  # Parse layer options
  # @return [string] layer transformation string
  # @private
  value: ()->
    layer = @origValue
    if cloudinary.Util.isPlainObject(layer)
      publicId     = layer.public_id
      format        = layer.format
      resourceType = layer.resource_type || "image"
      type          = layer.type || "upload"
      text          = layer.text
      textStyle    = null
      components    = []

      if publicId?
        publicId = publicId.replace(/\//g, ":")
        publicId = "#{publicId}.#{format}" if format?

      if !text? && resourceType != "text"
        if cloudinary.Util.isEmpty(publicId)
          throw "Must supply public_id for resource_type layer_parameter"
        if resourceType == "subtitles"
          textStyle = @textStyle(layer)

      else
        resourceType = "text"
        type          = null
        # // type is ignored for text layers
        textStyle    = @textStyle(layer)
        if text?
          unless publicId? ^ textStyle?
            throw "Must supply either style parameters or a public_id when providing text parameter in a text overlay/underlay"
          text = cloudinary.Util.smart_escape( cloudinary.Util.smart_escape(text, /([,\/])/))

      components.push(resourceType) if resourceType != "image"
      components.push(type) if type != "upload"
      components.push(textStyle)
      components.push(publicId)
      components.push(text)
      layer = cloudinary.Util.compact(components).join(":")
    layer

  LAYER_KEYWORD_PARAMS =[
    ["font_weight", "normal"],
    ["font_style", "normal"],
    ["text_decoration", "none"],
    ["text_align", null],
    ["stroke", "none"],
  ]

  textStyle: (layer)->
    fontFamily = layer.font_family
    fontSize   = layer.font_size
    keywords    =
      layer[attr] for [attr, defaultValue] in LAYER_KEYWORD_PARAMS when layer[attr] != defaultValue

    letterSpacing = layer.letter_spacing
    keywords.push("letter_spacing_#{letterSpacing}") unless cloudinary.Util.isEmpty(letterSpacing)
    lineSpacing = layer.line_spacing
    keywords.push("line_spacing_#{lineSpacing}") unless cloudinary.Util.isEmpty(lineSpacing)
    if !cloudinary.Util.isEmpty(fontSize) || !cloudinary.Util.isEmpty(fontFamily) || !cloudinary.Util.isEmpty(keywords)
      throw "Must supply font_family for text in overlay/underlay" if cloudinary.Util.isEmpty(fontFamily)
      throw "Must supply font_size for text in overlay/underlay" if cloudinary.Util.isEmpty(fontSize)
      keywords.unshift(fontSize)
      keywords.unshift(fontFamily)
      cloudinary.Util.compact(keywords).join("_")


parameters = {}
parameters.Param = Param
parameters.ArrayParam = ArrayParam
parameters.RangeParam = RangeParam
parameters.RawParam = RawParam
parameters.TransformationParam = TransformationParam
parameters.LayerParam = LayerParam

