class Layer
  ###*
   * Layer
   * @constructor Layer
   * @param {Object} options - layer parameters
  ###
  constructor: (options)->
    @options = {}
    if options?
      ["resourceType", "type", "publicId", "format"].forEach (key)=>
        @options[key] = options[key] ? options[Util.snakeCase(key)]

  resourceType: (value)->
    @options.resourceType = value
    @

  type: (value)->
    @options.type = value
    @

  publicId: (value)->
    @options.publicId = value
    @

  ###*
   * Get the public ID, formatted for layer parameter
   * @function Layer#getPublicId
   * @return {String} public ID
  ###
  getPublicId: ()->
    @options.publicId?.replace(/\//g, ":")

  ###*
   * Get the public ID, with format if present
   * @function Layer#getFullPublicId
   * @return {String} public ID
  ###
  getFullPublicId: ()->
    if @options.format?
      @getPublicId() + "." + @options.format
    else
      @getPublicId()

  format: (value)->
    @options.format = value
    @

  ###*
   * generate the string representation of the layer
   * @function Layer#toString
  ###
  toString: ()->
    components = []

    throw "Must supply publicId" unless @options.publicId?
    components.push(@options.resourceType) unless (@options.resourceType == "image")
    components.push(@options.type) unless (@options.type == "upload")

    components.push(@getFullPublicId())

    Util.compact(components).join( ":")