class Condition extends Expression
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
    super(conditionStr)

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


