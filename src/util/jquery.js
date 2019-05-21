/* eslint-env jquery */

/**
  * Includes utility methods and lodash / jQuery shims
 */
export * from './baseutil';

/**
  * Get data from the DOM element.
  *
  * This method will use jQuery's `data()` method if it is available, otherwise it will get the `data-` attribute
  * @param {Element} element - the element to get the data from
  * @param {string} name - the name of the data item
  * @returns the value associated with the `name`
  * @function Util.getData
 */
export function getData(element, name) {
  return jQuery(element).data(name);
}

/**
* Set data in the DOM element.
*
* This method will use jQuery's `data()` method if it is available, otherwise it will set the `data-` attribute
* @function Util.setData
* @param {Element} element - the element to set the data in
* @param {string} name - the name of the data item
* @param {*} value - the value to be set
*
 */
export function setData(element, name, value) {
  return jQuery(element).data(name, value);
}

/**
* Get attribute from the DOM element.
*
* This method will use jQuery's `attr()` method if it is available, otherwise it will get the attribute directly
* @function Util.getAttribute
* @param {Element} element - the element to set the attribute for
* @param {string} name - the name of the attribute
* @returns {*} the value of the attribute
*
 */
export function getAttribute(element, name) {
  return jQuery(element).attr(name);
}

/**
* Set attribute in the DOM element.
*
* This method will use jQuery's `attr()` method if it is available, otherwise it will set the attribute directly
* @function Util.setAttribute
* @param {Element} element - the element to set the attribute for
* @param {string} name - the name of the attribute
* @param {*} value - the value to be set
 */
export function setAttribute(element, name, value) {
  return jQuery(element).attr(name, value);
}

/**
 * Remove an attribute in the DOM element.
 *
 * @function Util.removeAttribute
 * @param {Element} element - the element to set the attribute for
 * @param {string} name - the name of the attribute
 */
export function removeAttribute(element, name) {
  return jQuery(element).removeAttr(name);
}

/**
* Set a group of attributes to the element
* @function Util.setAttributes
* @param {Element} element - the element to set the attributes for
* @param {Object} attributes - a hash of attribute names and values
 */
export function setAttributes(element, attributes) {
  return jQuery(element).attr(attributes);
}

/**
* Checks if element has a css class
* @function Util.hasClass
* @param {Element} element - the element to check
* @param {string} name - the class name
@returns {boolean} true if the element has the class
 */
export function hasClass(element, name) {
  return jQuery(element).hasClass(name);
}

/**
* Add class to the element
* @function Util.addClass
* @param {Element} element - the element
* @param {string} name - the class name to add
 */
export function addClass(element, name) {
  return jQuery(element).addClass(name);
}

export function width(element) {
  return jQuery(element).width();
}

/**
 * Returns true if item is a string
 * @param item
 * @returns {boolean} true if item is a string
 */
export function isString(item) {
  return typeof item === 'string' || (item != null ? item.toString() : void 0) === '[object String]';
}

/**
 * Recursively assign source properties to destination
 * @function Util.merge
 * @param {Object} destination - the object to assign to
 * @param {...Object} [sources] The source objects.
 */
export function merge(destination, ...sources) {
  return jQuery.extend(true, destination, ...sources);
}

/**
 * Creates a new array from the parameter with "falsey" values removed
 * @function Util.compact
 * @param {Array} array - the array to remove values from
 * @return {Array} a new array without falsey values
 */
export function compact(arr) {
  var item, j, len, results;
  results = [];
  for (j = 0, len = arr.length; j < len; j++) {
    item = arr[j];
    if (item) {
      results.push(item);
    }
  }
  return results;
}

/**
 * Create a new copy of the given object, including all internal objects.
 * @function Util.cloneDeep
 * @param {Object} value - the object to clone
 * @return {Object} a new deep copy of the object
 */
export function cloneDeep(value) {
  return jQuery.extend(true, {}, value);
}

/**
 * Check if a given item is included in the given array
 * @function Util.contains
 * @param {Array} array - the array to search in
 * @param {*} item - the item to search for
 * @return {boolean} true if the item is included in the array
 */
export function contains(arr, item) {
  var i, j, len;
  for (j = 0, len = arr.length; j < len; j++) {
    i = arr[j];
    if (i === item) {
      return true;
    }
  }
  return false;
}

/**
 * Returns values in the given array that are not included in the other array
 * @function Util.difference
 * @param {Array} arr - the array to select from
 * @param {Array} values - values to filter from arr
 * @return {Array} the filtered values
 */
export function difference(arr, values) {
  var item, j, len, results;
  results = [];
  for (j = 0, len = arr.length; j < len; j++) {
    item = arr[j];
    if (!contains(values, item)) {
      results.push(item);
    }
  }
  return results;
}

/**
 * Returns a list of all the function names in obj
 * @function Util.functions
 * @param {Object} object - the object to inspect
 * @return {Array} a list of functions of object
 */
export function functions(object) {
  var i, results;
  results = [];
  for (i in object) {
    if (jQuery.isFunction(object[i])) {
      results.push(i);
    }
  }
  return results;
}

/**
 * Returns the provided value. This functions is used as a default predicate function.
 * @function Util.identity
 * @param {*} value
 * @return {*} the provided value
 */
export function identity(value) {
  return value;
}

/**
 * @class Util
 */
export const isArray = jQuery.isArray;

export const assign = jQuery.extend;

export const isPlainObject = jQuery.isPlainObject;

/**
 * Remove leading or trailing spaces from text
 * @function Util.trim
 * @param {string} text
 * @return {string} the `text` without leading or trailing spaces
 */
export const trim = jQuery.trim;

/**
 * Return true if all items in list are strings
 * @function Util.allString
 * @param {Array} list - an array of items
 */
export function allStrings(list) {
  return list.length && list.every(isString);
}
