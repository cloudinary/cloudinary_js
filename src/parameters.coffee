
config = config || -> {}

###*
# Parameters that are filtered out before passing the options to an HTML tag
###
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

###*
# Defaults values for parameters.
#
# (Previously defined using option_consume() )
###
default_transformation_params ={
  responsive_width: config().responsive_width
  transformation: []
  dpr: config().dpr
  type: "upload"
  resource_type: "image"
  cloud_name: config().cloud_name
  private_cdn: config().private_cdn
  type: 'upload'
  resource_type: "image"
  cloud_name: config().cloud_name
  private_cdn: config().private_cdn
  secure_distribution: config().secure_distribution
  cname: config().cname
  cdn_subdomain: config().cdn_subdomain
  secure_cdn_subdomain: config().secure_cdn_subdomain
  shorten: config().shorten
  secure: window.location.protocol == 'https:'
  protocol: config().protocol
  use_root_path: config().use_root_path
  source_types: []
  source_transformation: {}
  fallback_content: ''

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
  flatten: -> #FIXME when to handle string?
    flat = for t in @value
      if _.isFunction( t.flatten)
        t.flatten() # Param or Transformation
      else
        t
    "#{@short}_#{flat.join(@sep)}"
  set: (@value)->
    super(_.toArray(@value))

class TransformationParam extends Param
  constructor: (@name, @short = "t", @sep = '.', @process = _.identity) ->
    super(@name, @short, @process)
  flatten: -> #FIXME when to handle string?
    if _.all(@value, _.isString)
      ["#{@short}_#{@value.join(@sep)}"]
    else
      for t in @value when _.isString(t) || _.isFunction( t.flatten)
        if _.isString( t)
          "#{@short}_#{t}"
        else if _.isFunction( t.flatten)
          t.flatten()


  set: (@value)->
    super(_.toArray(@value))

class RangeParam extends Param
  constructor: (@name, @short, @process = @norm_range_value)->
    super(@name, @short, @process)

class RawParam extends Param
  constructor: (@name, @short, @process = _.identity)->
    super(@name, @short, @process)
  flatten: ->
    @value


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
