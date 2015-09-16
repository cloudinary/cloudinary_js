###*
  * Includes utility methods and lodash / jQuery shims
###

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

#  The following lodash methods are used in this library.
#  TODO create a shim that will switch between jQuery and lodash
#
#_.camelCase
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
  assign: jQuery.extend
  ###*
   * Recursively assign source properties to destination
   * @param {object} destination - the
   * @param {...object} [sources] The source objects.
  ###
  merge: merge

