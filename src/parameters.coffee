
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
  "cdn_subdomain"
  "cloud_name"
  "cname"
  "color"
  "color_space"
  "crop"
  "default_image"
  "delay"
  "density"
  "dpr"
  "dpr"
  "duration"
  "effect"
  "end_offset"
  "fallback_content"
  "fetch_format"
  "format"
  "flags"
  "gravity"
  "height"
  "offset"
  "opacity"
  "overlay"
  "page"
  "prefix"
  "private_cdn"
  "protocol"
  "quality"
  "radius"
  "raw_transformation"
  "resource_type"
  "responsive_width"
  "secure"
  "secure_cdn_subdomain"
  "secure_distribution"
  "shorten"
  "size"
  "source_transformation"
  "source_types"
  "start_offset"
  "transformation"
  "type"
  "underlay"
  "use_root_path"
  "video_codec"
  "video_sampling"
  "width"
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
  cdn_subdomain: config().cdn_subdomain
  cloud_name: config().cloud_name
  cname: config().cname
  dpr: config().dpr
  fallback_content: ''
  private_cdn: config().private_cdn
  protocol: config().protocol
  resource_type: "image"
  responsive_width: config().responsive_width
  secure: window.location.protocol == 'https:'
  secure_cdn_subdomain: config().secure_cdn_subdomain
  secure_distribution: config().secure_distribution
  shorten: config().shorten
  source_transformation: {}
  source_types: []
  transformation: []
  type: 'upload'
  use_root_path: config().use_root_path

}

class Param
  constructor: (@name, @short, @process = _.identity)->
    #console.log("setting up " + @name)

  set: (@value)->
    #console.log("Set " + @name + "= " + @value)
    this

  flatten: ->
    #console.log("flatten #{@value}")
    #console.dir(this)
    val = @process(@value)
    if @short? && val?
      "#{@short }_#{val}"
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
  flatten: -> #FIXME when to handle string?
    flat = for t in @value
      if _.isFunction( t.flatten)
        t.flatten() # Param or Transformation
      else
        t
    "#{@short}_#{flat.join(@sep)}"
  set: (@value)->
    if _.isArray(@value)
      super(@value)
    else
      super([@value])

class TransformationParam extends Param
  constructor: (@name, @short = "t", @sep = '.', @process = _.identity) ->
    super(@name, @short, @process)
  flatten: -> #FIXME when to handle string?
    if _.isEmpty(@value)
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

  set: (@value)->
    if _.isArray(@value)
      super(@value)
    else
      super([@value])

class RangeParam extends Param
  constructor: (@name, @short, @process = @norm_range_value)->
    super(@name, @short, @process)

#class FetchParam extends Param
#  constructor: (@name = "fetch", @short = "f", @process = _.identity)->
#    super(@name, @short, @process)
#  flatten: ->
#    "#{@short}/#{@value}"

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
