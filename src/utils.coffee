###*
  * Includes utility methods and lodash / jQuery shims
###


###*
  * Verifies that jQuery is present.
  *
  * @returns {boolean} true if jQuery is defined
###
isJQuery = ->
  jQuery?

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
  if isJQuery()
    jQuery(element).data(name)
  else if _.isElement(element)
    element.getAttribute("data-#{name}")

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
  if isJQuery()
    jQuery(element).data(name, value)
  else if _.isElement(element)
    element.setAttribute("data-#{name}", value)

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
  if isJQuery()
    jQuery(element).attr(name)
  else if _.isElement(element)
    element.getAttribute(name)

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
  if isJQuery()
    jQuery(element).attr(name, value)
  else if _.isElement(element)
    element.setAttribute(name, value)

setAttributes = (element, attributes)->
  if isJQuery()
    jQuery(element).attr(attributes)
  else
    for name, value of attributes
      if value?
        setAttribute(element, name, value)
      else
        element.removeAttribute(name)

hasClass = (element, name)->
  if isJQuery()
    jQuery(element).hasClass(name)
  else if _.isElement(element)
    element.className.match(new RegExp("\\b#{name}\\b"))

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

curCSS = (elem, name, computed) ->
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
    ret = jQuery.style(elem, name)  if ret is "" and not contains(elem.ownerDocument, elem)

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
    valueIsBorderBox = isBorderBox and (support.boxSizingReliable() or val is elem.style[name])

    # Normalize "", auto, and prepare for extra
    val = parseFloat(val) or 0

  # Use the active box-sizing model to add/subtract irrelevant styles
  (val + augmentWidthOrHeight(elem, name, extra or ((if isBorderBox then "border" else "content")), valueIsBorderBox, styles))

#width = (element)


  ###
  The following lodash methods are used in this library.
  TODO create a shim that will switch between jQuery and lodash

  _.all
  _.any
  _.assign
  _.camelCase
  _.cloneDeep
  _.compact
  _.contains
  _.defaults
  _.difference
  _.extend
  _.filter
  _.identity
  _.includes
  _.isArray
  _.isElement
  _.isEmpty
  _.isFunction
  _.isObject
  _.isPlainObject
  _.isString
  _.isUndefined
  _.map
  _.mapValues
  _.merge
  _.omit
  _.parseInt
  _.snakeCase
  _.trim
  _.trimRight

  ###
# unless running on server side, export to the windows object
unless module?.exports? || exports?
  exports = window

exports.Cloudinary ?= {}
exports.Cloudinary.getWidthOrHeight = getWidthOrHeight
