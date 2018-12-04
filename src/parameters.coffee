import Expression from './expression'

import {
  allStrings,
  compact,
  identity,
  isArray,
  isEmpty,
  isFunction,
  isPlainObject,
  isString,
  withCamelCaseKeys
} from './util'

import Layer from './layer/layer'
import TextLayer from './layer/textlayer'
import SubtitlesLayer from './layer/subtitleslayer'
import FetchLayer from './layer/fetchlayer'


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
   * @param {function} [process=Util.identity ] - Manipulate origValue when value is called
   * @ignore
  ###
  constructor: (name, shortName, process = Util.identity)->
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
    valid = if isArray(val) || isPlainObject(val) || isString(val)
        !isEmpty(val)
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
    if isArray(arg)
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
   * @param {function} [process=Util.identity ] - Manipulate origValue when value is called
   * @class ArrayParam
   * @extends Param
   * @ignore
  ###
  constructor: (name, shortName, sep = '.', process) ->
    super(name, shortName, process)
    @sep = sep

  serialize: ->
    if @shortName?
      arrayValue = @value()
      if isEmpty(arrayValue)
        ''
      else if isString(arrayValue)
        "#{@shortName}_#{arrayValue}"
      else
        flat = for t in arrayValue
          if isFunction( t.serialize)
            t.serialize() # Param or Transformation
          else
            t
        "#{@shortName}_#{flat.join(@sep)}"
    else
      ''

  value: ()->
    if isArray(@origValue)
      @process(v) for v in @origValue
    else
      @process(@origValue)

  set: (origValue)->
    if !origValue? || isArray(origValue)
      super(origValue)
    else
      super([origValue])

class TransformationParam extends Param
  ###*
   * A parameter that represents a transformation
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} [shortName='t'] - The name of the serialized form of the parameter
   * @param {string} [sep='.'] - The separator to use when joining the array elements together
   * @param {function} [process=Util.identity ] - Manipulate origValue when value is called
   * @class TransformationParam
   * @extends Param
   * @ignore
  ###
  constructor: (name, shortName = "t", sep = '.', process) ->
    super(name, shortName, process)
    @sep = sep

  serialize: ->
    if isEmpty(@value())
      ''
    else if allStrings(@value())
      joined = @value().join(@sep)
      if !isEmpty(joined)
        "#{@shortName}_#{joined}"
      else
        ''
    else
      result = for t in @value() when t?
        if isString( t) && !isEmpty(t)
          "#{@shortName}_#{t}"
        else if isFunction( t.serialize)
          t.serialize()
        else if isPlainObject(t) && !isEmpty(t)
          new Transformation(t).serialize()
      compact(result)

  set: (@origValue)->
    if isArray(@origValue)
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
  constructor: (name, shortName, process)->
    super(name, shortName, process)
    @process ||= @norm_range_value

  @norm_range_value: (value) ->
    offset = String(value).match(new RegExp('^' + offset_any_pattern + '$'))
    if offset
      modifier = if offset[5]? then 'p' else ''
      value = (offset[1] or offset[4]) + modifier
    value

class RawParam extends Param
  constructor: (name, shortName, process = Util.identity)->
    super(name, shortName, process)
  serialize: ->
    @value()

class LayerParam extends Param

  # Parse layer options
  # @return [string] layer transformation string
  # @private
  value: ()->
    layerOptions = @origValue
    
    if isPlainObject(layerOptions)
      layerOptions = withCamelCaseKeys(layerOptions)
      if layerOptions.resourceType == "text" || layerOptions.text?
        result = new TextLayer(layerOptions).toString()
      else if layerOptions.resourceType == "subtitles"
        result = new SubtitlesLayer(layerOptions).toString()
      else if layerOptions.resourceType == "fetch" || layerOptions.url?
        result = new FetchLayer(layerOptions).toString()
      else
        result = new Layer(layerOptions).toString()
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
    (new TextLayer(layer)).textStyleIdentifier()

class ExpressionParam extends Param
  serialize: ()->
    Expression.normalize(super())

export {
  Param,
  ArrayParam,
  TransformationParam,
  RangeParam,
  RawParam,
  LayerParam,
  ExpressionParam
}