filtered_transformation_params = [
  "angle"
  "audio_codec"
  "audio_frequency"
  "background"
  "bit_rate"
  "border"
  "color"
  "color_space"
  "crop"
  "default_image"
  "delay"
  "density"
  "dpr"
  "duration"
  "effect"
  "end_offset"
  "fetch_format"
  "flags"
  "gravity"
  "offset"
  "opacity"
  "overlay"
  "page"
  "prefix"
  "quality"
  "radius"
  "raw_transformation"
  "responsive_width"
  "size"
  "start_offset"
  "transformation"
  "underlay"
  "video_codec"
  "video_sampling"
  "x"
  "y"
  "zoom"
]

default_transformation_params ={
  "responsive_width": config().responsive_width
  "transformation": []
  "dpr": config().dpr

}

class Param
  constructor: (@name, @short, @process = _.identity)->
    console.log("setting up " + @name)

  set: (@value)->
    console.log("Set " + @name + "= " + @value)
    this

  flatten: ->
    console.log("flatten #{@value}")
    console.dir(this)
    "#{@short }_#{@process(@value)}"

  @norm_range_value: (value) ->
    offset = String(value).match(new RegExp('^' + offset_any_pattern + '$'))
    if offset
      modifier = if offset[5]? then 'p' else ''
      value = (offset[1] or offset[4]) + modifier
    value

  @norm_color: (value) -> value.replace(/^#/, 'rgb:')

  build_array: (arg = []) ->
    if _.isArray(arg)
      arg
    else
      [arg]


class ArrayParam extends Param
  constructor: (@name, @short, @sep = '.', @process = _.identity) ->
    super(@name, @short, @process)
  flatten: -> "#{@short}_#{@build_array(@value).join(@sep)}"

class RangeParam extends Param
  constructor: (@name, @short, @process = @norm_range_value)->
    super(@name, @short, @process)



###*
# A video codec parameter can be either a String or a Hash.
# @param {Object} param <code>vc_<codec>[ : <profile> : [<level>]]</code>
#                       or <code>{ codec: 'h264', profile: 'basic', level: '3.1' }</code>
# @return {String} <code><codec> : <profile> : [<level>]]</code> if a Hash was provided
#                   or the param if a String was provided.
#                   Returns null if param is not a Hash or String
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
