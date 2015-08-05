isJQuery = ->
  $?.fn?.jquery?

getData = ( element, name)->
  if isJQuery()
    $(element).data(name)
  else if _.isElement(element)
    element.getAttribute("data-#{name}")

setData = (element, name, value)->
  if isJQuery()
    $(element).data(name, value)
  else if _.isElement(element)
    element.setAttribute("data-#{name}", value)

getAttribute = ( element, name)->
  if isJQuery()
    $(element).attr(name)
  else if _.isElement(element)
    element.getAttribute(name)

setAttribute = (element, name, value)->
  if isJQuery()
    $(element).attr(name, value)
  else if _.isElement(element)
    element.setAttribute(name, value)

hasClass = (element, name)->
  if isJQuery()
    $(element).hasClass(name)
  else if _.isElement(element)
    element.className.match(new RegExp("\b" + name +"\b"))
