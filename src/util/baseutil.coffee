
###
 * Includes common utility methods and shims
###

###*
 * Return true if all items in list are strings
 * @function Util.allString
 * @param {Array} list - an array of items
###
allStrings = (list)->
  for item in list
    return false unless Util.isString(item)
  return true

###*
* Creates a new array without the given item.
* @function Util.without
* @param {Array} array - original array
* @param {*} item - the item to exclude from the new array
* @return {Array} a new array made of the original array's items except for `item`
###
without = (array, item)->
  newArray = []
  i = -1; length = array.length;
  while ++i < length
    newArray.push(array[i]) if array[i] != item
  newArray

###*
* Return true is value is a number or a string representation of a number.
* @function Util.isNumberLike
* @param {*} value
* @returns {boolean} true if value is a number
* @example
*    Util.isNumber(0) // true
*    Util.isNumber("1.3") // true
*    Util.isNumber("") // false
*    Util.isNumber(undefined) // false
###
isNumberLike = (value)->
  value? && !isNaN(parseFloat(value))

###*
 * Escape all characters matching unsafe in the given string
 * @function Util.smartEscape
 * @param {string} string - source string to escape
 * @param {RegExp} unsafe - characters that must be escaped
 * @return {string} escaped string
###
smartEscape = (string, unsafe = /([^a-zA-Z0-9_.\-\/:]+)/g)->
  string.replace unsafe, (match)->
    match.split("").map((c)-> "%"+c.charCodeAt(0).toString(16).toUpperCase()).join("")

###*
 * Assign values from sources if they are not defined in the destination.
 * Once a value is set it does not change
 * @function Util.defaults
 * @param {Object} destination - the object to assign defaults to
 * @param {...Object} source - the source object(s) to assign defaults from
 * @return {Object} destination after it was modified
###
defaults = (destination, sources...)->
  sources.reduce(
    (dest, source)->
      for key, value of source when dest[key] == undefined
        dest[key] = value
      dest
    , destination
  )

###********** lodash functions ###
objectProto = Object.prototype

###*
# Used to resolve the [`toStringTag`](http://ecma-international.org/ecma-262/6.0/#sec-object.prototype.tostring)
# of values.
###

objToString = objectProto.toString

###*
# Checks if `value` is the [language type](https://es5.github.io/#x8) of `Object`.
# (e.g. arrays, functions, objects, regexes, `new Number(0)`, and `new String('')`)
#
# @param {*} value The value to check.
# @returns {boolean} Returns `true` if `value` is an object, else `false`.
# @example
#
#isObject({});
# // => true
#
#isObject([1, 2, 3]);
# // => true
#
#isObject(1);
# // => false
###

isObject = (value) ->
# Avoid a V8 JIT bug in Chrome 19-20.
# See https://code.google.com/p/v8/issues/detail?id=2291 for more details.
  type = typeof value
  ! !value and (type == 'object' or type == 'function')

funcTag = '[object Function]'

###*
* Checks if `value` is classified as a `Function` object.
* @function Util.isFunction
* @param {*} value The value to check.
* @returns {boolean} Returns `true` if `value` is correctly classified, else `false`.
* @example
*
* function Foo(){};  
* isFunction(Foo);
* // => true
*
* isFunction(/abc/);
* // => false
###
isFunction = (value) ->
# The use of `Object#toString` avoids issues with the `typeof` operator
# in older versions of Chrome and Safari which return 'function' for regexes
# and Safari 8 which returns 'object' for typed array constructors.
  isObject(value) and objToString.call(value) == funcTag

###********** lodash functions ###
  

###* Used to match words to create compound words. ###

reWords = do ->
  upper = '[A-Z]'
  lower = '[a-z]+'
  RegExp upper + '+(?=' + upper + lower + ')|' + upper + '?' + lower + '|' + upper + '+|[0-9]+', 'g'

###*
* Convert string to camelCase
* @function Util.camelCase
* @param {string} string - the string to convert
* @return {string} in camelCase format
###
camelCase = (source)->
  words = source.match(reWords)
  words = for word, i in words
    word = word.toLocaleLowerCase()
    if i then word.charAt(0).toLocaleUpperCase() + word.slice(1) else word
  words.join('')

###*
 * Convert string to snake_case
 * @function Util.snakeCase
 * @param {string} string - the string to convert
 * @return {string} in snake_case format
###
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

###*
 * Create a copy of the source object with all keys in camelCase
 * @function Util.withCamelCaseKeys
 * @param {Object} value - the object to copy
 * @return {Object} a new object
###
withCamelCaseKeys = (source)->
  convertKeys(source, Util.camelCase)

###*
 * Create a copy of the source object with all keys in snake_case
 * @function Util.withSnakeCaseKeys
 * @param {Object} value - the object to copy
 * @return {Object} a new object
###
withSnakeCaseKeys = (source)->
  convertKeys(source, Util.snakeCase)

base64Encode =  
  if typeof btoa != 'undefined' && isFunction(btoa)
    # Browser
    btoa
  else if typeof Buffer != 'undefined' && isFunction(Buffer)
    # Node.js
    (input)->
      input = new Buffer.from(String(input), 'binary') unless input instanceof Buffer
      input.toString('base64')
  else
    (input)->
      throw new Error("No base64 encoding function found")

###*
* Returns the Base64-decoded version of url.<br>
* This method delegates to `btoa` if present. Otherwise it tries `Buffer`.
* @function Util.base64EncodeURL
* @param {string} url - the url to encode. the value is URIdecoded and then re-encoded before converting to base64 representation
* @return {string} the base64 representation of the URL   
###
base64EncodeURL = (input)->
  try
    input = decodeURI(input)
  catch ignore
  
  input = encodeURI(input);
  base64Encode(input);
    
BaseUtil =
  allStrings: allStrings
  camelCase: camelCase
  convertKeys: convertKeys
  defaults: defaults
  snakeCase: snakeCase
  without: without
  isFunction: isFunction
  isNumberLike: isNumberLike
  smartEscape: smartEscape
  withCamelCaseKeys: withCamelCaseKeys
  withSnakeCaseKeys: withSnakeCaseKeys
  base64EncodeURL: base64EncodeURL