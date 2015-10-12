`/*
 * Cloudinary's jQuery library - v1.0.24
 * Copyright Cloudinary
 * see https://github.com/cloudinary/cloudinary_js
 */

(function (factory) {
    'use strict';
    if (typeof define === 'function' && define.amd) {
        // Register as an anonymous AMD module:
        define([
            'jquery',
            'tmpl',
            'load-image',
            'canvas'
        ], factory);
    } else {
        // Browser globals:
        window.cloudinary = factory(jQuery);
    }
}(function (jQuery) {
var cloudinary = {};
`

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
  args = (i for i in arguments)
  args.unshift(true) # deep extend
  jQuery.extend.apply(this, args )

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
  # reverse the order of the arguments
  for a in arguments
    args.unshift(a)
  # bring destination object back to the start
  first = args.pop()
  args.unshift(first)
  jQuery.extend.apply(this, args)

difference = (arr, values)->
  for item in arr when !contains(values, item)
    item

functions = (object)->
  for i of object when jQuery.isFunction(object[i])
    i

identity = (value)-> value

without = (array, item)->
  newArray = []
  i = -1; length = array.length;
  while ++i < length
    newArray.push(array[i]) if array[i] != item
  newArray

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
  ###*
   * Returns true if argument is a function.
   * @param {*} value - the value to check
   * @return {boolean} true if the value is a function
  ###
  isFunction: jQuery.isFunction
  ###*
   * Returns a list of all the function names in obj
   * @param {object} object - the object to inspect
   * @return {Array} a list of functions of object
  ###
  functions: functions
  ###*
   * Returns the provided value. This functions is used as a default predicate function.
   * @param {*} value
   * @return {*} the provided value
  ###
  identity: identity
  isPlainObject: jQuery.isPlainObject
  ###*
   * Remove leading or trailing spaces from text
   * @param {String} text
   * @return {String} the `text` without leading or trailing spaces
  ###
  trim: jQuery.trim
  ###*
   * Creates a new array without the given item.
   * @param {Array} array - original array
   * @param {*} item - the item to exclude from the new array
   * @return {Array} a new array made of the original array's items except for `item`
  ###
  without: without


#/**
# * @license
# * lodash 3.10.0 (Custom Build) <https://lodash.com/>
#* Build: `lodash modern -o ./lodash.js`
#* Copyright 2012-2015 The Dojo Foundation <http://dojofoundation.org/>
#* Based on Underscore.js 1.8.3 <http://underscorejs.org/LICENSE>
#* Copyright 2009-2015 Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors
#* Available under MIT license <https://lodash.com/license>
#*/

###*
 * Main Cloudinary class
###
class Cloudinary
  CF_SHARED_CDN = "d3jpl91pxevbkh.cloudfront.net";
  OLD_AKAMAI_SHARED_CDN = "cloudinary-a.akamaihd.net";
  AKAMAI_SHARED_CDN = "res.cloudinary.com";
  SHARED_CDN = AKAMAI_SHARED_CDN;
  DEFAULT_POSTER_OPTIONS = { format: 'jpg', resource_type: 'video' };
  DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv'];

  devicePixelRatioCache = {}
  responsiveConfig = {}
  responsiveResizeInitialized = false
  ###*
  * @const {object} Cloudinary.DEFAULT_IMAGE_PARAMS
  * Defaults values for image parameters.
  *
  * (Previously defined using option_consume() )
  ###
  @DEFAULT_IMAGE_PARAMS: {
    resource_type: "image"
    transformation: []
    type: 'upload'
  }

  ###*
  * Defaults values for video parameters.
  * @const {object} Cloudinary.DEFAULT_VIDEO_PARAMS
  * (Previously defined using option_consume() )
  ###
  @DEFAULT_VIDEO_PARAMS: {
    fallback_content: ''
    resource_type: "video"
    source_transformation: {}
    source_types: DEFAULT_VIDEO_SOURCE_TYPES
    transformation: []
    type: 'upload'
  }

  ###*
   * Main Cloudinary class
   * @class Cloudinary
   * @param {object} options - options to configure Cloudinary
   * @see Configuration for more details
   * @example
   *var cl = new cloudinary.Cloudinary( { cloud_name: "mycloud"});
   *var imgTag = cl.image("myPicID");
  ###
  constructor: (options)->
    configuration = new cloudinary.Configuration(options)

    # Provided for backward compatibility
    @config= (newConfig, newValue) ->
      configuration.config(newConfig, newValue)


    @fromDocument = ()->
      configuration.fromDocument()
      @


    @fromEnvironment = ()->
      configuration.fromEnvironment()
      @

    ###*
     * Initialize configuration.
     * @function Cloudinary#init
     * @see Configuration#init
     * @return {Cloudinary} this for chaining
    ###
    @init = ()->
      configuration.init()
      @

  @new = (options)-> new @(options)

  ###*
   * Return the resource type and action type based on the given configuration
   * @function Cloudinary#finalizeResourceType
   * @param {object|string} resource_type
   * @param {string} [type='upload']
   * @param {string} [url_suffix]
   * @param {boolean} [use_root_path]
   * @param {boolean} [shorten]
   * @returns {string} resource_type/type
   * @ignore
  ###
  finalizeResourceType = (resourceType,type,urlSuffix,useRootPath,shorten) ->
    if Util.isPlainObject(resourceType)
      options = resourceType
      resourceType = options.resource_type
      type = options.type
      urlSuffix = options.url_suffix
      useRootPath = options.use_root_path
      shorten = options.shorten

    type?='upload'
    if urlSuffix?
      if resourceType=='image' && type=='upload'
        resourceType = "images"
        type = null
      else if resourceType== 'raw' && type== 'upload'
        resourceType = 'files'
        type = null
      else
        throw new Error("URL Suffix only supported for image/upload and raw/upload")
    if useRootPath
      if (resourceType== 'image' && type== 'upload' || resourceType == "images")
        resourceType = null
        type = null
      else
        throw new Error("Root path only supported for image/upload")
    if shorten && resourceType== 'image' && type== 'upload'
      resourceType = 'iu'
      type = null
    [resourceType,type].join("/")

  absolutize = (url) ->
    if !url.match(/^https?:\//)
      prefix = document.location.protocol + '//' + document.location.host
      if url[0] == '?'
        prefix += document.location.pathname
      else if url[0] != '/'
        prefix += document.location.pathname.replace(/\/[^\/]*$/, '/')
      url = prefix + url
    url

  ###*
   * Generate an resource URL.
   * @function Cloudinary#url
   * @param {string} publicId - the public ID of the resource
   * @param {Object} [options] - options for the tag and transformations, possible values include all {@link Transformation} parameters
   *                          and {@link Configuration} parameters
   * @param {string} [options.type='upload'] - the classification of the resource
   * @param {Object} [options.resource_type='image'] - the type of the resource
   * @return {HTMLImageElement} an image tag element
  ###
  url: (publicId, options = {}) ->
    options = Util.defaults({}, options, @config(), Cloudinary.DEFAULT_IMAGE_PARAMS)
    if options.type == 'fetch'
      options.fetch_format = options.fetch_format or options.format
      publicId = absolutize(publicId)

    transformation = new Transformation(options)
    transformationString = transformation.serialize()

    throw 'Unknown cloud_name' unless options.cloud_name

    throw 'URL Suffix only supported in private CDN' if options.url_suffix and !options.private_cdn

    # if publicId has a '/' and doesn't begin with v<number> and doesn't start with http[s]:/ and version is empty
    if publicId.search('/') >= 0 and !publicId.match(/^v[0-9]+/) and !publicId.match(/^https?:\//) and !options.version?.toString()
      options.version = 1

    if publicId.match(/^https?:/)
      if options.type == 'upload' or options.type == 'asset'
        url = publicId
      else
        publicId = encodeURIComponent(publicId).replace(/%3A/g, ':').replace(/%2F/g, '/')
    else
      # Make sure publicId is URI encoded.
      publicId = encodeURIComponent(decodeURIComponent(publicId)).replace(/%3A/g, ':').replace(/%2F/g, '/')
      if options.url_suffix
        if options.url_suffix.match(/[\.\/]/)
          throw 'url_suffix should not include . or /'
        publicId = publicId + '/' + options.url_suffix
      if options.format
        if !options.trust_public_id
          publicId = publicId.replace(/\.(jpg|png|gif|webp)$/, '')
        publicId = publicId + '.' + options.format

    prefix = cloudinaryUrlPrefix(publicId, options)
    resourceTypeAndType = finalizeResourceType(options.resource_type, options.type, options.url_suffix, options.use_root_path, options.shorten)
    version = if options.version then 'v' + options.version else ''

    url ||  Util.compact([
      prefix
      resourceTypeAndType
      transformationString
      version
      publicId
    ]).join('/').replace(/([^:])\/+/g, '$1/')



  video_url: (publicId, options) ->
    options = Util.assign({ resource_type: 'video' }, options)
    @url(publicId, options)

  video_thumbnail_url: (publicId, options) ->
    options = Util.assign({}, DEFAULT_POSTER_OPTIONS, options)
    @url(publicId, options)

  transformation_string: (options) ->
    new Transformation( options).serialize()

  ###*
   * Generate an image tag.
   * @function Cloudinary#image
   * @param {string} publicId - the public ID of the image
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} an image tag element
  ###
  image: (publicId, options={}) ->
    # generate a tag without the image src
    tag_options = Util.assign( {src: ''}, options)
    img = @imageTag(publicId, tag_options).toDOM()
    # cache the image src
    Util.setData(img, 'src-cache', @url(publicId, options))
    # set image src taking responsiveness in account
    @cloudinary_update(img, options)
    img

  ###*
   * Creates a new ImageTag instance, configured using this own's configuration.
   * @function Cloudinary#imageTag
   * @param {string} publicId - the public ID of the resource
   * @param {object} options - additional options to pass to the new ImageTag instance
   * @return {ImageTag} an instance of ImageTag
  ###
  imageTag: (publicId, options)->
    options = Util.defaults({}, options, @config())
    new ImageTag(publicId, options)

  video_thumbnail: (publicId, options) ->
    @image publicId, Util.merge( {}, DEFAULT_POSTER_OPTIONS, options)

  facebook_profile_image: (publicId, options) ->
    @image publicId, Util.assign({type: 'facebook'}, options)

  twitter_profile_image: (publicId, options) ->
    @image publicId, Util.assign({type: 'twitter'}, options)

  twitter_name_profile_image: (publicId, options) ->
    @image publicId, Util.assign({type: 'twitter_name'}, options)

  gravatar_image: (publicId, options) ->
    @image publicId, Util.assign({type: 'gravatar'}, options)

  fetch_image: (publicId, options) ->
    @image publicId, Util.assign({type: 'fetch'}, options)

  video: (publicId, options = {}) ->
    @videoTag(publicId, options).toHtml()

  videoTag: (publicId, options)->
    options = Util.defaults({}, options, @config())
    new VideoTag(publicId, options)

  sprite_css: (publicId, options) ->
    options = Util.assign({ type: 'sprite' }, options)
    if !publicId.match(/.css$/)
      options.format = 'css'
    @url publicId, options

  responsive: (options) ->
    responsiveConfig = Util.merge(responsiveConfig or {}, options)
    @cloudinary_update 'img.cld-responsive, img.cld-hidpi', responsiveConfig
    responsiveResize = responsiveConfig['responsive_resize'] ? @config('responsive_resize') ? true
    if responsiveResize and !responsiveResizeInitialized
      responsiveConfig.resizing = responsiveResizeInitialized = true
      timeout = null
      window.addEventListener 'resize', =>
        debounce = responsiveConfig['responsive_debounce'] ? @config('responsive_debounce') ? 100

        reset = ->
          if timeout
            clearTimeout timeout
            timeout = null

        run = =>
          @cloudinary_update 'img.cld-responsive', responsiveConfig

        wait = ->
          reset()
          setTimeout (->
            reset()
            run()
          ), debounce

        if debounce
          wait()
        else
          run()

  calc_stoppoint: (element, width) ->
    stoppoints = Util.getData(element,'stoppoints') or @config('stoppoints') or defaultStoppoints
    if Util.isFunction stoppoints
      stoppoints(width)
    else
      if Util.isString stoppoints
        stoppoints = (parseInt(point) for point in stoppoints.split(',')).sort( (a,b) -> a - b )
      closestAbove stoppoints, width

  device_pixel_ratio: ->
    dpr = window?.devicePixelRatio or 1
    dprString = devicePixelRatioCache[dpr]
    if !dprString
      # Find closest supported DPR (to work correctly with device zoom)
      dprUsed = closestAbove(@supported_dpr_values, dpr)
      dprString = dprUsed.toString()
      if dprString.match(/^\d+$/)
        dprString += '.0'
      devicePixelRatioCache[dpr] = dprString
    dprString
  supported_dpr_values: [
    0.75
    1.0
    1.3
    1.5
    2.0
    3.0
  ]

  defaultStoppoints = (width) ->
    10 * Math.ceil(width / 10)

  closestAbove = (list, value) ->
    i = list.length - 2
    while i >= 0 and list[i] >= value
      i--
    list[i + 1]

  # Produce a number between 1 and 5 to be used for cdn sub domains designation
  cdnSubdomainNumber = (publicId)->
    crc32(publicId) % 5 + 1

  #  * cdn_subdomain - Boolean (default: false). Whether to automatically build URLs with multiple CDN sub-domains. See this blog post for more details.
  #  * private_cdn - Boolean (default: false). Should be set to true for Advanced plan's users that have a private CDN distribution.
  #  * secure_distribution - The domain name of the CDN distribution to use for building HTTPS URLs. Relevant only for Advanced plan's users that have a private CDN distribution.
  #  * cname - Custom domain name to use for building HTTP URLs. Relevant only for Advanced plan's users that have a private CDN distribution and a custom CNAME.
  #  * secure - Boolean (default: false). Force HTTPS URLs of images even if embedded in non-secure HTTP pages.
  cloudinaryUrlPrefix = (publicId, options) ->
    return '/res'+options.cloud_name if options.cloud_name?.indexOf("/")==0

    # defaults
    protocol = "http://"
    cdnPart = ""
    subdomain = "res"
    host = ".cloudinary.com"
    path = "/" + options.cloud_name

    # modifications
    if options.protocol
      protocol = options.protocol + '//'
    else if window?.location?.protocol == 'file:'
      protocol = 'file://'

    if options.private_cdn
      cdnPart = options.cloud_name + "-"
      path = ""

    if options.cdn_subdomain
      subdomain = "res-" + cdnSubdomainNumber(publicId)

    if options.secure
      protocol = "https://"
      subdomain = "res" if options.secure_cdn_subdomain == false
      if options.secure_distribution? &&
         options.secure_distribution != OLD_AKAMAI_SHARED_CDN &&
         options.secure_distribution != SHARED_CDN
        cdnPart = ""
        subdomain = ""
        host = options.secure_distribution

    else if options.cname
      protocol = "http://"
      cdnPart = ""
      subdomain = if options.cdn_subdomain then 'a'+((crc32(publicId)%5)+1)+'.' else ''
      host = options.cname
      #      path = ""

    [protocol, cdnPart, subdomain, host, path].join("")


  ###*
  * Finds all `img` tags under each node and sets it up to provide the image through Cloudinary
  * @function Cloudinary#processImageTags
  ###
  processImageTags: (nodes, options = {}) ->
    # similar to `$.fn.cloudinary`
    options = Util.defaults({}, options, @config())
    images = for node in nodes when node.tagName?.toUpperCase() == 'IMG'
        imgOptions = Util.assign({
          width: node.getAttribute('width')
          height: node.getAttribute('height')
          src: node.getAttribute('src')
        }, options)
        publicId = imgOptions['source'] || imgOptions['src']
        delete imgOptions['source']
        delete imgOptions['src']
        url = @url(publicId, imgOptions)
        imgOptions = new Transformation(imgOptions).toHtmlAttributes()
        Util.setData(node, 'src-cache', url)
        node.setAttribute('width', imgOptions.width)
        node.setAttribute('height', imgOptions.height)

    @cloudinary_update( images, options)
    this

  ###*
  * Update hidpi (dpr_auto) and responsive (w_auto) fields according to the current container size and the device pixel ratio.
  * Only images marked with the cld-responsive class have w_auto updated.
  * @function Cloudinary#cloudinary_update
  * @param {(Array|string|NodeList)} elements - the elements to modify
  * @param {object} options
  * @param {boolean|string} [options.responsive_use_stoppoints='resize']
  *  - when `true`, always use stoppoints for width
  * - when `"resize"` use exact width on first render and stoppoints on resize (default)
  * - when `false` always use exact width
  * @param {boolean} [options.responsive] - if `true`, enable responsive on this element. Can be done by adding cld-responsive.
  * @param {boolean} [options.responsive_preserve_height] - if set to true, original css height is preserved.
  *   Should only be used if the transformation supports different aspect ratios.
  ###
  cloudinary_update: (elements, options = {}) ->
    elements = switch
      when Util.isArray(elements)
        elements
      when elements.constructor.name == "NodeList"
        elements
      when Util.isString(elements)
        document.querySelectorAll(elements)
      else
        [elements]

    responsive_use_stoppoints = options['responsive_use_stoppoints'] ? @config('responsive_use_stoppoints') ? 'resize'
    exact = !responsive_use_stoppoints || responsive_use_stoppoints == 'resize' and !options.resizing
    for tag in elements when tag.tagName?.match(/img/i)
      if options.responsive
        Util.addClass(tag, "cld-responsive")
      attrs = {}
      src = Util.getData(tag, 'src-cache') or Util.getData(tag, 'src')
      if !src
        return
      responsive = Util.hasClass(tag, 'cld-responsive') and src.match(/\bw_auto\b/)
      if responsive
        container = tag.parentNode
        containerWidth = 0
        while container and containerWidth == 0
          containerWidth = Util.width(container)
          container = container.parentNode
        if containerWidth == 0
          # container doesn't know the size yet. Usually because the image is hidden or outside the DOM.
          return
        requestedWidth = if exact then containerWidth else @calc_stoppoint(tag, containerWidth)
        currentWidth = Util.getData(tag, 'width') or 0
        if requestedWidth > currentWidth
          # requested width is larger, fetch new image
          Util.setData(tag, 'width', requestedWidth)
        else
          # requested width is not larger - keep previous
          requestedWidth = currentWidth
        src = src.replace(/\bw_auto\b/g, 'w_' + requestedWidth)
        attrs.width = null
        if !options.responsive_preserve_height
          attrs.height = null
      # Update dpr according to the device's devicePixelRatio
      attrs.src = src.replace(/\bdpr_(1\.0|auto)\b/g, 'dpr_' + @device_pixel_ratio())
      Util.setAttributes(tag, attrs)
    this

  ###*
  * Provide a transformation object, initialized with own's options, for chaining purposes.
  * @function Cloudinary#transformation
  * @param {object} options
  * @return {Transformation}
  ###
  transformation: (options)->
    Transformation.new( @config()).fromOptions(options).setParent( this)

cloudinary.Cloudinary = Cloudinary

crc32 = (str) ->
# http://kevin.vanzonneveld.net
# +   original by: Webtoolkit.info (http://www.webtoolkit.info/)
# +   improved by: T0bsn
# +   improved by: http://stackoverflow.com/questions/2647935/javascript-crc32-function-and-php-crc32-not-matching
# -    depends on: utf8_encode
# *     example 1: crc32('Kevin van Zonneveld');
# *     returns 1: 1249991249
  str = utf8_encode str

  table = '00000000 77073096 EE0E612C 990951BA 076DC419 706AF48F E963A535 9E6495A3 0EDB8832 79DCB8A4 E0D5E91E 97D2D988 09B64C2B 7EB17CBD E7B82D07 90BF1D91 1DB71064 6AB020F2 F3B97148 84BE41DE 1ADAD47D 6DDDE4EB F4D4B551 83D385C7 136C9856 646BA8C0 FD62F97A 8A65C9EC 14015C4F 63066CD9 FA0F3D63 8D080DF5 3B6E20C8 4C69105E D56041E4 A2677172 3C03E4D1 4B04D447 D20D85FD A50AB56B 35B5A8FA 42B2986C DBBBC9D6 ACBCF940 32D86CE3 45DF5C75 DCD60DCF ABD13D59 26D930AC 51DE003A C8D75180 BFD06116 21B4F4B5 56B3C423 CFBA9599 B8BDA50F 2802B89E 5F058808 C60CD9B2 B10BE924 2F6F7C87 58684C11 C1611DAB B6662D3D 76DC4190 01DB7106 98D220BC EFD5102A 71B18589 06B6B51F 9FBFE4A5 E8B8D433 7807C9A2 0F00F934 9609A88E E10E9818 7F6A0DBB 086D3D2D 91646C97 E6635C01 6B6B51F4 1C6C6162 856530D8 F262004E 6C0695ED 1B01A57B 8208F4C1 F50FC457 65B0D9C6 12B7E950 8BBEB8EA FCB9887C 62DD1DDF 15DA2D49 8CD37CF3 FBD44C65 4DB26158 3AB551CE A3BC0074 D4BB30E2 4ADFA541 3DD895D7 A4D1C46D D3D6F4FB 4369E96A 346ED9FC AD678846 DA60B8D0 44042D73 33031DE5 AA0A4C5F DD0D7CC9 5005713C 270241AA BE0B1010 C90C2086 5768B525 206F85B3 B966D409 CE61E49F 5EDEF90E 29D9C998 B0D09822 C7D7A8B4 59B33D17 2EB40D81 B7BD5C3B C0BA6CAD EDB88320 9ABFB3B6 03B6E20C 74B1D29A EAD54739 9DD277AF 04DB2615 73DC1683 E3630B12 94643B84 0D6D6A3E 7A6A5AA8 E40ECF0B 9309FF9D 0A00AE27 7D079EB1 F00F9344 8708A3D2 1E01F268 6906C2FE F762575D 806567CB 196C3671 6E6B06E7 FED41B76 89D32BE0 10DA7A5A 67DD4ACC F9B9DF6F 8EBEEFF9 17B7BE43 60B08ED5 D6D6A3E8 A1D1937E 38D8C2C4 4FDFF252 D1BB67F1 A6BC5767 3FB506DD 48B2364B D80D2BDA AF0A1B4C 36034AF6 41047A60 DF60EFC3 A867DF55 316E8EEF 4669BE79 CB61B38C BC66831A 256FD2A0 5268E236 CC0C7795 BB0B4703 220216B9 5505262F C5BA3BBE B2BD0B28 2BB45A92 5CB36A04 C2D7FFA7 B5D0CF31 2CD99E8B 5BDEAE1D 9B64C2B0 EC63F226 756AA39C 026D930A 9C0906A9 EB0E363F 72076785 05005713 95BF4A82 E2B87A14 7BB12BAE 0CB61B38 92D28E9B E5D5BE0D 7CDCEFB7 0BDBDF21 86D3D2D4 F1D4E242 68DDB3F8 1FDA836E 81BE16CD F6B9265B 6FB077E1 18B74777 88085AE6 FF0F6A70 66063BCA 11010B5C 8F659EFF F862AE69 616BFFD3 166CCF45 A00AE278 D70DD2EE 4E048354 3903B3C2 A7672661 D06016F7 4969474D 3E6E77DB AED16A4A D9D65ADC 40DF0B66 37D83BF0 A9BCAE53 DEBB9EC5 47B2CF7F 30B5FFE9 BDBDF21C CABAC28A 53B39330 24B4A3A6 BAD03605 CDD70693 54DE5729 23D967BF B3667A2E C4614AB8 5D681B02 2A6F2B94 B40BBE37 C30C8EA1 5A05DF1B 2D02EF8D'
  crc = 0
  x = 0
  y = 0
  crc = crc ^ -1
  i = 0
  iTop = str.length
  while i < iTop
    y = (crc ^ str.charCodeAt(i)) & 0xFF
    x = '0x' + table.substr(y * 9, 8)
    crc = crc >>> 8 ^ x
    i++
  crc = crc ^ -1
  #convert to unsigned 32-bit int if needed
  if crc < 0
    crc += 4294967296
  crc

if typeof module != "undefined" && module.exports
  #On a server
  exports.crc32 = crc32
else
  #On a client
  window.crc32 = crc32

utf8_encode = (argString) ->
# http://kevin.vanzonneveld.net
# +   original by: Webtoolkit.info (http://www.webtoolkit.info/)
# +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
# +   improved by: sowberry
# +    tweaked by: Jack
# +   bugfixed by: Onno Marsman
# +   improved by: Yves Sucaet
# +   bugfixed by: Onno Marsman
# +   bugfixed by: Ulrich
# +   bugfixed by: Rafal Kukawski
# +   improved by: kirilloid
# *     example 1: utf8_encode('Kevin van Zonneveld');
# *     returns 1: 'Kevin van Zonneveld'
  if argString == null or typeof argString == 'undefined'
    return ''
  string = argString + ''
  # .replace(/\r\n/g, "\n").replace(/\r/g, "\n");
  utftext = ''
  start = undefined
  end = undefined
  stringl = 0
  start = end = 0
  stringl = string.length
  n = 0
  while n < stringl
    c1 = string.charCodeAt(n)
    enc = null
    if c1 < 128
      end++
    else if c1 > 127 and c1 < 2048
      enc = String.fromCharCode(c1 >> 6 | 192, c1 & 63 | 128)
    else
      enc = String.fromCharCode(c1 >> 12 | 224, c1 >> 6 & 63 | 128, c1 & 63 | 128)
    if enc != null
      if end > start
        utftext += string.slice(start, end)
      utftext += enc
      start = end = n + 1
    n++
  if end > start
    utftext += string.slice(start, stringl)
  utftext


if typeof module != "undefined" && module.exports
#On a server
  exports.utf8_encode = utf8_encode
else
#On a client
  window.utf8_encode = utf8_encode

###*
 * Cloudinary configuration class
###
class Configuration

  ###*
  * Defaults configuration.
  * @const {object} Configuration.DEFAULT_CONFIGURATION_PARAMS
  ###
  DEFAULT_CONFIGURATION_PARAMS ={
    secure: window?.location?.protocol == 'https:'
  }

  @CONFIG_PARAMS = [
    "api_key"
    "api_secret"
    "cdn_subdomain"
    "cloud_name"
    "cname"
    "private_cdn"
    "protocol"
    "resource_type"
    "responsive_width"
    "secure"
    "secure_cdn_subdomain"
    "secure_distribution"
    "shorten"
    "type"
    "url_suffix"
    "use_root_path"
    "version"
  ]
  ###*
   * Cloudinary configuration class
   * @constructor Configuration
   * @param {object} options - configuration parameters
  ###
  constructor: (options ={})->
    @configuration = Util.cloneDeep(options)
    Util.defaults( @configuration, DEFAULT_CONFIGURATION_PARAMS)

  ###*
   * Initialize the configuration.
   * The function first tries to retrieve the configuration form the environment and then from the document.
   * @function Configuration#init
   * @return {Configuration} returns this for chaining
   * @see fromDocument
   * @see fromEnvironment
  ###
  init: ()->
    @fromEnvironment()
    @fromDocument()
    @

  ###*
   * Set a new configuration item
   * @function Configuration#set
   * @param {String} name - the name of the item to set
   * @param {*} value - the value to be set
   * @return {Configuration}
   *
  ###
  set:(name, value)->
    @configuration[name] = value
    this

  ###*
   * Get the value of a configuration item
   * @function Configuration#get
   * @param {string} name - the name of the item to set
   * @return {*} the configuration item
  ###
  get: (name)->
    @configuration[name]

  merge: (config={})->
    Util.assign(@configuration, Util.cloneDeep(config))
    this

  ###*
   * Initialize Cloudinary from HTML meta tags.
   * @function Configuration#fromDocument
   * @return {Configuration}
   * @example <meta name="cloudinary_cloud_name" content="mycloud">
   *
  ###
  fromDocument: ->
    meta_elements = document?.querySelectorAll('meta[name^="cloudinary_"]');
    if meta_elements
      for el in meta_elements
        @configuration[el.getAttribute('name').replace('cloudinary_', '')] = el.getAttribute('content')
    this

  ###*
   * Initialize Cloudinary from the `CLOUDINARY_URL` environment variable.
   *
   * This function will only run under Node.js environment.
   * @function Configuration#fromEnvironment
   * @requires Node.js
  ###
  fromEnvironment: ->
    cloudinary_url = process?.env?.CLOUDINARY_URL
    if cloudinary_url?
      uri = require('url').parse(cloudinary_url, true)
      @configuration =
        cloud_name: uri.host,
        api_key: uri.auth and uri.auth.split(":")[0],
        api_secret: uri.auth and uri.auth.split(":")[1],
        private_cdn: uri.pathname?,
        secure_distribution: uri.pathname and uri.pathname.substring(1)
      if uri.query?
        for k, v of uri.query
          @configuration[k] = v
    this

  ###*
  * Create or modify the Cloudinary client configuration
  *
  * Warning: `config()` returns the actual internal configuration object. modifying it will change the configuration.
  *
  * This is a backward compatibility method. For new code, use get(), merge() etc.
  * @function Configuration#config
  * @param {hash|string|true} new_config
  * @param {string} new_value
  * @returns {*} configuration, or value
  *
  * @see {@link fromEnvironment} for initialization using environment variables
  * @see {@link fromDocument} for initialization using HTML meta tags
  ###
  config: (new_config, new_value) ->
    # REVIEW it would be more OO to return a copy of @configuration and not the internal object itself. It will mean that cloudinary.config().foo = "bar" will have no effect.
    switch
      when new_value != undefined
        @set(new_config, new_value)
        @configuration
      when Util.isString(new_config)
        @get(new_config)
      when Util.isPlainObject(new_config)
        @merge(new_config)
        @configuration
      else
        # Backward compatibility - return the internal object
        @configuration

  ###*
   * Returns a copy of the configuration parameters
   * @function Configuration#toOptions
   * @returns {Object} a key:value collection of the configuration parameters
  ###
  toOptions: ()->
    Util.cloneDeep(@configuration)

cloudinary.Configuration = Configuration

class Param
  ###*
   * Represents a single parameter
   * @class Param
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} short - The name of the serialized form of the parameter.
   *                         If a value is not provided, the parameter will not be serialized.
   * @param {function} [process=Util.identity ] - Manipulate origValue when value is called
   * @ignore
  ###
  constructor: (name, short, process = Util.identity)->
    ###*
     * The name of the parameter in snake_case
     * @member {string} Param#name
    ###
    @name = name
    ###*
     * The name of the serialized form of the parameter
     * @member {string} Param#short
    ###
    @short = short
    ###*
     * Manipulate origValue when value is called
     * @member {function} Param#process
    ###
    @process = process

  ###*
   * Set a (unprocessed) value for this parameter
   * @function Param#set
   * @param {*} origValue - the value of the parameter
   * @return {Param} self for chaining
  ###
  set: (@origValue)->
    this

  ###*
   * Generate the serialized form of the parameter
   * @function Param#serialize
   * @return {string} the serialized form of the parameter
  ###
  serialize: ->
    val = @value()
    valid = if Util.isArray(val) || Util.isPlainObject(val) || Util.isString(val)
        !Util.isEmpty(val)
      else
        val?
    if @short? && valid
      "#{@short}_#{val}"
    else
      ''

  ###*
   * Return the processed value of the parameter
   * @function Param#value
  ###
  value: ->
    @process(@origValue)

  @norm_color: (value) -> value?.replace(/^#/, 'rgb:')

  build_array: (arg = []) ->
    if Util.isArray(arg)
      arg
    else
      [arg]

class ArrayParam extends Param
  ###*
   * A parameter that represents an array
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} short - The name of the serialized form of the parameter
   *                         If a value is not provided, the parameter will not be serialized.
   * @param {string} [sep='.'] - The separator to use when joining the array elements together
   * @param {function} [process=Util.identity ] - Manipulate origValue when value is called
   * @class ArrayParam
   * @ignore
  ###
  constructor: (name, short, sep = '.', process) ->
    @sep = sep
    super(name, short, process)

  serialize: ->
    if @short?
      array = @value()
      if Util.isEmpty(array)
        ''
      else
        flat = for t in @value()
          if Util.isFunction( t.serialize)
            t.serialize() # Param or Transformation
          else
            t
        "#{@short}_#{flat.join(@sep)}"
    else
      ''

  set: (origValue)->
    if !origValue? || Util.isArray(origValue)
      super(origValue)
    else
      super([origValue])

class TransformationParam extends Param
  ###*
   * A parameter that represents a transformation
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} [short='t'] - The name of the serialized form of the parameter
   * @param {string} [sep='.'] - The separator to use when joining the array elements together
   * @param {function} [process=Util.identity ] - Manipulate origValue when value is called
   * @class TransformationParam
   * @ignore
  ###
  constructor: (name, short = "t", sep = '.', process) ->
    @sep = sep
    super(name, short, process)

  serialize: ->
    if Util.isEmpty(@value())
      null
    else if Util.allStrings(@value())
      "#{@short}_#{@value().join(@sep)}"
    else
      result = for t in @value() when t?
        if Util.isString( t)
          "#{@short}_#{t}"
        else if Util.isFunction( t.serialize)
          t.serialize()
        else if Util.isPlainObject(t)
          new Transformation(t).serialize()
      Util.compact(result)

  set: (@origValue)->
    if Util.isArray(@origValue)
      super(@origValue)
    else
      super([@origValue])

class RangeParam extends Param
  ###*
   * A parameter that represents a range
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} short - The name of the serialized form of the parameter
   *                         If a value is not provided, the parameter will not be serialized.
   * @param {string} [sep='.'] - The separator to use when joining the array elements together
   * @param {function} [process=norm_range_value ] - Manipulate origValue when value is called
   * @class RangeParam
   * @ignore
  ###
  constructor: (name, short, process = @norm_range_value)->
    super(name, short, process)

  @norm_range_value: (value) ->
    offset = String(value).match(new RegExp('^' + offset_any_pattern + '$'))
    if offset
      modifier = if offset[5]? then 'p' else ''
      value = (offset[1] or offset[4]) + modifier
    value

class RawParam extends Param
  constructor: (name, short, process = Util.identity)->
    super(name, short, process)
  serialize: ->
    @value()


###*
* Covert value to video codec string.
*
* If the parameter is an object,
* @param {(string|Object)} param - the video codec as either a String or a Hash
* @return {string} the video codec string in the format codec:profile:level
* @example
* vc_[ :profile : [level]]
* or
  { codec: 'h264', profile: 'basic', level: '3.1' }
* @ignore
###
process_video_params = (param) ->
  switch param.constructor
    when Object
      video = ""
      if 'codec' of param
        video = param['codec']
        if 'profile' of param
          video += ":" + param['profile']
          if 'level' of param
            video += ":" + param['level']
      video
    when String
      param
    else
      null



class TransformationBase
  lastArgCallback = (args)->
    callback = args?[args.length - 1]
    if(Util.isFunction(callback))
      callback
    else
      undefined

  ###*
   * The base class for transformations.
   * @class TransformationBase
  ###
  constructor: (options = {}) ->
    ###* @private ###
    chainedTo = undefined
    ###* @private ###
    trans = {}

    ###*
     * Return an options object that can be used to create an identical Transformation
     * @function Transformation#toOptions
     * @return {Object} a plain object representing this transformation
    ###
    @toOptions = ()->
      opt= {}
      for key, value of trans
        opt[key]= value.origValue
      for key, value of @otherOptions when value != undefined
        opt[key]= value
      opt

    ###*
     * Set a parent for this object for chaining purposes.
     *
     * @function Transformation#setParent
     * @private
     * @param {Object} object - the parent to be assigned to
     * @returns {Transformation} - returns this instance for chaining purposes.
    ###
    @setParent = (object)->
      chainedTo = object
      @fromOptions( object.toOptions?())
      this

    ###*
     * Returns the parent of this object in the chain
     * @function Transformation#getParent
     * @private
     * @return {Object} the parent of this object if any
    ###
    @getParent = ()->
      chainedTo

    #
    # Helper methods to create parameter methods
    # These methods are defined here because they access `trans` which is
    # a private member of `TransformationBase`
    #

    ###* @private ###
    @param = (value, name, abbr, defaultValue, process) ->
      unless process?
        if Util.isFunction(defaultValue)
          process = defaultValue
        else
          process = Util.identity
      trans[name] = new Param(name, abbr, process).set(value)
      @

    ###* @private ###
    @rawParam = (value, name, abbr, defaultValue, process = Util.identity) ->
      process = lastArgCallback(arguments)
      trans[name] = new RawParam(name, abbr, process).set(value)
      @

    ###* @private ###
    @rangeParam = (value, name, abbr, defaultValue, process = Util.identity) ->
      process = lastArgCallback(arguments)
      trans[name] = new RangeParam(name, abbr, process).set(value)
      @

    ###* @private ###
    @arrayParam = (value, name, abbr, sep = ":", defaultValue = [], process = Util.identity) ->
      process = lastArgCallback(arguments)
      trans[name] = new ArrayParam(name, abbr, sep, process).set(value)
      @

    ###* @private ###
    @transformationParam = (value, name, abbr, sep = ".", defaultValue, process = Util.identity) ->
      process = lastArgCallback(arguments)
      trans[name] = new TransformationParam(name, abbr, sep, process).set(value)
      @

    #
    # End Helper methods
    #

    ###*
     * Get the value associated with the given name.
     * @function Transformation#getValue
     * @param {string} name - the name of the parameter
     * @return {*} the processed value associated with the given name
     * @description Use {@link get}.origValue for the value originally provided for the parameter
    ###
    @getValue = (name)->
      trans[name]?.value() ? @otherOptions[name]

    ###*
     * Get the parameter object for the given parameter name
     * @function Transformation#get
     * @param {String} name the name of the transformation parameter
     * @returns {Param} the param object for the given name, or undefined
    ###
    @get = (name)->
      trans[name]

    ###*
     * Remove a transformation option from the transformation.
     * @function Transformation#remove
     * @param {string} name - the name of the option to remove
     * @return {*} the option that was removed or null if no option by that name was found
    ###
    @remove = (name)->
      switch
        when trans[name]?
          temp = trans[name]
          delete trans[name]
          temp.origValue
        when @otherOptions[name]?
          temp = @otherOptions[name]
          delete @otherOptions[name]
          temp
        else
          null

    ###*
     * Return an array of all the keys (option names) in the transformation.
     * @return {Array<string>} the keys in snakeCase format
    ###
    @keys = ()->
      (Util.snakeCase(key) for key of trans).sort()

    ###*
     * Returns a plain object representation of the transformation. Values are processed.
     * @function Transformation#toPlainObject
     * @return {object} the transformation options as plain object
    ###
    @toPlainObject = ()->
      hash = {}
      for key of trans
        hash[key] = trans[key].value()
        hash[key] = Util.cloneDeep(hash[key]) if Util.isPlainObject(hash[key])
      hash

    ###*
     * Complete the current transformation and chain to a new one.
     * In the URL, transformations are chained together by slashes.
     * @function Transformation#chain
     * @return {TransformationBase} this transformation for chaining
     * @example
     * var tr = cloudinary.Transformation.new();
     * tr.width(10).crop('fit').chain().angle(15).serialize()
     * // produces "c_fit,w_10/a_15"
    ###
    @chain = ()->
      tr = new @constructor( @toOptions())
      trans = []
      @set("transformation", tr)

    @otherOptions = {}

    ###*
     * Transformation Class methods.
     * This is a list of the parameters defined in Transformation.
     * Values are camelCased.
     * @private
     * @ignore
     * @type {Array<String>}
    ###
    @methods = Util.difference(
      Util.functions(Transformation.prototype),
      Util.functions(TransformationBase.prototype)
    )

    ###*
     * Parameters that are filtered out before passing the options to an HTML tag.
     * The list of parameters is `Transformation::methods` and `Configuration::CONFIG_PARAMS`
     * @const {Array<string>} TransformationBase.PARAM_NAMES
     * @private
     * @see toHtmlAttributes
    ###
    @PARAM_NAMES = (Util.snakeCase(m) for m in @methods).concat( cloudinary.Configuration.CONFIG_PARAMS)


    # Finished constructing the instance, now process the options

    @fromOptions(options) unless Util.isEmpty(options)

  ###*
   * Merge the provided options with own's options
   * @param {Object} [options={}] key-value list of options
   * @returns {Transformation} this instance for chaining
  ###
  fromOptions: (options) ->
    options or= {}
    options = {transformation: options } if Util.isString(options) || Util.isArray(options) || options instanceof Transformation
    options = Util.cloneDeep(options, (value) ->
      if value instanceof Transformation
        new value.constructor( value.toOptions())
    )
    for key, opt of options
      @set key, opt
    this

  ###*
   * Set a parameter.
   * The parameter name `key` is converted to
   * @param {String} key - the name of the parameter
   * @param {*} value - the value of the parameter
   * @returns {Transformation} this instance for chaining
  ###
  set: (key, value)->
    camelKey = Util.camelCase( key)
    if Util.contains( @methods, camelKey)
      this[camelKey](value)
    else
      @otherOptions[key] = value
    this

  hasLayer: ()->
    @getValue("overlay") || @getValue("underlay")

  ###*
   * Generate a string reprensetation of the transformation.
   * @function Transformation#serialize
   * @return {string} the transformation as a string
  ###
  serialize: ->
    resultArray = []
    paramList = @keys()
    transformations = @get("transformation")?.serialize()
    paramList = Util.without(paramList, "transformation")
    transformationList = (@get(t)?.serialize() for t in paramList )
    switch
      when Util.isString(transformations)
        transformationList.push( transformations)
      when Util.isArray( transformations)
        resultArray = (transformations)
    transformationString = (
      for value in transformationList when Util.isArray(value) &&!Util.isEmpty(value) || !Util.isArray(value) && value
        value
    ).sort().join(',')
    resultArray.push(transformationString) unless Util.isEmpty(transformationString)
    Util.compact(resultArray).join('/')

  ###*
   * Provide a list of all the valid transformation option names
   * @function Transformation#listNames
   * @private
   * @return {Array<string>} a array of all the valid option names
  ###
  listNames: ->
    @methods


  ###*
   * Returns attributes for an HTML tag.
   * @function Cloudinary.toHtmlAttributes
   * @return PlainObject
  ###
  toHtmlAttributes: ()->
    options = {}
    options[key] = value for key, value of @otherOptions when  !Util.contains(@PARAM_NAMES, key)
    options[key] = @get(key).value for key in Util.difference(@keys(), @PARAM_NAMES)
    # convert all "html_key" to "key" with the same value
    for k in @keys() when /^html_/.exec(k)
      options[k.substr(5)] = @getValue(k)

    unless @hasLayer()|| @getValue("angle") || Util.contains( ["fit", "limit", "lfill"],@getValue("crop"))
      width = @get("width")?.origValue
      height = @get("height")?.origValue
      if parseFloat(width) >= 1.0
        options['width'] ?= width
      if parseFloat(height) >= 1.0
        options['height'] ?= height
    options

  isValidParamName: (name) ->
    @methods.indexOf(Util.camelCase(name)) >= 0

  ###*
   * Delegate to the parent (up the call chain) to produce HTML
   * @function Transformation#toHtml
   * @return {string} HTML representation of the parent if possible.
   * @example
   * tag = cloudinary.ImageTag.new("sample", {cloud_name: "demo"})
   * // ImageTag {name: "img", publicId: "sample"}
   * tag.toHtml()
   * // <img src="http://res.cloudinary.com/demo/image/upload/sample">
   * tag.transformation().crop("fit").width(300).toHtml()
   * // <img src="http://res.cloudinary.com/demo/image/upload/c_fit,w_300/sample">
  ###

  toHtml: ()->
    @getParent()?.toHtml?()

  toString: ()->
    @serialize()

class Transformation  extends TransformationBase

  @new = (args)-> new Transformation(args)

  ###*
   *  Represents a single transformation.
   *  @class Transformation
   *  @example
   *  t = new cloudinary.Transformation();
   *  t.angle(20).crop("scale").width("auto");
   *
   *  // or
   *
   *  t = new cloudinary.Transformation( {angle: 20, crop: "scale", width: "auto"});
  ###
  constructor: (options = {})->
    super(options)

  ###
    Transformation Parameters
  ###

  angle: (value)->                @arrayParam value, "angle", "a", "."
  audioCodec: (value)->           @param value, "audio_codec", "ac"
  audioFrequency: (value)->       @param value, "audio_frequency", "af"
  aspectRatio: (value)->          @param value, "aspect_ratio", "ar"
  background: (value)->           @param value, "background", "b", Param.norm_color
  bitRate: (value)->              @param value, "bit_rate", "br"
  border: (value)->               @param value, "border", "bo", (border) ->
    if (Util.isPlainObject(border))
      border = Util.assign({}, {color: "black", width: 2}, border)
      "#{border.width}px_solid_#{Param.norm_color(border.color)}"
    else
      border
  color: (value)->                @param value, "color", "co", Param.norm_color
  colorSpace: (value)->           @param value, "color_space", "cs"
  crop: (value)->                 @param value, "crop", "c"
  defaultImage: (value)->         @param value, "default_image", "d"
  delay: (value)->                @param value, "delay", "l"
  density: (value)->              @param value, "density", "dn"
  duration: (value)->             @rangeParam value, "duration", "du"
  dpr: (value)->                  @param value, "dpr", "dpr", (dpr) ->
    dpr = dpr.toString()
    if (dpr == "auto")
      "1.0"
    else if (dpr?.match(/^\d+$/))
      dpr + ".0"
    else
      dpr
  effect: (value)->               @arrayParam value,  "effect", "e", ":"
  endOffset: (value)->            @rangeParam value,  "end_offset", "eo"
  fallbackContent: (value)->      @param value,   "fallback_content"
  fetchFormat: (value)->          @param value,       "fetch_format", "f"
  format: (value)->               @param value,       "format"
  flags: (value)->                @arrayParam value,  "flags", "fl", "."
  gravity: (value)->              @param value,       "gravity", "g"
  height: (value)->               @param value,       "height", "h", =>
    if ( @getValue("crop") || @getValue("overlay") || @getValue("underlay"))
      value
    else
      null
  htmlHeight: (value)->           @param value, "html_height"
  htmlWidth:(value)->             @param value, "html_width"
  offset: (value)->
    [start_o, end_o] = if( Util.isFunction(value?.split))
      value.split('..')
    else if Util.isArray(value)
      value
    else
      [null,null]
    @startOffset(start_o) if start_o?
    @endOffset(end_o) if end_o?
  opacity: (value)->              @param value, "opacity",  "o"
  overlay: (value)->              @param value, "overlay",  "l"
  page: (value)->                 @param value, "page",     "pg"
  poster: (value)->               @param value, "poster"
  prefix: (value)->               @param value, "prefix",   "p"
  quality: (value)->              @param value, "quality",  "q"
  radius: (value)->               @param value, "radius",   "r"
  rawTransformation: (value)->    @rawParam value, "raw_transformation"
  size: (value)->
    if( Util.isFunction(value?.split))
      [width, height] = value.split('x')
      @width(width)
      @height(height)
  sourceTypes: (value)->          @param value, "source_types"
  sourceTransformation: (value)-> @param value, "source_transformation"
  startOffset: (value)->          @rangeParam value, "start_offset", "so"
  transformation: (value)->       @transformationParam value, "transformation", "t"
  underlay: (value)->             @param value, "underlay", "u"
  videoCodec: (value)->           @param value, "video_codec", "vc", process_video_params
  videoSampling: (value)->        @param value, "video_sampling", "vs"
  width: (value)->                @param value, "width", "w", =>
    if ( @getValue("crop") || @getValue("overlay") || @getValue("underlay"))
      value
    else
      null
  x: (value)->                    @param value, "x", "x"
  y: (value)->                    @param value, "y", "y"
  zoom: (value)->                 @param value, "zoom", "z"


cloudinary.Transformation = Transformation
cloudinary.TransformationBase = TransformationBase


###*
  * Represents an HTML (DOM) tag
###
class HtmlTag
  ###*
   * Represents an HTML (DOM) tag
   * @constructor HtmlTag
   * @example tag = new HtmlTag( 'div', { 'width': 10})
   * @param {String} name - the name of the tag
   * @param {String} [publicId]
   * @param {Object} options
  ###
  constructor: (name, publicId, options)->
    @name = name
    @publicId = publicId
    if !options?
      if Util.isPlainObject(publicId)
        options = publicId
        @publicId = undefined
      else
        options = {}
    transformation = new Transformation(options)
    transformation.setParent(this)
    @transformation = ()->
      transformation

  ###*
   * Convenience constructor
   * Creates a new instance of an HTML (DOM) tag
   * @function HtmlTag.new
   * @example tag = HtmlTag.new( 'div', { 'width': 10})
   * @param {String} name - the name of the tag
   * @param {String} [publicId]
   * @param {Object} options
   * @return {HtmlTag}
  ###
  @new = (name, publicId, options)->
    new @(name, publicId, options)


  ###*
   * Represent the given key and value as an HTML attribute.
   * @function HtmlTag#toAttribute
   * @param {String} key - attribute name
   * @param {*|boolean} value - the value of the attribute. If the value is boolean `true`, return the key only.
   * @returns {String} the attribute
   *
  ###
  toAttribute = (key, value) ->
    if !value
      undefined
    else if value == true
      key
    else
      "#{key}=\"#{value}\""

  ###*
   * combine key and value from the `attr` to generate an HTML tag attributes string.
   * `Transformation::toHtmlTagOptions` is used to filter out transformation and configuration keys.
   * @param {Object} attr
   * @return {String} the attributes in the format `'key1="value1" key2="value2"'`
  ###
  htmlAttrs: (attrs) ->
    pairs = (toAttribute( key, value) for key, value of attrs when value).sort().join(' ')

  ###*
   * Get all options related to this tag.
   * @returns {Object} the options
   *
  ###
  getOptions: ()-> @transformation().toOptions()

  ###*
   * Get the value of option `name`
   * @param {String} name - the name of the option
   * @returns the value of the option
   *
  ###
  getOption: (name)-> @transformation().getValue(name)

  ###*
   * Get the attributes of the tag.
   * The attributes are be computed from the options every time this method is invoked.
   * @returns {Object} attributes
  ###
  attributes: ()->
    @transformation().toHtmlAttributes()

  setAttr: ( name, value)->
    @transformation().set( name, value)
    this

  getAttr: (name)->
    @attributes()[name]

  removeAttr: (name)->
    @transformation().remove(name)

  content: ()->
    ""

  openTag: ()->
    "<#{@name} #{@htmlAttrs(@attributes())}>"

  closeTag:()->
    "</#{@name}>"

  content: ()->
    ""

  toHtml: ()->
    @openTag() + @content()+ @closeTag()

  toDOM: ()->
    throw "Can't create DOM if document is not present!" unless Util.isFunction( document?.createElement)
    element = document.createElement(@name)
    element[name] = value for name, value of @attributes()
    element



cloudinary.HtmlTag = HtmlTag


###*
* Creates an HTML (DOM) Image tag using Cloudinary as the source.
###
class ImageTag extends HtmlTag

  ###*
   * Creates an HTML (DOM) Image tag using Cloudinary as the source.
   * @param {String} [publicId]
   * @param {Object} [options]
  ###
  constructor: (publicId, options={})->
    super("img", publicId, options)

  closeTag: ()->
    ""

  attributes: ()->
    attr = super() || []
    attr['src'] ?= new Cloudinary(@getOptions()).url( @publicId)
    attr

cloudinary.ImageTag = ImageTag


###*
* Creates an HTML (DOM) Video tag using Cloudinary as the source.
###
class VideoTag extends HtmlTag

  VIDEO_TAG_PARAMS = ['source_types','source_transformation','fallback_content', 'poster']
  DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv']
  DEFAULT_POSTER_OPTIONS = { format: 'jpg', resource_type: 'video' }


  ###*
   * Creates an HTML (DOM) Video tag using Cloudinary as the source.
   * @constructor VideoTag
   * @param {String} [publicId]
   * @param {Object} [options]
  ###
  constructor: (publicId, options={})->
    options = Util.defaults({}, options, Cloudinary.DEFAULT_VIDEO_PARAMS)
    super("video", publicId.replace(/\.(mp4|ogv|webm)$/, ''), options)

  setSourceTransformation: (value)->
    @transformation().sourceTransformation(value)
    this

  setSourceTypes: (value)->
    @transformation().sourceTypes(value)
    this

  setPoster: (value)->
    @transformation().poster(value)
    this

  setFallbackContent: (value)->
    @transformation().fallbackContent(value)
    this

  content: ()->
    sourceTypes = @transformation().getValue('source_types')
    sourceTransformation = @transformation().getValue('source_transformation')
    fallback = @transformation().getValue('fallback_content')

    if Util.isArray(sourceTypes)
      cld = new Cloudinary(@getOptions())
      innerTags = for srcType in sourceTypes
        transformation = sourceTransformation[srcType] or {}
        src = cld.url( "#{@publicId }", Util.defaults({}, transformation, { resource_type: 'video', format: srcType}))
        videoType = if srcType == 'ogv' then 'ogg' else srcType
        mimeType = 'video/' + videoType
        "<source #{@htmlAttrs(src: src, type: mimeType)}>"
    else
      innerTags = []
    innerTags.join('') + fallback

  attributes: ()->
    sourceTypes = @getOption('source_types')
    poster = @getOption('poster') ? {}

    if Util.isPlainObject(poster)
      defaults = if poster.public_id? then Cloudinary.DEFAULT_IMAGE_PARAMS else DEFAULT_POSTER_OPTIONS
      poster = new Cloudinary(@getOptions()).url(
        poster.public_id ? @publicId,
        Util.defaults({}, poster, defaults))

    attr = super() || []
    attr = a for a in attr when !Util.contains(VIDEO_TAG_PARAMS)
    unless  Util.isArray(sourceTypes)
      attr["src"] = new Cloudinary(@getOptions())
        .url(@publicId, {resource_type: 'video', format: sourceTypes})
    if poster?
      attr["poster"] = poster
    attr

cloudinary.VideoTag = VideoTag

class CloudinaryJQuery extends Cloudinary
  ###*
   * Cloudinary class with jQuery support
   * @constructor CloudinaryJQuery
  ###
  constructor: (options)->
    super(options)


  image: (publicId, options={})->
    # generate a tag without the image src
    tag_options = Util.merge( {src: ''}, options)
    img = @imageTag(publicId, tag_options).toHtml()
    # cache the image src
    url = @url(publicId, options)
    # set image src taking responsiveness in account
    jQuery(img).data('src-cache', url).cloudinary_update(options);

  responsive: (options) ->
    responsiveConfig = jQuery.extend(responsiveConfig or {}, options)
    jQuery('img.cld-responsive, img.cld-hidpi').cloudinary_update responsiveConfig
    responsive_resize = responsiveConfig['responsive_resize'] ? @config('responsive_resize') ? true
    if responsive_resize and !responsiveResizeInitialized
      responsiveConfig.resizing = responsiveResizeInitialized  = true
      timeout = null
      jQuery(window).on 'resize', =>
        debounce = responsiveConfig['responsive_debounce'] ? @config('responsive_debounce') ? 100

        reset = ->
          if timeout
            clearTimeout timeout
            timeout = null

        run = ->
          jQuery('img.cld-responsive').cloudinary_update responsiveConfig

        wait = ->
          reset()
          setTimeout (->
            reset()
            run()
          ), debounce

        if debounce
          wait()
        else
          run()


jQuery.fn.cloudinary = (options) ->
  @filter('img').each(->
    img_options = jQuery.extend({
      width: jQuery(this).attr('width')
      height: jQuery(this).attr('height')
      src: jQuery(this).attr('src')
    }, jQuery(this).data(), options)
    public_id = img_options.source || img_options.src
    delete img_options.source
    delete img_options.src
    url = jQuery.cloudinary.url(public_id, img_options)
    img_options = new Transformation(img_options).toHtmlAttributes()
    jQuery(this).data('src-cache', url).attr
      width: img_options.width
      height: img_options.height
    ).cloudinary_update options
  this



###*
* Update hidpi (dpr_auto) and responsive (w_auto) fields according to the current container size and the device pixel ratio.
* Only images marked with the cld-responsive class have w_auto updated.
* options:
* - responsive_use_stoppoints:
*   - true - always use stoppoints for width
*   - "resize" - use exact width on first render and stoppoints on resize (default)
*   - false - always use exact width
* - responsive:
*   - true - enable responsive on this element. Can be done by adding cld-responsive.
*            Note that jQuery.cloudinary.responsive() should be called once on the page.
* - responsive_preserve_height: if set to true, original css height is perserved. Should only be used if the transformation supports different aspect ratios.
###

jQuery.fn.cloudinary_update = (options = {}) ->
  responsive_use_stoppoints = options['responsive_use_stoppoints'] ? jQuery.cloudinary.config('responsive_use_stoppoints') ? 'resize'
  exact = !responsive_use_stoppoints || responsive_use_stoppoints == 'resize' and !options.resizing
  @filter('img').each ->
    if options.responsive
        jQuery(this).addClass 'cld-responsive'
    attrs = {}
    src = getData(this, 'src-cache') or getData(this, 'src')
    if !src
      return
    responsive = hasClass(this, 'cld-responsive') and src.match(/\bw_auto\b/)
    if responsive
      container = this.parentNode
      containerWidth = 0
      while container and containerWidth == 0
        containerWidth = container.clientWidth || 0
        container = container.parentNode
      if containerWidth == 0
        # container doesn't know the size yet. Usually because the image is hidden or outside the DOM.
        return
      requestedWidth = if exact then containerWidth else jQuery.cloudinary.calc_stoppoint(this, containerWidth)
      currentWidth = getData(this, 'width') or 0
      if requestedWidth > currentWidth
        # requested width is larger, fetch new image
        setData(this, 'width', requestedWidth)
      else
        # requested width is not larger - keep previous
        requestedWidth = currentWidth
      src = src.replace(/\bw_auto\b/g, 'w_' + requestedWidth)
      attrs.width = null
      if !options.responsive_preserve_height
        attrs.height = null
    # Update dpr according to the device's devicePixelRatio
    attrs.src = src.replace(/\bdpr_(1\.0|auto)\b/g, 'dpr_' + jQuery.cloudinary.device_pixel_ratio())
    jQuery(this).attr attrs
  this

webp = null

jQuery.fn.webpify = (options = {}, webp_options) ->
  that = this
  webp_options = webp_options ? options
  if !webp
    webp = jQuery.Deferred()
    webp_canary = new Image
    webp_canary.onerror = webp.reject
    webp_canary.onload = webp.resolve
    webp_canary.src = 'data:image/webp;base64,UklGRi4AAABXRUJQVlA4TCEAAAAvAUAAEB8wAiMwAgSSNtse/cXjxyCCmrYNWPwmHRH9jwMA'
  jQuery ->
    webp.done(->
      jQuery(that).cloudinary jQuery.extend({}, webp_options, format: 'webp')
    ).fail ->
      jQuery(that).cloudinary options
  this

jQuery.fn.fetchify = (options) ->
  @cloudinary jQuery.extend(options, 'type': 'fetch')

cloudinary.CloudinaryJQuery = CloudinaryJQuery


jQuery.cloudinary = new CloudinaryJQuery()
jQuery.cloudinary.fromDocument()


# Extend CloudinaryJQuery

CloudinaryJQuery::delete_by_token = (delete_token, options) ->
  options = options or {}
  url = options.url
  if !url
    cloud_name = options.cloud_name or jQuery.cloudinary.config().cloud_name
    url = 'https://api.cloudinary.com/v1_1/' + cloud_name + '/delete_by_token'
  dataType = if jQuery.support.xhrFileUpload then 'json' else 'iframe json'
  jQuery.ajax
    url: url
    method: 'POST'
    data: token: delete_token
    headers: 'X-Requested-With': 'XMLHttpRequest'
    dataType: dataType

CloudinaryJQuery::unsigned_upload_tag = (upload_preset, upload_params, options) ->
  jQuery('<input/>').attr(
    type: 'file'
    name: 'file').unsigned_cloudinary_upload upload_preset, upload_params, options

jQuery.fn.cloudinary_fileupload = (options) ->
  initializing = !@data('blueimpFileupload')
  if initializing
    options = jQuery.extend({
      maxFileSize: 20000000
      dataType: 'json'
      headers: 'X-Requested-With': 'XMLHttpRequest'
    }, options)
  @fileupload options
  if initializing
    @bind 'fileuploaddone', (e, data) ->
      if data.result.error
        return
      data.result.path = [
        'v'
        data.result.version
        '/'
        data.result.public_id
        if data.result.format then '.' + data.result.format else ''
      ].join('')
      if data.cloudinaryField and data.form.length > 0
        upload_info = [
          data.result.resource_type
          data.result.type
          data.result.path
        ].join('/') + '#' + data.result.signature
        multiple = jQuery(e.target).prop('multiple')

        add_field = ->
          jQuery('<input/>').attr(
            type: 'hidden'
            name: data.cloudinaryField).val(upload_info).appendTo data.form


        if multiple
          add_field()
        else
          field = jQuery(data.form).find('input[name="' + data.cloudinaryField + '"]')
          if field.length > 0
            field.val upload_info
          else
            add_field()
      jQuery(e.target).trigger 'cloudinarydone', data

    @bind 'fileuploadsend', (e, data) ->
      # add a common unique ID to all chunks of the same uploaded file
      data.headers['X-Unique-Upload-Id'] = (Math.random() * 10000000000).toString(16)

    @bind 'fileuploadstart', (e) ->
      jQuery(e.target).trigger 'cloudinarystart'

    @bind 'fileuploadstop', (e) ->
      jQuery(e.target).trigger 'cloudinarystop'

    @bind 'fileuploadprogress', (e, data) ->
      jQuery(e.target).trigger 'cloudinaryprogress', data

    @bind 'fileuploadprogressall', (e, data) ->
      jQuery(e.target).trigger 'cloudinaryprogressall', data

    @bind 'fileuploadfail', (e, data) ->
      jQuery(e.target).trigger 'cloudinaryfail', data

    @bind 'fileuploadalways', (e, data) ->
      jQuery(e.target).trigger 'cloudinaryalways', data

    if !@fileupload('option').url
      cloud_name = options.cloud_name or jQuery.cloudinary.config().cloud_name
      resource_type = options.resource_type or 'auto'
      type = options.type or 'upload'
      upload_url = 'https://api.cloudinary.com/v1_1/' + cloud_name + '/' + resource_type + '/' + type
      @fileupload 'option', 'url', upload_url
  this

jQuery.fn.cloudinary_upload_url = (remote_url) ->
  @fileupload('option', 'formData').file = remote_url
  @fileupload 'add', files: [ remote_url ]
  delete @fileupload('option', 'formData').file
  this

jQuery.fn.unsigned_cloudinary_upload = (upload_preset, upload_params = {}, options = {}) ->
  upload_params = Util.cloneDeep(upload_params)
  options = Util.cloneDeep(options)
  attrs_to_move = [
    'cloud_name'
    'resource_type'
    'type'
  ]
  i = 0
  while i < attrs_to_move.length
    attr = attrs_to_move[i]
    if upload_params[attr]
      options[attr] = upload_params[attr]
      delete upload_params[attr]
    i++
  # Serialize upload_params
  for key of upload_params
    value = upload_params[key]
    if Util.isPlainObject(value)
      upload_params[key] = jQuery.map(value, (v, k) ->
        k + '=' + v
      ).join('|')
    else if Util.isArray(value)
      if value.length > 0 and jQuery.isArray(value[0])
        upload_params[key] = jQuery.map(value, (array_value) ->
          array_value.join ','
        ).join('|')
      else
        upload_params[key] = value.join(',')
  if !upload_params.callback
    upload_params.callback = '/cloudinary_cors.html'
  upload_params.upload_preset = upload_preset
  options.formData = upload_params
  if options.cloudinary_field
    options.cloudinaryField = options.cloudinary_field
    delete options.cloudinary_field
  html_options = options.html or {}
  html_options.class = Util.trim("cloudinary_fileupload #{html_options.class || ''}")
  if options.multiple
    html_options.multiple = true
  @attr(html_options).cloudinary_fileupload options
  this

jQuery.cloudinary = new CloudinaryJQuery()


# Footer for the cloudinary.coffee file

`
return cloudinary;
}));
`