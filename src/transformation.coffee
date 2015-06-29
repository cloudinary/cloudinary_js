number_pattern = "([0-9]*)\\.([0-9]+)|([0-9]+)";
offset_any_pattern = "(#{number_pattern })([%pP])?";
#_log = console.log
#console.log = (value)->
#  out = document.getElementById("output")
#  out.innerHTML += "<p>#{value}</p>"
#  _log(value)

class TransformationBase
  param: (value, name, abbr, default_value, process) ->
    unless process?
      if _.isFunction(default_value)
        process = default_value
      else
        process = _.identity
    #console.dir(@)
    #console.dir(@trans)
    @trans[name] = new Param(name, abbr, process).set(value)

  rawParam: (value, name, abbr, default_value, process = _.identity) ->
    process = default_value if _.isFunction(default_value) && !process?
    @trans[name] = new RawParam(name, abbr, process).set(value)

#  fetchParam: (value, name, abbr, default_value, process = _.identity) ->
#    process = default_value if _.isFunction(default_value) && !process?
#    @trans[name] = new FetchParam(name, abbr, process).set(value)

  rangeParam: (value, name, abbr, default_value, process = _.identity) ->
    process = default_value if _.isFunction(default_value) && !process?
    @trans[name] = new RangeParam(name, abbr, process).set(value)

  arrayParam: (value, name, abbr, sep = ":", default_value = [], process = _.identity) ->
    process = default_value if _.isFunction(default_value) && !process?
    @trans[name] = new ArrayParam(name, abbr, sep, process).set(value)

  transformationParam: (value, name, abbr, sep = ".", default_value, process = _.identity) ->
    process = default_value if _.isFunction(default_value) && !process?
    @trans[name] = new TransformationParam(name, abbr, sep, process).set(value)


  constructor: (options = {})->
    @trans = {}
    @exclude_list = []
    @whitelist = _.functions(TransformationBase.prototype)
    _.difference(@whitelist, ["_set", "param", "rawParam", "rangeParam", "arrayParam"])
#    console.log(@whitelist)
  angle: (value)->            @param value, "angle", "a"
  audio_codec: (value)->      @param value, "audio_codec", "ac"
  audio_frequency: (value)->  @param value, "audio_frequency", "af"
  background: (value)->       @param value, "background", "b", Param.norm_color
  bit_rate: (value)->         @param value, "bit_rate", "br"
  border: (value)->           @param value, "border", "bo", (border) ->
    if (_.isPlainObject(border))
      border = _.assign({}, {color: "black", width: 2}, border)
      "#{border.width}px_solid_#{Param.norm_color(border.color)}"
    else
      border
  color: (value)->            @param value, "color", "co", Param.norm_color
  color_space: (value)->      @param value, "color_space", "cs"
  crop: (value)->             @param value, "crop", "c"
  default_image: (value)->    @param value, "default_image", "d"
  delay: (value)->            @param value, "delay", "l"
  density: (value)->          @param value, "density", "dn"
  duration: (value)->         @rangeParam value, "duration", "du"
  dpr: (value)->              @param value, "dpr", "dpr", (dpr) ->
    dpr = dpr.toString()
    if (dpr == "auto")
      "1.0"
    else if (dpr?.match(/^\d+$/))
      dpr + ".0"
    else
      dpr
  effect: (value)->           @arrayParam value,  "effect", "e", ":"
  end_offset: (value)->       @rangeParam value,  "end_offset", "eo"
  fetch_format: (value)->     @param value,       "fetch_format", "f"
  format: (value)->           @param value,       "format"
  flags: (value)->            @arrayParam value,  "flags", "fl", "."
  gravity: (value)->          @param value,       "gravity", "g"
  height: (value)->           @param value,       "height", "h", =>
    if _.any([ @getValue("crop"), @getValue("overlay"), @getValue("underlay")])
      value
    else
      null
  html_height: (value)->      @param value, "html_height"
  html_width:(value)->        @param value, "html_width"
  offset: (value)->
    [start_o, end_o] = if( _.isFunction(value?.split))
      value.split('..')
    else if _.isArray(value)
      value
    else
      [null,null]
    @start_offset(start_o) if start_o?
    @end_offset(end_o) if end_o?
  opacity: (value)->          @param value, "opacity",  "o"
  overlay: (value)->          @param value, "overlay",  "l"
  page: (value)->             @param value, "page",     "pg"
  prefix: (value)->           @param value, "prefix",   "p"
  quality: (value)->          @param value, "quality",  "q"
  radius: (value)->           @param value, "radius",   "r"
  raw_transformation: (value)-> @rawParam value, "raw_transformation"
  size: (value)->
    if( _.isFunction(value?.split))
      [width, height] = value.split('x')
      @width(width)
      @height(height)
  start_offset: (value)->     @rangeParam value, "start_offset", "so"
  transformation: (value)->   @transformationParam value, "transformation"
  underlay: (value)->         @param value, "underlay", "u"
  video_codec: (value)->      @param value, "video_codec", "vc", process_video_params
  video_sampling: (value)->   @param value, "video_sampling", "vs"
  width: (value)->            @param value, "width", "w", =>
    if _.any([ @getValue("crop"), @getValue("overlay"), @getValue("underlay")])
      value
    else
      null
  x: (value)->                @param value, "x", "x"
  y: (value)->                @param value, "y", "y"
  zoom: (value)->             @param value, "zoom", "z"

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
    # TODO dup options
    super()
    this.fromOptions(options)
  fromOptions: (options = {}) ->
    options = {transformation: options } if _.isString(options) || _.isArray(options)
    #console.dir(_.intersection(options, @whitelist))
    for k in _.intersection(_.keys(options), @whitelist)
#      console.log("setting #{k} to #{options[k]}")
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
    result_array = []
#    console.log("filtered_transformation_params")
#    console.log(filtered_transformation_params)
    transformations = @remove("transformation");
    if transformations
      result_array = result_array.concat( transformations.flatten())
    unless _.any([ @getValue("overlay"), @getValue("underlay"), @getValue("angle"), _.contains( ["fit", "limit", "lfill"],@getValue("crop"))])
      width = @getValue("width")
      height = @getValue("height")
      if width && width != "auto" && parseFloat(width) >= 1.0
        @html_width(width) unless @getValue("html_width")
      if @get("height") && parseFloat(height) >= 1.0
        @html_height(height) unless @getValue("html_height")
# TODO will this have affect on client code? (shouldn't because public api dup options)
#    unless _.any([ @getValue("crop"), @getValue("overlay"), @getValue("underlay")])
#      @remove("width")
#      @remove("height")

    param_list = _.keys(@trans).sort()

    transformation_string = (@get(t)?.flatten() for t in param_list )
    transformation_string = _.filter(transformation_string, (value)->
      _.isArray(value) &&!_.isEmpty(value) || !_.isArray(value) && value
    ).join(',')
    result_array.push(transformation_string) unless _.isEmpty(transformation_string)
    _.compact(result_array).join('/')

  listNames: ->
    @whitelist

  toPlainObject: ()->
    hash = {}
    hash[key] = @trans[key].value for key of @trans
    hash

  ###*
  # Returns an options object with attributes for an HTML tag.
  #
  # @param {Object} options if provided, this object will be muted
  ###
  toHtmlTagOptions: (options = {})->
    # delete any filtered key or options.keys - @trans
    # copy rest
    # rest = @trans.keys - filtered
    delete_keys = _.union( filtered_transformation_params,
                    _.difference(_.keys(options), _.keys(@trans)))
    delete options[key] for key in delete_keys
    options[key] = @trans[key].value for key in _.difference(_.keys(@trans ), filtered_transformation_params)
    options.width == options.html_width if options.html_width
    options.height == options.html_height if options.html_height

    options

  isValidParamName: (name) ->
    @whitelist.indexOf(name) >= 0


if module?.exports
#On a server
  exports.Transformation = Transformation
else
#On a client
  window.Transformation = Transformation

