###*
  * Verifies that the `$` (global) variable is jQuery.
  *
  * If it is not, assume that jQuery is not available. (We are ignoring the possible "no conflict" scenario.)
  * @returns {boolean} true if `$` is a jQuery object
###
isJQuery = ->
  $?.fn?.jquery?

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
    $(element).data(name)
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
    $(element).data(name, value)
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
    $(element).attr(name)
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
    $(element).attr(name, value)
  else if _.isElement(element)
    element.setAttribute(name, value)

setAttributes = (element, attributes)->
  if isJQuery()
    $(element).attr(attributes)
  else
    for name, value of attributes
      if value?
        setAttribute(element, name, value)
      else
        element.removeAttribute(name)

hasClass = (element, name)->
  if isJQuery()
    $(element).hasClass(name)
  else if _.isElement(element)
    element.className.match(new RegExp("\b" + name +"\b"))
