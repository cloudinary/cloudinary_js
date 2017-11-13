
###
 * Includes utility methods and lodash / jQuery shims
###

###*
 * Get data from the DOM element.
 *
 * This method will use jQuery's `data()` method if it is available, otherwise it will get the `data-` attribute
 * @param {Element} element - the element to get the data from
 * @param {string} name - the name of the data item
 * @returns the value associated with the `name`
 * @function Util.getData
###
getData = ( element, name)->
  switch
    when !element?
      undefined
    when _.isFunction(element.getAttribute)
      element.getAttribute("data-#{name}")
    when _.isFunction(element.getAttr)
      element.getAttr("data-#{name}")
    when _.isFunction(element.data)
      element.data(name)
    when _.isFunction( jQuery?.fn?.data) && _.isElement(element)
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
setData = (element, name, value)->
  switch
    when !element?
      undefined
    when _.isFunction(element.setAttribute)
      element.setAttribute("data-#{name}", value)
    when _.isFunction(element.setAttr)
      element.setAttr("data-#{name}", value)
    when _.isFunction(element.data)
      element.data(name, value)
    when _.isFunction( jQuery?.fn?.data) && _.isElement(element)
      jQuery(element).data(name, value)

###*
 * Get attribute from the DOM element.
 *
 * @function Util.getAttribute
 * @param {Element} element - the element to set the attribute for
 * @param {string} name - the name of the attribute
 * @returns {*} the value of the attribute
 *
###
getAttribute = ( element, name)->
  switch
    when !element?
      undefined
    when _.isFunction(element.getAttribute)
      element.getAttribute(name)
    when _.isFunction(element.attr)
      element.attr(name)
    when _.isFunction(element.getAttr)
      element.getAttr(name)

###*
 * Set attribute in the DOM element.
 *
 * @function Util.setAttribute
 * @param {Element} element - the element to set the attribute for
 * @param {string} name - the name of the attribute
 * @param {*} value - the value to be set
###
setAttribute = (element, name, value)->
  switch
    when !element?
      undefined
    when _.isFunction(element.setAttribute)
      element.setAttribute(name, value)
    when _.isFunction(element.attr)
      element.attr(name, value)
    when _.isFunction(element.setAttr)
      element.setAttr(name, value)

###*
 * Remove an attribute in the DOM element.
 *
 * @function Util.removeAttribute
 * @param {Element} element - the element to set the attribute for
 * @param {string} name - the name of the attribute
###
removeAttribute = (element, name)->
  switch
    when !element?
      undefined
    when _.isFunction(element.removeAttribute)
      element.removeAttribute(name)
    else
      setAttribute(element, undefined)

###*
  * Set a group of attributes to the element
  * @function Util.setAttributes
  * @param {Element} element - the element to set the attributes for
  * @param {Object} attributes - a hash of attribute names and values
###
setAttributes = (element, attributes)->
    for name, value of attributes
      if value?
        setAttribute(element, name, value)
      else
        removeAttribute(element, name)

###*
  * Checks if element has a css class
  * @function Util.hasClass
  * @param {Element} element - the element to check
  * @param {string} name - the class name
  @returns {boolean} true if the element has the class
###
hasClass = (element, name)->
  if _.isElement(element)
    element.className.match(new RegExp("\\b#{name}\\b"))

###*
  * Add class to the element
  * @function Util.addClass
  * @param {Element} element - the element
  * @param {string} name - the class name to add
###
addClass = (element, name)->
  element.className = _.trim( "#{element.className} #{name}") unless element.className.match( new RegExp("\\b#{name}\\b"))

# The following code is taken from jQuery

getStyles = (elem) ->
# Support: IE<=11+, Firefox<=30+ (#15098, #14150)
# IE throws on elements created in popups
# FF meanwhile throws on frame elements through "defaultView.getComputedStyle"
    if elem.ownerDocument.defaultView.opener
      return elem.ownerDocument.defaultView.getComputedStyle(elem, null)
    window.getComputedStyle elem, null

cssExpand = [ "Top", "Right", "Bottom", "Left" ]

contains = (a, b) ->
  adown = (if a.nodeType is 9 then a.documentElement else a)
  bup = b and b.parentNode
  a is bup or !!(bup and bup.nodeType is 1 and adown.contains(bup))

# Truncated version of jQuery.style(elem, name)
domStyle = (elem, name) ->
  # Don't set styles on text and comment nodes
  unless !elem or elem.nodeType == 3 or elem.nodeType == 8 or !elem.style
    elem.style[name]

curCSS = (elem, name, computed) ->
  rmargin = (/^margin/)
  width = undefined
  minWidth = undefined
  maxWidth = undefined
  ret = undefined
  style = elem.style
  computed = computed or getStyles(elem)

  # Support: IE9
  # getPropertyValue is only needed for .css('filter') (#12537)
  ret = computed.getPropertyValue(name) or computed[name]  if computed
  if computed
    ret = domStyle(elem, name)  if ret is "" and not contains(elem.ownerDocument, elem)

    # Support: iOS < 6
    # A tribute to the "awesome hack by Dean Edwards"
    # iOS < 6 (at least) returns percentage for a larger set of values, but width seems to be reliably pixels
    # this is against the CSSOM draft spec: http://dev.w3.org/csswg/cssom/#resolved-values
    if rnumnonpx.test(ret) and rmargin.test(name)

      # Remember the original values
      width = style.width
      minWidth = style.minWidth
      maxWidth = style.maxWidth

      # Put in the new values to get a computed value out
      style.minWidth = style.maxWidth = style.width = ret
      ret = computed.width

      # Revert the changed values
      style.width = width
      style.minWidth = minWidth
      style.maxWidth = maxWidth

  # Support: IE
  # IE returns zIndex value as an integer.
  (if ret isnt `undefined` then ret + "" else ret)


cssValue = (elem, name, convert, styles)->
  val = curCSS( elem, name, styles )
  if convert then parseFloat( val ) else val

augmentWidthOrHeight = (elem, name, extra, isBorderBox, styles) ->

  # If we already have the right measurement, avoid augmentation
  # Otherwise initialize for horizontal or vertical properties
  if extra is (if isBorderBox then "border" else "content")
    0
  else
    sides = if name is "width" then [  "Right", "Left" ] else [ "Top", "Bottom" ]
    val = 0
    for side in sides
      # Both box models exclude margin, so add it if we want it
      val += cssValue( elem, extra + side, true, styles)  if extra is "margin"
      if isBorderBox
        # border-box includes padding, so remove it if we want content
        val -= cssValue( elem, "padding#{side}", true, styles)  if extra is "content"
        # At this point, extra isn't border nor margin, so remove border
        val -= cssValue( elem, "border#{side}Width", true, styles)  if extra isnt "margin"
      else
        # At this point, extra isn't content, so add padding
        val += cssValue( elem, "padding#{side}", true, styles)
        # At this point, extra isn't content nor padding, so add border
        val += cssValue( elem, "border#{side}Width", true, styles)  if extra isnt "padding"
    val

pnum = (/[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|)/).source
rnumnonpx = new RegExp( "^(" + pnum + ")(?!px)[a-z%]+$", "i" )

getWidthOrHeight = (elem, name, extra) ->
  # Start with offset property, which is equivalent to the border-box value
  valueIsBorderBox = true
  val = (if name is "width" then elem.offsetWidth else elem.offsetHeight)
  styles = getStyles(elem)
  isBorderBox = cssValue( elem, "boxSizing", false, styles) is "border-box"

  # Some non-html elements return undefined for offsetWidth, so check for null/undefined
  # svg - https://bugzilla.mozilla.org/show_bug.cgi?id=649285
  # MathML - https://bugzilla.mozilla.org/show_bug.cgi?id=491668
  if val <= 0 or not val?

  # Fall back to computed then uncomputed css if necessary
    val = curCSS(elem, name, styles)
    val = elem.style[name]  if val < 0 or not val?

    # Computed unit is not pixels. Stop here and return.
    return val  if rnumnonpx.test(val)

    # Check for style in case a browser which returns unreliable values
    # for getComputedStyle silently falls back to the reliable elem.style
#    valueIsBorderBox = isBorderBox and (support.boxSizingReliable() or val is elem.style[name])
    valueIsBorderBox = isBorderBox and (val is elem.style[name])

    # Normalize "", auto, and prepare for extra
    val = parseFloat(val) or 0

  # Use the active box-sizing model to add/subtract irrelevant styles
  (val + augmentWidthOrHeight(elem, name, extra or ((if isBorderBox then "border" else "content")), valueIsBorderBox, styles))

width = (element)->
  getWidthOrHeight(element, "width", "content")


###*
 * @class Util
###
Util = _.assign BaseUtil,
  hasClass: hasClass
  addClass: addClass
  getAttribute: getAttribute
  setAttribute: setAttribute
  removeAttribute: removeAttribute
  setAttributes: setAttributes
  getData: getData
  setData: setData
  width: width
  ###*
  # Returns true if item is a string
  # @function Util.isString
  # @param item
  # @returns {boolean} true if item is a string
  ###
  isString: _.isString
  isArray: _.isArray
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
  isEmpty: _.isEmpty
  ###*
   * Assign source properties to destination.
   * If the property is an object it is assigned as a whole, overriding the destination object.
   * @function Util.assign
   * @param {Object} destination - the object to assign to
  ###
  assign: _.assign
  ###*
   * Recursively assign source properties to destination
   * @function Util.merge
   * @param {Object} destination - the object to assign to
   * @param {...Object} [sources] The source objects.
  ###
  merge: _.merge
  ###*
   * Create a new copy of the given object, including all internal objects.
   * @function Util.cloneDeep
   * @param {Object} value - the object to clone
   * @return {Object} a new deep copy of the object
  ###
  cloneDeep: _.cloneDeep
  ###*
   * Creates a new array from the parameter with "falsey" values removed
   * @function Util.compact
   * @param {Array} array - the array to remove values from
   * @return {Array} a new array without falsey values
  ###
  compact: _.compact
  ###*
   * Check if a given item is included in the given array
   * @function Util.contains
   * @param {Array} array - the array to search in
   * @param {*} item - the item to search for
   * @return {boolean} true if the item is included in the array
  ###
  contains: _.includes
  ###*
   * Returns values in the given array that are not included in the other array
   * @function Util.difference
   * @param {Array} arr - the array to select from
   * @param {Array} values - values to filter from arr
   * @return {Array} the filtered values
  ###
  difference: _.difference
  ###*
   * Returns a list of all the function names in obj
   * @function Util.functions
   * @param {Object} object - the object to inspect
   * @return {Array} a list of functions of object
  ###
  functions: _.functions
  ###*
   * Returns the provided value. This functions is used as a default predicate function.
   * @function Util.identity
   * @param {*} value
   * @return {*} the provided value
  ###
  identity: _.identity
  isPlainObject: _.isPlainObject
  ###*
   * Remove leading or trailing spaces from text
   * @function Util.trim
   * @param {string} text
   * @return {string} the `text` without leading or trailing spaces
  ###
  trim: _.trim
