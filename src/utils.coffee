getData = ( element, name)->
  if _.isElement(element)
    element.getAttribute("data-#{name}")
  else if element.jquery?
    element.data(name)


setData = (element, name, value)->
  if _.isElement(element)
    element.setAttribute("data-#{name}", value)
  else if element.jquery?
    element.data(name, value)

getAttribute = ( element, name)->
  if _.isElement(element)
    element.getAttribute(name)
  else if element.jquery?
    element.attr(name)

setAttribute = (element, name, value)->
  if _.isElement(element)
    element.setAttribute(name, value)
  else if element.jquery?
    element.attr(name, value)
