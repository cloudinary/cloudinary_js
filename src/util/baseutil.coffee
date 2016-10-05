
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

defaults = (destination, sources...)->
  sources.reduce(
    (dest, source)->
      for key, value of source when dest[key] == undefined
        dest[key] = value
      dest
    , destination
  )

###* Used to match words to create compound words. ###

reWords = do ->
  upper = '[A-Z]'
  lower = '[a-z]+'
  RegExp upper + '+(?=' + upper + lower + ')|' + upper + '?' + lower + '|' + upper + '+|[0-9]+', 'g'

camelCase = (source)->
  words = source.match(reWords)
  words = for word, i in words
    word = word.toLocaleLowerCase()
    if i then word.charAt(0).toLocaleUpperCase() + word.slice(1) else word
  words.join('')

snakeCase = (source)->
  words = source.match(reWords)
  words = for word, i in words
    word.toLocaleLowerCase()
  words.join('_')

convertKeys = (source, converter = Util.identity)->
  result = {}
  for key, value of source
    key = converter(key)
    result[key] = value unless Util.isEmpty(key)
  result

withCamelCaseKeys = (source)->
  convertKeys(source, Util.camelCase)

withSnakeCaseKeys = (source)->
  convertKeys(source, Util.snakeCase)

BaseUtil =
  ###*
   * Return true if all items in list are strings
   * @param {Array} list - an array of items
  ###
  allStrings: allStrings
  ###*
  * Convert string to camelCase
  * @param {string} string - the string to convert
  * @return {string} in camelCase format
  ###
  camelCase: camelCase
  convertKeys: convertKeys
  ###*
   * Assign values from sources if they are not defined in the destination.
   * Once a value is set it does not change
   * @param {Object} destination - the object to assign defaults to
   * @param {...Object} source - the source object(s) to assign defaults from
   * @return {Object} destination after it was modified
  ###
  defaults: defaults
  ###*
   * Convert string to snake_case
   * @param {string} string - the string to convert
   * @return {string} in snake_case format
  ###
  snakeCase: snakeCase
  ###*
  * Creates a new array without the given item.
  * @param {Array} array - original array
  * @param {*} item - the item to exclude from the new array
  * @return {Array} a new array made of the original array's items except for `item`
  ###
  without: without
  ###*
  * Return true is value is a number or a string representation of a number.
  * @example
  *    Util.isNumber(0) // true
  *    Util.isNumber("1.3") // true
  *    Util.isNumber("") // false
  *    Util.isNumber(undefined) // false
  ###
  isNumberLike: isNumberLike
  smartEscape: smartEscape
  withCamelCaseKeys: withCamelCaseKeys
  withSnakeCaseKeys: withSnakeCaseKeys