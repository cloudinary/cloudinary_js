class Cloudinary
  'use strict';
  CF_SHARED_CDN = "d3jpl91pxevbkh.cloudfront.net";
  OLD_AKAMAI_SHARED_CDN = "cloudinary-a.akamaihd.net";
  AKAMAI_SHARED_CDN = "res.cloudinary.com";
  SHARED_CDN = AKAMAI_SHARED_CDN;
  DEFAULT_POSTER_OPTIONS = { format: 'jpg', resource_type: 'video' };
  DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv'];

  constructor: (configuration)->
    configure(configuration)

  configure: (new_config, new_value) ->
    unless @cloudinary_config?
      @cloudinary_config = {}
      meta_elements = document.getElementsByTagName("meta");
      for el in meta_elements
        @cloudinary_config[el.getAttribute('name').replace('cloudinary_', '')] = el.getAttribute('content')
    if new_value?
      @cloudinary_config[new_config] = new_value
    else if new_config?
      @cloudinary_config = new_config
    this


  option_consume = (options, option_name, default_value) ->
    result = options[option_name]
    delete options[option_name]
    if typeof result == 'undefined' then default_value else result
class Transformation

  constructor: (@name, @short, @process)->
    console.log("setting up " + @name)

  set: (@value)=>
    console.log("Set " + @name + "= " + @value)
    this

  flatten: ->
    @short + '_' + @process(@value)

class Resource
  constructor: (@cloudinary)->
    @transformations = new Array()
  add: (name, transformation)->
    @transformations.push {name, transformation}
    this

  angle: (angle) ->
    add build_array(angle).join '.'

  background: (background) ->
    add background.replace /^#/, 'rgb:'

  border: (border) ->
    if _.isPlainObject(border)
      border_width = '' + (border.width or 2)
      border_color = (border.color or 'black').replace(/^#/, 'rgb:')
      border = border_width + 'px_solid_' + border_color
    add border

  color: (color) ->
    add color.replace /^#/, 'rgb:'

  dpr: (dpr) ->
    dpr = dpr.toString()
    add if dpr == 'auto'
      '1.0'
    else if dpr.match(/^\d+$/)
      dpr + '.0'
    else
      dpr
  effect: (value) ->
    build_array(value).join ':'
  flags: (value) ->
    build_array(value).join '.'
  transformation: (value) ->
    build_array(value).join '.'

  ###*
  # A video codec parameter can be either a String or a Hash.
  #
  # @param {object} param <code>vc_<codec>[ : <profile> : [<level>]]</code>
  #                       or <code>{ codec: 'h264', profile: 'basic', level: '3.1' }</code>
  # @return {string} <code><codec> : <profile> : [<level>]]</code> if a Hash was provided
  #                   or the param if a String was provided.
  #                   Returns NIL if param is not a Hash or String
  ###
  video_codec: (param) ->
    add 'vc',
      switch typeof param
        when 'object'
          if param['codec'] != undefined
            video = param['codec']
            if param['profile'] != undefined
              video += ':' + param['profile']
              if param['level'] != undefined
                video += ':' + param['level']
          else
            ''
        when 'string'
          param
        else
          null
    this

  start_offset: (value)->
    add 'so', norm_range_value(value)
    this

  end_offset: (value)->
    add 'eo', norm_range_value(value)
    this

  duration: (value)->
    add 'du', norm_range_value(value)

  join_array_function = (sep) ->
  (value) ->
    build_array(value).join sep

  norm_range_value = (value) ->
    offset = String(value).match(new RegExp('^' + offset_any_pattern + '$'))
    if offset
      modifier = if present(offset[5]) then 'p' else ''
      value = (offset[1] or offset[4]) + modifier
    value
