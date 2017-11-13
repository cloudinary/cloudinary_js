
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
# @static
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
# Checks if `value` is classified as a `Function` object.
#
# @static
# @param {*} value The value to check.
# @returns {boolean} Returns `true` if `value` is correctly classified, else `false`.
# @example
#
# function Foo(){};  
# isFunction(Foo);
# // => true
#
# isFunction(/abc/);
# // => false
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

base64EncodeURL = (input)->
  try
    input = decodeURI(input)
  catch ignore
  
  input = encodeURI(input);
  base64Encode(input);
  

    
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
  # Checks if `value` is classified as a `Function` object.
  #
  # @static
  # @param {*} value The value to check.
  # @returns {boolean} Returns `true` if `value` is correctly classified, else `false`.
  # @example
  #
  # function Foo(){};  
  # isFunction(Foo);
  # // => true
  #
  # isFunction(/abc/);
  # // => false
  ###
  isFunction: isFunction
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
  ###*
  * Returns the Base64-decoded version of url.<br>
  * This method delegates to `btoa` if present. Otherwise it tries `Buffer`.
  * @param {string} url - the url to encode. the value is URIdecoded and then re-encoded before converting to base64 representation
  * @return {string} the base64 representation of the URL   
  ###
  base64EncodeURL: base64EncodeURL