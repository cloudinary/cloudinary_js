class TextLayer extends Layer
  ###*
   * @constructor TextLayer
   * @param {Object} options - layer parameters
  ###
  constructor: (options)->
    super(options)
    keys =[
      "resourceType",
      "resourceType",
      "fontFamily",
      "fontSize",
      "fontWeight",
      "fontStyle",
      "textDecoration",
      "textAlign",
      "stroke",
      "letterSpacing",
      "lineSpacing",
      "text"
    ]
    if options?
      keys.forEach (key)=>
        @options[key] = options[key] ? options[Util.snakeCase(key)]
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
    style = @textStyleIdentifier()
    if @options.publicId?
      publicId = @getFullPublicId()
    if @options.text?
      hasPublicId = !Util.isEmpty(publicId)
      hasStyle = !Util.isEmpty(style)
      if hasPublicId && hasStyle || !hasPublicId && !hasStyle
        throw "Must supply either style parameters or a public_id when providing text parameter in a text overlay/underlay, but not both!"
      re = /\$\([a-zA-Z]\w*\)/g
      start = 0
      #        textSource = text.replace(new RegExp("[,/]", 'g'), (c)-> "%#{c.charCodeAt(0).toString(16).toUpperCase()}")
      textSource = Util.smartEscape(@options.text, /[,/]/g)
      text = ""
      while res = re.exec(textSource)
        text += Util.smartEscape(textSource.slice(start, res.index))
        text += res[0]
        start = res.index + res[0].length
      text += Util.smartEscape(textSource.slice(start))

    components = [@options.resourceType, style, publicId, text]
    return Util.compact(components).join( ":")

  textStyleIdentifier: ()->
    components = []
    components.push(@options.fontWeight) unless @options.fontWeight == "normal"
    components.push(@options.fontStyle) unless @options.fontStyle == "normal"
    components.push(@options.textDecoration) unless @options.textDecoration == "none"
    components.push(@options.textAlign)
    components.push(@options.stroke) unless @options.stroke == "none"
    components.push("letter_spacing_" + @options.letterSpacing) unless Util.isEmpty(@options.letterSpacing) && !Util.isNumberLike(@options.letterSpacing)
    components.push("line_spacing_" + @options.lineSpacing) unless Util.isEmpty(@options.lineSpacing) && !Util.isNumberLike(@options.lineSpacing)

    unless Util.isEmpty(Util.compact(components))
      throw "Must supply fontFamily. #{components}" if Util.isEmpty(@options.fontFamily)
      throw "Must supply fontSize." if Util.isEmpty(@options.fontSize) && !Util.isNumberLike(@options.fontSize)
    components.unshift(@options.fontFamily, @options.fontSize)
    components = Util.compact(components).join("_")
    return components
