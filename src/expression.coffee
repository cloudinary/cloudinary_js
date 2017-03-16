class Expression

  ###*
   * @internal
  ###
  @OPERATORS =
    "=": 'eq'
    "!=": 'ne'
    "<": 'lt'
    ">": 'gt'
    "<=": 'lte'
    ">=": 'gte'
    "&&": 'and'
    "||": 'or'
    "*": "mul"
    "/": "div"
    "+": "add"
    "-": "sub"

  ###*
   * @internal
  ###

  @PREDEFINED_VARS =
    "aspect_ratio": "ar"
    "aspectRatio": "ar"
    "current_page": "cp"
    "currentPage": "cp"
    "face_count": "fc"
    "faceCount": "fc"
    "height": "h"
    "initial_aspect_ratio": "iar"
    "initial_height": "ih"
    "initial_width": "iw"
    "initialAspectRatio": "iar"
    "initialHeight": "ih"
    "initialWidth": "iw"
    "page_count": "pc"
    "page_x": "px"
    "page_y": "py"
    "pageCount": "pc"
    "pageX": "px"
    "pageY": "py"
    "tags": "tags"
    "width": "w"

  ###*
   * @internal
  ###
  @BOUNDRY = "[ _]+"

  ###*
   * Represents a transformation expression
   * @param {string} expressionStr - a expression in string format
   * @class Expression
   *
  ###
  constructor: (expressionStr)->
    ###*
      * @protected
      * @inner Expression-expressions
    ###
    @expressions = []

    @expressions.push(Expression.normalize(expressionStr)) if expressionStr?

  ###*
   * Convenience constructor method
   * @function Expression.new
  ###
  @new = (expressionStr)-> new @(expressionStr)

  ###*
   * Normalize a string expression
   * @function Cloudinary#normalize
   * @param {string} expression a expression, e.g. "w gt 100", "width_gt_100", "width > 100"
   * @return {string} the normalized form of the value expression, e.g. "w_gt_100"
  ###
  @normalize = (expression)->
    return expression unless expression?
    expression = String(expression)
    operators = "\\|\\||>=|<=|&&|!=|>|=|<|/|-|\\+|\\*"
    pattern = "((" + operators + ")(?=[ _])|" + Object.keys(Expression.PREDEFINED_VARS).join("|") + ")"
    replaceRE = new RegExp(pattern, "g")
    expression = expression.replace replaceRE, (match)->
      Expression.OPERATORS[match] || Expression.PREDEFINED_VARS[match]
    expression.replace(/[ _]+/g, '_')

  ###*
   * Serialize the expression
   * @return {string} the expression as a string
  ###
  serialize: ()->
    Expression.normalize(@expressions.join("_"))

  toString: ()->
    @serialize()

  ###*
   * Get the parent transformation of this expression
   * @return Transformation
  ###
  getParent: ()-> @parent

  ###*
   * Set the parent transformation of this expression
   * @param {Transformation} the parent transformation
   * @return {Expression} this expression
  ###
  setParent: (parent)->
    @parent = parent
    @

  ###*
   * Add a expression
   * @function Expression#predicate
   * @internal
  ###
  predicate: (name, operator, value)->
    operator = Expression.OPERATORS[operator] if Expression.OPERATORS[operator]?
    @expressions.push( "#{name}_#{operator}_#{value}")
    @

  ###*
   * @function Expression#and
  ###
  and: ()->
    @expressions.push("and")
    @

  ###*
   * @function Expression#or
  ###
  or: ()->
    @expressions.push("or")
    @

  ###*
   * Conclude expression
   * @function Expression#then
   * @return {Transformation} the transformation this expression is defined for
  ###
  then: ()-> @getParent().if(@toString())

  ###*
   * @function Expression#height
   * @param {string} operator the comparison operator (e.g. "<", "lt")
   * @param {string|number} value the right hand side value
   * @return {Expression} this expression
  ###
  height: (operator, value)-> @predicate("h", operator, value)

  ###*
   * @function Expression#width
   * @param {string} operator the comparison operator (e.g. "<", "lt")
   * @param {string|number} value the right hand side value
   * @return {Expression} this expression
  ###
  width: (operator, value)-> @predicate("w", operator, value)

  ###*
   * @function Expression#aspectRatio
   * @param {string} operator the comparison operator (e.g. "<", "lt")
   * @param {string|number} value the right hand side value
   * @return {Expression} this expression
  ###
  aspectRatio: (operator, value)-> @predicate("ar", operator, value)

  ###*
   * @function Expression#pages
   * @param {string} operator the comparison operator (e.g. "<", "lt")
   * @param {string|number} value the right hand side value
   * @return {Expression} this expression
  ###
  pageCount: (operator, value)-> @predicate("pc", operator, value)

  ###*
   * @function Expression#faces
   * @param {string} operator the comparison operator (e.g. "<", "lt")
   * @param {string|number} value the right hand side value
   * @return {Expression} this expression
  ###
  faceCount: (operator, value)-> @predicate("fc", operator, value)

  value: (value)->
    @expressions.push(value)
    @

  ###*
  ###
  @variable = (name, value)->
    new @(name).value(value)

  ###*
    * @returns a new expression with the predefined variable "width"
    * @function Expression.width
   ###
  @width = ()->
    new @("width")

  ###*
    * @returns a new expression with the predefined variable "height"
    * @function Expression.height
   ###
  @height = ()->
    new @("height")

  ###*
    * @returns a new expression with the predefined variable "initialWidth"
    * @function Expression.initialWidth
   ###
  @initialWidth = ()->
    new @("initialWidth")

  ###*
    * @returns a new expression with the predefined variable "initialHeight"
    * @function Expression.initialHeight
   ###
  @initialHeight = ()->
    new @("initialHeight")

  ###*
    * @returns a new expression with the predefined variable "aspectRatio"
    * @function Expression.aspectRatio
   ###
  @aspectRatio = ()->
    new @("aspectRatio")

  ###*
    * @returns a new expression with the predefined variable "initialAspectRatio"
    * @function Expression.initialAspectRatio
   ###
  @initialAspectRatio = ()->
    new @("initialAspectRatio")

  ###*
    * @returns a new expression with the predefined variable "pageCount"
    * @function Expression.pageCount
   ###
  @pageCount = ()->
    new @("pageCount")

  ###*
    * @returns a new expression with the predefined variable "faceCount"
    * @function Expression.faceCount
   ###
  faceCount = ()->
    new @("faceCount")

  ###*
    * @returns a new expression with the predefined variable "currentPage"
    * @function Expression.currentPage
   ###
  @currentPage = ()->
    new @("currentPage")

  ###*
    * @returns a new expression with the predefined variable "tags"
    * @function Expression.tags
   ###
  @tags = ()->
    new @("tags")

  ###*
    * @returns a new expression with the predefined variable "pageX"
    * @function Expression.pageX
   ###
  @pageX = ()->
    new @("pageX")

  ###*
    * @returns a new expression with the predefined variable "pageY"
    * @function Expression.pageY
   ###
  @pageY = ()->
    new @("pageY")
