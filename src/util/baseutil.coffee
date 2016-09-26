
###
 * Includes common utility methods and shims
###

allStrings = (list)->
  for item in list
    return false unless Util.isString(item)
  return true


without = (array, item)->
  newArray = []
  i = -1; length = array.length;
  while ++i < length
    newArray.push(array[i]) if array[i] != item
  newArray

isNumberLike = (value)->
  value? && !isNaN(parseFloat(value))

smartEscape = (string, unsafe = /([^a-zA-Z0-9_.\-\/:]+)/g)->
  string.replace unsafe, (match)->
    match.split("").map((c)-> "%"+c.charCodeAt(0).toString(16).toUpperCase()).join("")

BaseUtil =
  ###*
   * Return true if all items in list are strings
   * @param {Array} list - an array of items
  ###
  allStrings: allStrings
  ###*
  * Creates a new array without the given item.
  * @param {Array} array - original array
  * @param {*} item - the item to exclude from the new array
  * @return {Array} a new array made of the original array's items except for `item`
  ###
  without: without
  ###*
  * Return true is value is a number or a string represetantion of a number.
  * @example
  *    Util.isNumber(0) // true
  *    Util.isNumber("1.3") // true
  *    Util.isNumber("") // false
  *    Util.isNumber(undefined) // false
  ###
  isNumberLike: isNumberLike
  smartEscape: smartEscape