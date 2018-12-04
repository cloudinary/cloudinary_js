
###*
  * Includes utility methods and lodash / jQuery shims
###
export * from './baseutil'
###*
  * Get data from the DOM element.
  *
  * This method will use jQuery's `data()` method if it is available, otherwise it will get the `data-` attribute
  * @param {Element} element - the element to get the data from
  * @param {string} name - the name of the data item
  * @returns the value associated with the `name`
  * @function Util.getData
###
export getData = ( element, name)->
  jQuery(element).data(name)

###*
  * Set data in the DOM element.
  *
  * This method will use jQuery's `data()` method if it is available, otherwise it will set the `data-` attribute
  * @function Util.setData
  * @param {Element} element - the element to set the data in
  * @param {string} name - the name of the data item
  * @param {*} value - the value to be set
  *
###
export setData = (element, name, value)->
  jQuery(element).data(name, value)

###*
  * Get attribute from the DOM element.
  *
  * This method will use jQuery's `attr()` method if it is available, otherwise it will get the attribute directly
  * @function Util.getAttribute
  * @param {Element} element - the element to set the attribute for
  * @param {string} name - the name of the attribute
  * @returns {*} the value of the attribute
  *
###
export getAttribute = ( element, name)->
  jQuery(element).attr(name)
###*
  * Set attribute in the DOM element.
  *
  * This method will use jQuery's `attr()` method if it is available, otherwise it will set the attribute directly
  * @function Util.setAttribute
  * @param {Element} element - the element to set the attribute for
  * @param {string} name - the name of the attribute
  * @param {*} value - the value to be set
###
export setAttribute = (element, name, value)->
  jQuery(element).attr(name, value)

###*
 * Remove an attribute in the DOM element.
 *
 * @function Util.removeAttribute
 * @param {Element} element - the element to set the attribute for
 * @param {string} name - the name of the attribute
###
export removeAttribute = (element, name)->
  jQuery(element).removeAttr(name)

###*
  * Set a group of attributes to the element
  * @function Util.setAttributes
  * @param {Element} element - the element to set the attributes for
  * @param {Object} attributes - a hash of attribute names and values
###
export setAttributes = (element, attributes)->
  jQuery(element).attr(attributes)

###*
  * Checks if element has a css class
  * @function Util.hasClass
  * @param {Element} element - the element to check
  * @param {string} name - the class name
  @returns {boolean} true if the element has the class
###
export hasClass = (element, name)->
  jQuery(element).hasClass(name)

###*
  * Add class to the element
  * @function Util.addClass
  * @param {Element} element - the element
  * @param {string} name - the class name to add
###
export addClass = (element, name)->
  jQuery(element).addClass( name)


export width = (element)->
  jQuery(element).width()

###*
# Returns true if item is empty:
# <ul>
#   <li>item is null or undefined</li>
#   <li>item is an array or string of length 0</li>
#   <li>item is an object with no keys</li>
# </ul>
# @function Util.isEmpty
# @param item
# @returns {boolean} true if item is empty
###
export isEmpty = (item)->
  !item? ||
  (jQuery.isArray(item) || Util.isString(item)) && item.length == 0 ||
  (jQuery.isPlainObject(item) && jQuery.isEmptyObject(item))


###*
# Returns true if item is a string
# @param item
# @returns {boolean} true if item is a string
###
export isString = (item)->
  typeof item == 'string' || item?.toString() == '[object String]'

###*
 * Recursively assign source properties to destination
 * @function Util.merge
 * @param {Object} destination - the object to assign to
 * @param {...Object} [sources] The source objects.
###
export merge = ()->
  args = (i for i in arguments)
  args.unshift(true) # deep extend
  jQuery.extend.apply(this, args )

###*
 * Creates a new array from the parameter with "falsey" values removed
 * @function Util.compact
 * @param {Array} array - the array to remove values from
 * @return {Array} a new array without falsey values
###
export compact = (arr)->
  for item in arr when item
    item

###*
 * Create a new copy of the given object, including all internal objects.
 * @function Util.cloneDeep
 * @param {Object} value - the object to clone
 * @return {Object} a new deep copy of the object
###
export cloneDeep = ()->
  args = jQuery.makeArray(arguments)
  args.unshift({}) # add "fresh" destination
  args.unshift(true) # deep
  jQuery.extend.apply(this, args)

###*
 * Check if a given item is included in the given array
 * @function Util.contains
 * @param {Array} array - the array to search in
 * @param {*} item - the item to search for
 * @return {boolean} true if the item is included in the array
###
export contains = (arr, item)->
  for i in arr when i == item
    return true
  return false

###*
 * Returns values in the given array that are not included in the other array
 * @function Util.difference
 * @param {Array} arr - the array to select from
 * @param {Array} values - values to filter from arr
 * @return {Array} the filtered values
###
export difference = (arr, values)->
  for item in arr when !contains(values, item)
    item

###*
 * Returns a list of all the function names in obj
 * @function Util.functions
 * @param {Object} object - the object to inspect
 * @return {Array} a list of functions of object
###
export functions = (object)->
  for i of object when jQuery.isFunction(object[i])
    i

###*
 * Returns the provided value. This functions is used as a default predicate function.
 * @function Util.identity
 * @param {*} value
 * @return {*} the provided value
###
export identity = (value)-> value

###*
 * @class Util
###
export isArray = jQuery.isArray
export assign = jQuery.extend
export isPlainObject = jQuery.isPlainObject
  ###*
   * Remove leading or trailing spaces from text
   * @function Util.trim
   * @param {string} text
   * @return {string} the `text` without leading or trailing spaces
  ###
export trim = jQuery.trim
