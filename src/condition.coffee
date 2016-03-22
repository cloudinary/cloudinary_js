class Condition
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

  @PARAMETERS =
    "width": "w"
    "height": "h"
    "aspect_ratio": "ar"
    "aspectRatio": "ar"
    "page_count": "pc"
    "pageCount": "pc"
    "face_count": "fc"
    "faceCount": "fc"

  @BOUNDRY = "[ _]+"

  ###*
   * Represents a transformation condition
   * @param {string} conditionStr - a condition in string format
   * @class Condition
   * @example
   * // normally this class is not instantiated directly
   * var tr = cloudinary.Transformation.new()
   *    .if().width( ">", 1000).and().aspectRatio("<", "3:4").then()
   *      .width(1000)
   *      .crop("scale")
   *    .else()
   *      .width(500)
   *      .crop("scale")
   *
   * var tr = cloudinary.Transformation.new()
   *    .if("w > 1000 and aspectRatio < 3:4")
   *      .width(1000)
   *      .crop("scale")
   *    .else()
   *      .width(500)
   *      .crop("scale")
   *
  ###
  constructor: (conditionStr)->
    @predicate_list = []
    @predicate_list.push(@normalize(conditionStr)) if conditionStr?

  ###*
   * Convenience constructor method
   * @function Condition.new
  ###
  @new = (conditionStr)-> new @(conditionStr)

  ###*
   * Normalize a string condition
   * @function Cloudinary#normalize
   * @param {string} value a condition, e.g. "w gt 100", "width_gt_100", "width > 100"
   * @return {string} the normalized form of the value condition, e.g. "w_gt_100"
  ###
  normalize: (value)->
    replaceRE = new RegExp("(" + Object.keys(Condition.PARAMETERS).join("|") + "|[=<>&|!]+)", "g")
    value = value.replace replaceRE, (match)->
      Condition.OPERATORS[match] || Condition.PARAMETERS[match]
    value.replace(/[ _]+/g,'_')

  ###*
   * Get the parent transformation of this condition
   * @return Transformation
  ###
  getParent: ()-> @parent

  ###*
   * Set the parent transformation of this condition
   * @param {Transformation} the parent transformation
   * @return {Condition} this condition
  ###
  setParent: (parent)->
    @parent = parent
    @

  ###*
   * Serialize the condition
   * @return {string} the condition as a string
  ###
  toString: ()-> @predicate_list.join("_")

  ###*
   * Add a condition
   * @function Condition#predicate
   * @internal
  ###
  predicate: (name, operator, value)->
    operator = Condition.OPERATORS[operator] if Condition.OPERATORS[operator]?
    @predicate_list.push( "#{name}_#{operator}_#{value}")
    @

  ###*
   * @function Condition#and
  ###
  and: ()->
    @predicate_list.push("and")
    @

  ###*
   * @function Condition#or
  ###
  or: ()->
    @predicate_list.push("or")
    @

  ###*
   * Conclude condition
   * @function Condition#then
   * @return {Transformation} the transformation this condition is defined for
  ###
  then: ()-> @getParent().if(@toString())

  ###*
   * @function Condition#height
   * @param {string} operator the comparison operator (e.g. "<", "lt")
   * @param {string|number} value the right hand side value
   * @return {Condition} this condition
  ###
  height: (operator, value)-> @predicate("h", operator, value)

  ###*
   * @function Condition#width
   * @param {string} operator the comparison operator (e.g. "<", "lt")
   * @param {string|number} value the right hand side value
   * @return {Condition} this condition
  ###
  width: (operator, value)-> @predicate("w", operator, value)

  ###*
   * @function Condition#aspectRatio
   * @param {string} operator the comparison operator (e.g. "<", "lt")
   * @param {string|number} value the right hand side value
   * @return {Condition} this condition
  ###
  aspectRatio: (operator, value)-> @predicate("ar", operator, value)

  ###*
   * @function Condition#pages
   * @param {string} operator the comparison operator (e.g. "<", "lt")
   * @param {string|number} value the right hand side value
   * @return {Condition} this condition
  ###
  pageCount: (operator, value)-> @predicate("pc", operator, value)

  ###*
   * @function Condition#faces
   * @param {string} operator the comparison operator (e.g. "<", "lt")
   * @param {string|number} value the right hand side value
   * @return {Condition} this condition
  ###
  faceCount: (operator, value)-> @predicate("fc", operator, value)


