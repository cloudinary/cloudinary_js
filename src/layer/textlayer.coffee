class TextLayer extends Layer
  ###*
   * @constructor TextLayer
   * @param {Object} options - layer parameters
  ###
  constructor: (options)->
    super(options)
    @options.resourceType = "text"


  resourceType: (resourceType)->
    throw "Cannot modify resourceType for text layers"

  type: (type)->
    throw "Cannot modify type for text layers"

  format: (format)->
    throw "Cannot modify format for text layers"

  fontFamily: (fontFamily)->
    @options.fontFamily = fontFamily
    @

  fontSize: (fontSize)->
    @options.fontSize = fontSize
    @

  fontWeight: (fontWeight)->
    @options.fontWeight = fontWeight
    @

  fontStyle: (fontStyle)->
    @options.fontStyle = fontStyle
    @

  textDecoration: (textDecoration)->
    @options.textDecoration = textDecoration
    @

  textAlign: (textAlign)->
    @options.textAlign = textAlign
    @

  stroke: (stroke)->
    @options.stroke = stroke
    @

  letterSpacing: (letterSpacing)->
    @options.letterSpacing = letterSpacing
    @

  lineSpacing: (lineSpacing)->
    @options.lineSpacing = lineSpacing
    @

  text: (text)->
    @options.text = text
    @

  ###*
   * generate the string representation of the layer
   * @function TextLayer#toString
   * @return {String}
  ###
  toString: ()->
    if @options.publicId?
      publicId = @getFullPublicId()
    else if @options.text?
      text = encodeURIComponent(@options.text).replace(/%2C/g, "%E2%80%9A").replace(/\//g, "%E2%81%84")
    else
      throw "Must supply either text or public_id."

    components = [@options.resourceType, textStyleIdentifier.call(@), publicId, text]
    return Util.compact(components).join( ":")

  textStyleIdentifier = ()->
    components = []
    components.push(@options.fontWeight) unless @options.fontWeight == "normal"
    components.push(@options.fontStyle) unless @options.fontStyle == "normal"
    components.push(@options.textDecoration) unless @options.textDecoration == "none"
    components.push(@options.textAlign)
    components.push(@options.stroke) unless @options.stroke =="none"
    components.push("letter_spacing_" + @options.letterSpacing) unless Util.isEmpty(@options.letterSpacing)
    components.push("line_spacing_" + @options.lineSpacing) if @options.lineSpacing?
    fontSize = "" + @options.fontSize if @options.fontSize?
    components.unshift(@options.fontFamily, fontSize)

    components = Util.compact(components).join("_")

    unless Util.isEmpty(components)
      throw "Must supply fontFamily." if Util.isEmpty(@options.fontFamily)
      throw "Must supply fontSize." if Util.isEmpty(fontSize)

    return components
