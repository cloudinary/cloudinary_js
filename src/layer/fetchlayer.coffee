class FetchLayer extends Layer
  ###*
   * @constructor FetchLayer
   * @param {Object|string} options - layer parameters or a url
  ###
  constructor: (options)->
    super(options)
    if( Util.isString(options))
      @options.url = options
    else if options?.url
      @options.url = options.url

  url: (url)->
    @options.url = url
    @

  ###*
   * generate the string representation of the layer
   * @function FetchLayer#toString
   * @return {String}
  ###
  toString: ()->
    "fetch:#{cloudinary.Util.base64EncodeURL(@options.url)}"
