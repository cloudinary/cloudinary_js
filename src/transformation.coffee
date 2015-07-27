
class TransformationBase

  constructor: (options = {})->

    ###*
    # Parameters that are filtered out before passing the options to an HTML tag
    ###
    @PARAM_NAMES = [
      "angle"
      "api_key"
      "api_secret"
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
      "url_suffix"
      "use_root_path"
      "version"
      "video_codec"
      "video_sampling"
      "width"
      "x"
      "y"
      "zoom"

    ]


    trans = {}
    @whitelist = _(TransformationBase.prototype).functions().map(_.snakeCase).value()

    @toOptions = ()->
      _.mapValues(trans, (t)-> t.value)

    @param = (value, name, abbr, defaultValue, process) ->
      unless process?
        if _.isFunction(defaultValue)
          process = defaultValue
        else
          process = _.identity
      #console.dir(@)
      #console.dir(@trans)
      trans[name] = new Param(name, abbr, process).set(value)
      @

    @rawParam = (value, name, abbr, defaultValue, process = _.identity) ->
      process = defaultValue if _.isFunction(defaultValue) && !process?
      trans[name] = new RawParam(name, abbr, process).set(value)
      @

  #  fetchParam: (value, name, abbr, defaultValue, process = _.identity) ->
  #    process = defaultValue if _.isFunction(defaultValue) && !process?
  #    @trans[name] = new FetchParam(name, abbr, process).set(value)

    @rangeParam = (value, name, abbr, defaultValue, process = _.identity) ->
      process = defaultValue if _.isFunction(defaultValue) && !process?
      trans[name] = new RangeParam(name, abbr, process).set(value)
      @

    @arrayParam = (value, name, abbr, sep = ":", defaultValue = [], process = _.identity) ->
      process = defaultValue if _.isFunction(defaultValue) && !process?
      trans[name] = new ArrayParam(name, abbr, sep, process).set(value)
      @

    @transformationParam = (value, name, abbr, sep = ".", defaultValue, process = _.identity) ->
      process = defaultValue if _.isFunction(defaultValue) && !process?
      trans[name] = new TransformationParam(name, abbr, sep, process).set(value)
      @

    @getValue = (name)->
      trans[name]?.value

    @get = (name)->
      trans[name]

    @remove = (name)->
      temp = trans[name]
      delete trans[name]
      temp

    @keys = ()->
      _(trans).keys().map(_.snakeCase).value().sort()

    @toPlainObject = ()->
      hash = {}
      hash[key] = trans[key].value for key of trans
      hash


  angle: (value)->            @arrayParam value, "angle", "a", "."
  audioCodec: (value)->      @param value, "audio_codec", "ac"
  audioFrequency: (value)->  @param value, "audio_frequency", "af"
  background: (value)->       @param value, "background", "b", Param.norm_color
  bitRate: (value)->         @param value, "bit_rate", "br"
  border: (value)->           @param value, "border", "bo", (border) ->
    if (_.isPlainObject(border))
      border = _.assign({}, {color: "black", width: 2}, border)
      "#{border.width}px_solid_#{Param.norm_color(border.color)}"
    else
      border
  color: (value)->            @param value, "color", "co", Param.norm_color
  colorSpace: (value)->      @param value, "color_space", "cs"
  crop: (value)->             @param value, "crop", "c"
  defaultImage: (value)->    @param value, "default_image", "d"
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
  endOffset: (value)->       @rangeParam value,  "end_offset", "eo"
  fetchFormat: (value)->     @param value,       "fetch_format", "f"
  format: (value)->           @param value,       "format"
  flags: (value)->            @arrayParam value,  "flags", "fl", "."
  gravity: (value)->          @param value,       "gravity", "g"
  height: (value)->           @param value,       "height", "h", =>
    if _.any([ @getValue("crop"), @getValue("overlay"), @getValue("underlay")])
      value
    else
      null
  htmlHeight: (value)->      @param value, "html_height"
  htmlWidth:(value)->        @param value, "html_width"
  offset: (value)->
    [start_o, end_o] = if( _.isFunction(value?.split))
      value.split('..')
    else if _.isArray(value)
      value
    else
      [null,null]
    @startOffset(start_o) if start_o?
    @endOffset(end_o) if end_o?
  opacity: (value)->          @param value, "opacity",  "o"
  overlay: (value)->          @param value, "overlay",  "l"
  page: (value)->             @param value, "page",     "pg"
  prefix: (value)->           @param value, "prefix",   "p"
  quality: (value)->          @param value, "quality",  "q"
  radius: (value)->           @param value, "radius",   "r"
  rawTransformation: (value)-> @rawParam value, "raw_transformation"
  size: (value)->
    if( _.isFunction(value?.split))
      [width, height] = value.split('x')
      @width(width)
      @height(height)
  startOffset: (value)->     @rangeParam value, "start_offset", "so"
  transformation: (value)->   @transformationParam value, "transformation"
  underlay: (value)->         @param value, "underlay", "u"
  videoCodec: (value)->      @param value, "video_codec", "vc", process_video_params
  videoSampling: (value)->   @param value, "video_sampling", "vs"
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
    parent = null
    @otherOptions = {}
    super(options)
    @fromOptions(options)

    @setParent = (object)->
      parent = object

    @getParent = ()->
      parent

  fromOptions: (options = {}) ->
    options = _.cloneDeep(options)
    options = {transformation: options } if _.isString(options) || _.isArray(options)

    for key, opt of options
      if _.includes( @whitelist, key)
        this[_.camelCase(key)](opt)
      else
        @otherOptions[key] = opt
    this

  @new = (args)-> new Transformation(args)

  hasLayer: ()->
    @getValue("overlay") || @getValue("underlay") || @getValue("angle")

  flatten: ->
    resultArray = []
    transformations = @remove("transformation");
    if transformations
      resultArray = resultArray.concat( transformations.flatten())

    transformationString = (@get(t)?.flatten() for t in @keys() )
    transformationString = _.filter(transformationString, (value)->
      _.isArray(value) &&!_.isEmpty(value) || !_.isArray(value) && value
    ).join(',')
    resultArray.push(transformationString) unless _.isEmpty(transformationString)
    _.compact(resultArray).join('/')

  listNames: ->
    @whitelist


  ###*
  # Returns an options object with attributes for an HTML tag.
  # @return Object
  ###
  toHtmlAttributes: ()->
    options = _.omit( @otherOptions, @PARAM_NAMES)
    options[key] = @get(key).value for key in _.difference(@keys(), @PARAM_NAMES)
    # convert all "html_key" to "key" with the same value
    for k,v of options when /^html_/.exec(k)
      options[k.substr(5)] = v
      delete options[k]

    unless @hasLayer() || _.contains( ["fit", "limit", "lfill"],@getValue("crop"))
      width = @getValue("width")
      height = @getValue("height")
      if parseFloat(width) >= 1.0
        options['width'] ?= width
      if parseFloat(height) >= 1.0
        options['height'] ?= height
    options

  isValidParamName: (name) ->
    @whitelist.indexOf(name) >= 0


# unless running on server side, export to the windows object
unless module?.exports? || exports?
  exports = window

exports.Cloudinary ?= {}
exports.Cloudinary.Transformation = Transformation


#.transformation(t).url()
#new ImageTag().transformation().width(100).render()
#new Transformation().width(100).render()
#c.imageTag("sample").transformation().width(100).render()
