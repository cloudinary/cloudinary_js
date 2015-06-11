number_pattern = "([0-9]*)\\.([0-9]+)|([0-9]+)";
offset_any_pattern = "(#{number_pattern })([%pP])?";
#_log = console.log
#console.log = (value)->
#  out = document.getElementById("output")
#  out.innerHTML += "<p>#{value}</p>"
#  _log(value)

class TransformationBase
  param: (value, name, abbr, default_value, process = _.identity) ->
    process = default_value if _.isFunction(default_value) && !process?
    console.dir(@)
    console.dir(@trans)
    @trans[name] = new Param(name, abbr, process).set(value)

  rawParam: (value, name, abbr, default_value, process = _.identity) ->
    process = default_value if _.isFunction(default_value) && !process?
    @trans[name] = new RawParam(name, abbr, process).set(value)

  rangeParam: (value, name, abbr, default_value, process = _.identity) ->
    process = default_value if _.isFunction(default_value) && !process?
    @trans[name] = new RangeParam(name, abbr, process).set(value)

  arrayParam: (value, name, abbr, sep = ":", default_value, process = _.identity) ->
    process = default_value if _.isFunction(default_value) && !process?
    @trans[name] = new ArrayParam(name, abbr, sep, process).set(value)

  constructor: (@trans = {})->
    @trans = {}
    @whitelist = _.functions(TransformationBase.prototype)
    _.difference(@whitelist, ["_set", "param", "rawParam", "rangeParam", "arrayParam"])
    console.log(@whitelist)
  angle: (value)-> @param value, "angle", "a"
  audio_codec: (value)-> @param value, "audio_codec", "ac"
  audio_frequency: (value)-> @param value, "audio_frequency", "f"
  background: (value)-> @param value, "background", "b", Param.norm_color
  bit_rate: (value)-> @param value, "bit_rate", "r"
  border: (value)-> @param value, "border", "bo", (border) ->
    if (_.isPlainObject(border))
      _.assign({color: "black", width: 2}, border)
      "#{border.width}px_solid_#{Param.norm_color(border.color)}"
    else
      border
  color: (value)-> @param value, "color", "co", Param.norm_color
  color_space: (value)-> @param value, "color_space", "s"
  crop: (value)-> @param value, "crop", "c"
  default_image: (value)-> @param value, "default_image", "d"
  delay: (value)-> @param value, "delay", "l"
  density: (value)-> @param value, "density", "n"
  duration: (value)-> @rangeParam value, "duration", "du"
  dpr: (value)-> @param value, "dpr", "dpr", (dpr) ->
    if (dpr == "auto")
      "1.0"
    else if (dpr?.match(/^d+$/))
      dpr + ".0"
    else
      dpr
  effect: (value)-> @arrayParam value, "effect", "e", ":"
  end_offset: (value)-> @rangeParam value, "end_offset", "eo"
  fetch_format: (value)-> @param value, "fetch_format", "f"
  flags: (value)-> @arrayParam value, "flags", "fl", "."
  gravity: (value)-> @param value, "gravity", "g"
  height: (value)-> @param value, "height", "h"
  html_height: (value)-> @param value, "html_height"
  html_width:(value)-> @param value, "html_width"
  offset: (value)->
    [start_o, end_o] = if( _.isFunction(value?.split))
      value.split('..')
    else if _.isArray(value)
      value
    else
      [null,null]
    @start_offset(start_o) if start_o?
    @end_offset(end_o) if end_o?
  opacity: (value)-> @param value, "opacity", "o"
  overlay: (value)-> @param value, "overlay", "l"
  page: (value)-> @param value, "page", "g"
  prefix: (value)-> @param value, "prefix", "p"
  quality: (value)-> @param value, "quality", "q"
  radius: (value)-> @param value, "radius", "r"
  raw_transformation: (value)-> @rawParam value, "raw_transformation"
  size: (value)->
    if( _.isFunction(value?.split))
      [width, height] = value.split('x')
      @width(width)
      @height(height)
  start_offset: (value)-> @rangeParam value, "start_offset", "so"
  transformation: (value)-> @arrayParam value, "transformation", "t", ".", (transformation_array)->
    for t in transformation_array
      if _.isString(t) then t else new Transformation(t)
  underlay: (value)-> @param value, "underlay", "u"
  video_codec: (value)-> @param value, "video_codec", "vc", process_video_params
  video_sampling: (value)-> @param value, "video_sampling", "s"
  width: (value)-> @param value, "width", "w"
  x: (value)-> @param value, "x", "x"
  y: (value)-> @param value, "y", "y"
  zoom: (value)-> @param value, "zoom", "z"

###*
#  A single transformation.
#
#  Usage:
#
#      t = new Transformation();
#      t.angle(20).crop("scale").width("auto");
#
#  or
#      t = new Transformation( {angle: 20, crop: "scale", width: "auto"});
###
class Transformation extends TransformationBase
  constructor: (options = {}) ->
    super()
    this.fromOptions(options)
  fromOptions: (options = {}) ->
    options = {transformation: options } if _.isString(options) || _.isArray(options)
    console.dir(_.intersection(options, @whitelist))
    for k in _.intersection(_.keys(options), @whitelist)
      console.log("setting #{k} to #{options[k]}")
      this[k](options[k])
    this
  getValue: (name)->
    @trans[name]?.value
  get: (name)->
    @trans[name]
  remove: (name)->
    temp = @trans[name]
    delete @trans[name]
    temp
  flatten: ->
    param_list = @trans.sort()
    result_array = []
    console.log("filtered_transformation_params")
    console.log(filtered_transformation_params)
    transformations = remove("transformation");
    if transformations
      result_array.concat( transformations.flatten())
    unless _.any([ @getValue("overlay"), @getValue("underlay"), _.contains( ["fit", "limit", "lfill"],@["crop"])])
      width = @getValue("width")
      if width && width != "auto" && parseFloat(width) >= 1.0
        html_width(width) unless @get("html_width")
      if @get("height") && parseFloat(@getValue("height")) >= 1.0
        html_height(height) unless @get("html_height")
    unless _.any([ @getValue("crop"), @getValue("overlay"), @getValue("underlay")])
      _.pull( param_list, "width", "height")

    #    (@get(t).flatten() for t of @trans when filtered_transformation_params.indexOf(t) == -1).join(',')
    transformation_string = (@get(t).flatten() for t of param_list ).join(',')
    result_array.push(transformation_string) unless _.isEmpty(transformation_string)
    result_array.join('/')

  listNames: ->
    @whitelist

  isValidParamName: (name) ->
    @whitelist.indexOf(name) >= 0
if module?.exports
#On a server
  exports.Transformation = Transformation
else
#On a client
  window.Transformation = Transformation
