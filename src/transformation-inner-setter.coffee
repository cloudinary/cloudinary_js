number_pattern = "([0-9]*)\\.([0-9]+)|([0-9]+)";
offset_any_pattern = "(#{number_pattern })([%pP])?";
#_log = console.log
#console.log = (value)->
#  out = document.getElementById("output")
#  out.innerHTML += "<p>#{value}</p>"
#  _log(value)

class TransformationBase
  constructor: (@trans = {})->
    @whitelist = _.functions(TransformationBase.prototype)
    _.remove(@whitelist, "_set")
    console.log(@whitelist)
  _set: (value, param)->
    console.log("Setting #{param.name} to #{value}")
    console.log(this)
    @trans[param.name] = param.set(value)
  
  angle: (value)->
    console.log("Setting angle")
    console.dir(this)

    @_set(value, new ArrayParam("angle", "a"))
  audio_codec: (value)-> @_set(value, new Param("audio_codec", "ac"))
  audio_frequency: (value)-> @_set(value, new Param("audio_frequency", "af"))
  background: (value)-> @_set(value, new Param("background", "b", Param.norm_color))
  bit_rate: (value)-> @_set(value, new Param("bit_rate", "br"))
  border: (value)-> @_set(value, new Param("border", "bo", (border) ->
    if (_.isPlainObject(border))
      _.assign({color: "black", width: 2}, border)
      "#{border.width}px_solid_#{Param.norm_color(border.color)}"
    else
      border
  ))
  color: (value)-> @_set(value, new Param("color", "co", Param.norm_color))
  color_space: (value)-> @_set(value, new Param("color_space", "cs"))
  crop: (value)-> @_set(value, new Param("crop", "c"))
  default_image: (value)-> @_set(value, new Param("default_image", "d"))
  delay: (value)-> @_set(value, new Param("delay", "dl"))
  density: (value)-> @_set(value, new Param("density", "dn"))
  duration: (value)-> @_set(value, new RangeParam("duration", "du"))
  dpr: (value)-> @_set(value, new Param("dpr", "dpr", (dpr) ->
    if (dpr == "auto")
      "1.0"
    else if (dpr?.match(/^d+$/))
      dpr + ".0"
    else
      dpr
  ))
  effect: (value)-> @_set(value, new ArrayParam("effect", "e", ":"))
  end_offset: (value)-> @_set(value, new RangeParam("end_offset", "eo"))
  fetch_format: (value)-> @_set(value, new Param("fetch_format", "f"))
  flags: (value)-> @_set(value, new ArrayParam("flags", "fl", "."))
  gravity: (value)-> @_set(value, new Param("gravity", "g"))
  height: (value)-> @_set(value, new Param("height", "h"))
  opacity: (value)-> @_set(value, new Param("opacity", "o"))
  overlay: (value)-> @_set(value, new Param("overlay", "l"))
  page: (value)-> @_set(value, new Param("page", "pg"))
  prefix: (value)-> @_set(value, new Param("prefix", "p"))
  quality: (value)-> @_set(value, new Param("quality", "q"))
  radius: (value)-> @_set(value, new Param("radius", "r"))
  start_offset: (value)-> @_set(value, new RangeParam("start_offset", "so"))
  transformation: (value)-> @_set(value, new ArrayParam("transformation", "t", "."))
  underlay: (value)-> @_set(value, new Param("underlay", "u"))
  video_codec: (value)-> @_set(value, new Param("video_codec", "vc", process_video_params))
  video_sampling: (value)-> @_set(value, new Param("video_sampling", "vs"))
  width: (value)-> @_set(value, new Param("width", "w"))
  x: (value)-> @_set(value, new Param("x", "x"))
  y: (value)-> @_set(value, new Param("y", "y"))
  zoom: (value)-> @_set(value, new Param("zoom", "z"))


class Transformation extends TransformationBase
  constructor: (config = {}) ->
    super()
    this.fromOptions(config)
  fromOptions: (config = {}) ->
    console.dir(_.intersection(config, @whitelist))
    for k in _.intersection(_.keys(config), @whitelist)
      console.log("setting #{k} to #{config[k]}")
      this[k](config[k])
  toString: ->
    (@trans[t].flatten() for t of @trans when filtered_transformation_params.indexOf(t) == -1).join(',')

  listNames: ->
    @whitelist

  isValidParamName: (name) ->
    @whitelist.indexOf(name) >= 0


t = new Transformation
  angle: 10
  opacity: 0.5

console.dir(Transformation)
console.dir(t)
console.log(t.toString())
