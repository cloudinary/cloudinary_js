###*
  * Includes utility methods and lodash / jQuery shims
###
#/**
# * @license
# * lodash 3.10.0 (Custom Build) <https://lodash.com/>
#* Build: `lodash modern -o ./lodash.js`
#* Copyright 2012-2015 The Dojo Foundation <http://dojofoundation.org/>
#* Based on Underscore.js 1.8.3 <http://underscorejs.org/LICENSE>
#* Copyright 2009-2015 Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors
#* Available under MIT license <https://lodash.com/license>
#*/
# For
###*
  * Get data from the DOM element.
  *
  * This method will use jQuery's `data()` method if it is available, otherwise it will get the `data-` attribute
  * @param {Element} element - the element to get the data from
  * @param {String} name - the name of the data item
  * @returns the value associated with the `name`
  *
###
getData = ( element, name)->
  jQuery(element).data(name)

###*
  * Set data in the DOM element.
  *
  * This method will use jQuery's `data()` method if it is available, otherwise it will set the `data-` attribute
  * @param {Element} element - the element to set the data in
  * @param {String} name - the name of the data item
  * @param {*} value - the value to be set
  *
###
setData = (element, name, value)->
  jQuery(element).data(name, value)

###*
  * Get attribute from the DOM element.
  *
  * This method will use jQuery's `attr()` method if it is available, otherwise it will get the attribute directly
  * @param {Element} element - the element to set the attribute for
  * @param {String} name - the name of the attribute
  * @returns {*} the value of the attribute
  *
###
getAttribute = ( element, name)->
  jQuery(element).attr(name)
###*
  * Set attribute in the DOM element.
  *
  * This method will use jQuery's `attr()` method if it is available, otherwise it will set the attribute directly
  * @param {Element} element - the element to set the attribute for
  * @param {String} name - the name of the attribute
  * @param {*} value - the value to be set
  *
###
setAttribute = (element, name, value)->
  jQuery(element).attr(name, value)

setAttributes = (element, attributes)->
  jQuery(element).attr(attributes)

hasClass = (element, name)->
  jQuery(element).hasClass(name)

addClass = (element, name)->
  jQuery(element).addClass( name)


width = (element)->
  jQuery(element).width()

isEmpty = (item)->
  (jQuery.isArray(item) || Util.isString(item)) && item.length == 0 ||
  (jQuery.isPlainObject(item) && jQuery.isEmptyObject(item))


allStrings = (list)->
  for item in list
    return false unless Util.isString(item)
  return true

isString = (item)->
  typeof item == 'string' || item?.toString() == '[object String]'

merge = ()->
  arguments.unshift(true) # deep extend
  jQuery.extend.apply(this, arguments )

###* Used to match words to create compound words. ###

reWords = do ->
  upper = '[A-Z\\xc0-\\xd6\\xd8-\\xde]'
  lower = '[a-z\\xdf-\\xf6\\xf8-\\xff]+'
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

compact = (arr)->
  for item in arr when item
    item

cloneDeep = ()->
  args = jQuery.makeArray(arguments)
  args.unshift({}) # add "fresh" destination
  args.unshift(true) # deep
  jQuery.extend.apply(this, args)

contains = (arr, item)->
  for i in arr when i == item
    return true
  return false

defaults = ()->
  args = []
  return arguments[0] if arguments.length == 1
  for a in arguments
    args.unshift(a)
  first = args.pop()
  args.unshift(first)
  jQuery.extend.apply(this, args)

difference = (arr, values)->
  for item in arr when !contains(values, item)
    item

#  The following lodash methods are used in this library.
#  TODO create a shim that will switch between jQuery and lodash
#
#_.cloneDeep
#_.compact
#_.contains
#_.defaults
#_.difference
#_.extend
#_.filter
#_.forEach
#_.functions
#_.identity
#_.includes
#_.isElement
#_.isEmpty
#_.isFunction
#_.isObject
#_.isPlainObject
#_.isUndefined
#_.keys
#_.map
#_.mapValues
#_.omit
#_.parseInt
#_.snakeCase
#_.trim
#_.trimRight
#_.without


Util =
  hasClass: hasClass
  addClass: addClass
  getAttribute: getAttribute
  setAttribute: setAttribute
  setAttributes: setAttributes
  getData: getData
  setData: setData
  width: width
  ###*
   * Return true if all items in list are strings
   * @param {array} list - an array of items
  ###
  allStrings: allStrings
  isString: isString
  isArray: jQuery.isArray
  isEmpty: isEmpty
  ###*
   * Assign source properties to destination.
   * If the property is an object it is assigned as a whole, overriding the destination object.
   * @param {object} destination - the object to assign to
  ###
  assign: jQuery.extend
  ###*
   * Recursively assign source properties to destination
  * @param {object} destination - the object to assign to
   * @param {...object} [sources] The source objects.
  ###
  merge: merge
  ###*
   * Convert string to camelCase
   * @param {string} string - the string to convert
   * @return {string} in camelCase format
  ###
  camelCase: camelCase
  ###*
   * Convert string to snake_case
   * @param {string} string - the string to convert
   * @return {string} in snake_case format
  ###
  snakeCase: snakeCase
  ###*
   * Create a new copy of the given object, including all internal objects.
   * @param {object} value - the object to clone
   * @return {object} a new deep copy of the object
  ###
  cloneDeep: cloneDeep
  ###*
   * Creates a new array from the parameter with "falsey" values removed
   * @param {Array} array - the array to remove values from
   * @return {Array} a new array without falsey values
  ###
  compact: compact
  ###*
   * Check if a given item is included in the given array
   * @param {Array} array - the array to search in
   * @param {*} item - the item to search for
   * @return {boolean} true if the item is included in the array
  ###
  contains: contains
  ###*
   * Assign values from sources if they are not defined in the destination.
   * Once a value is set it does not change
   * @param {object} destination - the object to assign defaults to
   * @param {...object} source - the source object(s) to assign defaults from
   * @return {object} destination after it was modified
  ###
  defaults: defaults
  ###*
   * Returns values in the given array that are not included in the other array
   * @param {Array} arr - the array to select from
   * @param {Array} values - values to filter from arr
   * @return {Array} the filtered values
  ###
  difference: difference
