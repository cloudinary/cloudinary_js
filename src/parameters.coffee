
class Param
  constructor: (@name, @short, @process = _.identity)->

  set: (@origValue)->
    this

  flatten: ->
    val = @process(@origValue)
    if @short? && val?
      "#{@short}_#{val}"
    else
      null

  value: ->
    @process(@origValue)

  @norm_range_value: (value) ->
    offset = String(value).match(new RegExp('^' + offset_any_pattern + '$'))
    if offset
      modifier = if offset[5]? then 'p' else ''
      value = (offset[1] or offset[4]) + modifier
    value

  @norm_color: (value) -> value?.replace(/^#/, 'rgb:')

  build_array: (arg = []) ->
    if _.isArray(arg)
      arg
    else
      [arg]


class ArrayParam extends Param
  constructor: (@name, @short, @sep = '.', @process = _.identity) ->
    super(@name, @short, @process)
  flatten: ->
    if @short? # FIXME call process
      flat = for t in @value()
        if _.isFunction( t.flatten)
          t.flatten() # Param or Transformation
        else
          t
      "#{@short}_#{flat.join(@sep)}"
    else
      null
  set: (@origValue)->
    if _.isArray(@origValue)
      super(@origValue)
    else
      super([@origValue])

class TransformationParam extends Param
  # FIXME chain, join with slashes
  # TODO maybe use regular param with "transformation" process?
  constructor: (@name, @short = "t", @sep = '.', @process = _.identity) ->
    super(@name, @short, @process)
  flatten: ->
    if _.isEmpty(@value())
      null
    else if _.all(@value(), _.isString)
      "#{@short}_#{@value().join(@sep)}"
    else
      result = for t in @value() when t?
        if _.isString( t)
          "#{@short}_#{t}"
        else if _.isFunction( t.flatten)
          t.flatten()
        else if _.isPlainObject(t)
          new Transformation(t).flatten()
      _.compact(result)
  set: (@origValue)->
    if _.isArray(@origValue)
      super(@origValue)
    else
      super([@origValue])

class RangeParam extends Param
  constructor: (@name, @short, @process = @norm_range_value)-> # FIXME overrun by identity in transformation?
    super(@name, @short, @process)

class RawParam extends Param
  constructor: (@name, @short, @process = _.identity)->
    super(@name, @short, @process)
  flatten: ->
    @value()


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
###
process_video_params = (param) ->
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

