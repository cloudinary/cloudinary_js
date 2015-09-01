
class Param
  constructor: (@name, @short, @process = _.identity)->

  set: (@value)->
    this

  flatten: ->
    val = @process(@value)
    if @short? && val?
      "#{@short}_#{val}"
    else
      null

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
      flat = for t in @value
        if _.isFunction( t.flatten)
          t.flatten() # Param or Transformation
        else
          t
      "#{@short}_#{flat.join(@sep)}"
    else
      null
  set: (@value)->
    if _.isArray(@value)
      super(@value)
    else
      super([@value])

class TransformationParam extends Param
  # TODO maybe use regular param with "transformation" process?
  constructor: (@name, @short = "t", @sep = '.', @process = _.identity) ->
    super(@name, @short, @process)
  flatten: ->
    result = if _.isEmpty(@value)
      null
    else if _.all(@value, _.isString)
      ["#{@short}_#{@value.join(@sep)}"]
    else
      for t in @value when t?
        if _.isString( t)
          "#{@short}_#{t}"
        else if _.isFunction( t.flatten)
          t.flatten()
        else if _.isPlainObject(t)
          new Transformation(t).flatten()
    _.compact(result)
  set: (@value)->
    if _.isArray(@value)
      super(@value)
    else
      super([@value])

class RangeParam extends Param
  constructor: (@name, @short, @process = @norm_range_value)-> # FIXME overrun by identity in transformation?
    super(@name, @short, @process)

class RawParam extends Param
  constructor: (@name, @short, @process = _.identity)->
    super(@name, @short, @process)
  flatten: ->
    @value


###*
* A video codec parameter can be either a String or a Hash.
* @param {Object} param <code>vc_<codec>[ : <profile> : [<level>]]</code>
*                       or <code>{ codec: 'h264', profile: 'basic', level: '3.1' }</code>
* @return {String} <code><codec> : <profile> : [<level>]]</code> if a Hash was provided
*                   or the param if a String was provided.
*                   Returns null if param is not a Hash or String
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

