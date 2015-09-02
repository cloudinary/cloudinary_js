

###*
  Main Cloudinary class

  Backward compatibility:
  Must provide public keys
   * CF_SHARED_CDN
   * OLD_AKAMAI_SHARED_CDN
   * AKAMAI_SHARED_CDN
   * SHARED_CDN
   * config
   * url
   * video_url
   * video_thumbnail_url
   * transformation_string
   * image
   * video_thumbnail
   * facebook_profile_image
   * twitter_profile_image
   * twitter_name_profile_image
   * gravatar_image
   * fetch_image
   * video
   * sprite_css
   * responsive
   * calc_stoppoint
   * device_pixel_ratio
   * supported_dpr_values

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
  *
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

  constructor: (options)->
    configuration = new Cloudinary.Configuration(options)

    # Provided for backward compatibility
    @config= (newConfig, newValue) ->
      configuration.config(newConfig, newValue)

  @new = (options)-> new @(options)

  ###*
   * Return the resource type and action type based on the given configuration
   * @param resource_type
   * @param type
   * @param url_suffix
   * @param use_root_path
   * @param shorten
   * @returns {string} resource_type/type
   *
  ###
  finalizeResourceType = (resourceType,type,urlSuffix,useRootPath,shorten) ->
    if _.isPlainObject(resourceType)
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

  url: (publicId, options = {}) ->
    options = _.defaults({}, options, @config(), Cloudinary.DEFAULT_IMAGE_PARAMS)
    if options.type == 'fetch'
      options.fetch_format = options.fetch_format or options.format
      publicId = absolutize(publicId)

    transformation = new Transformation(options)
    transformationString = transformation.flatten()

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

    url ||  _.filter([
      prefix
      resourceTypeAndType
      transformationString
      version
      publicId
    ], null).join('/').replace(/([^:])\/+/g, '$1/')



  video_url: (publicId, options) ->
    options = _.merge({ resource_type: 'video' }, options)
    @url(publicId, options)

  video_thumbnail_url: (publicId, options) ->
    options = _.merge({}, DEFAULT_POSTER_OPTIONS, options)
    @url(publicId, options)

  transformation_string: (options) ->
    new Transformation( options).flatten()

  image: (publicId, options={}) ->
    @imageTag(publicId, options).toHtml() # TODO need to call cloudinary_update

  video_thumbnail: (publicId, options) ->
    @image publicId, _.extend( {}, DEFAULT_POSTER_OPTIONS, options)

  facebook_profile_image: (publicId, options) ->
    @image publicId, _.merge({type: 'facebook'}, options)

  twitter_profile_image: (publicId, options) ->
    @image publicId, _.merge({type: 'twitter'}, options)

  twitter_name_profile_image: (publicId, options) ->
    @image publicId, _.merge({type: 'twitter_name'}, options)

  gravatar_image: (publicId, options) ->
    @image publicId, _.merge({type: 'gravatar'}, options)

  fetch_image: (publicId, options) ->
    @image publicId, _.merge({type: 'fetch'}, options)

  video: (publicId, options = {}) ->
    @videoTag(publicId, options).toHtml()

  sprite_css: (publicId, options) ->
    options = _.merge({ type: 'sprite' }, options)
    if !publicId.match(/.css$/)
      options.format = 'css'
    @url publicId, options

  responsive: (options) ->
    responsiveConfig = _.merge(responsiveConfig or {}, options)
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

        run = ->
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
    stoppoints = getData(element,'stoppoints') or @config('stoppoints') or defaultStoppoints
    if _.isFunction stoppoints
      stoppoints(width)
    else
      if _.isString stoppoints
        stoppoints = _.map(stoppoints.split(','), _.parseInt).sort( (a,b) -> a - b )
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
  * similar to `$.fn.cloudinary`
  * Finds all `img` tags under each node and sets it up to provide the image through Cloudinary
  ###
  processImageTags: (nodes, options = {}) ->
    options = _.defaults({}, options, @config())
    images = _(nodes)
      .filter( 'tagName': 'IMG')
      .forEach( (i) ->
        imgOptions = _.extend({
          width: i.getAttribute('width')
          height: i.getAttribute('height')
          src: i.getAttribute('src')
        }, options)
        publicId = imgOptions['source'] || imgOptions['src']
        delete imgOptions['source']
        delete imgOptions['src']
        url = @url(publicId, imgOptions)
        imgOptions = new Transformation(imgOptions).toHtmlAttributes()
        setData(i, 'src-cache', url)
        i.setAttribute('width', imgOptions.width)
        i.setAttribute('height', imgOptions.height)
      ).value()
    @cloudinary_update( images, options)
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
  *            Note that $.cloudinary.responsive() should be called once on the page.
  * - responsive_preserve_height: if set to true, original css height is perserved. Should only be used if the transformation supports different aspect ratios.
  ###

  cloudinary_update: (elements, options = {}) ->
    elements = switch elements
      when _.isArray(elements)
        elements
      when elements.constructor.name == "NodeList"
        elements
      when _.isString(elements)
        document.querySelectorAll(elements)
      when _.isElement(elements)
        [elements]

    responsive_use_stoppoints = options['responsive_use_stoppoints'] ? @config('responsive_use_stoppoints') ? 'resize'
    exact = !responsive_use_stoppoints || responsive_use_stoppoints == 'resize' and !options.resizing
    for tag in elements when tag.tagName.match(/img/i)
      if options.responsive
        tag.className = _.trim( "#{tag.className} cld-responsive") unless tag.className.match( /\bcld-responsive\b/)
      attrs = {}
      src = getData(tag, 'src-cache') or getData(tag, 'src')
      if !src
        return
      responsive = hasClass(tag, 'cld-responsive') and src.match(/\bw_auto\b/)
      if responsive
        container = tag.parentNode
        containerWidth = 0
        while container and containerWidth == 0
          containerWidth = container.clientWidth || 0
          container = container.parentNode
        if containerWidth == 0
          # container doesn't know the size yet. Usually because the image is hidden or outside the DOM.
          return
        requestedWidth = if exact then containerWidth else @calc_stoppoint(tag, containerWidth)
        currentWidth = getData(tag, 'width') or 0
        if requestedWidth > currentWidth
          # requested width is larger, fetch new image
          setData(tag, 'width', requestedWidth)
        else
          # requested width is not larger - keep previous
          requestedWidth = currentWidth
        src = src.replace(/\bw_auto\b/g, 'w_' + requestedWidth)
        attrs.width = null
        if !options.responsive_preserve_height
          attrs.height = null
      # Update dpr according to the device's devicePixelRatio
      attrs.src = src.replace(/\bdpr_(1\.0|auto)\b/g, 'dpr_' + @device_pixel_ratio())
      setAttributes(tag, attrs)
    this

  ###*
  * Provide a transformation object, initialized with own's options, for chaining purposes.
  * @return {Transformation}
  ###
  transformation: (options)->
    Transformation.new( @config(options)).setParent( this)

global = module?.exports ? window
# Copy all previously defined object in the "Cloudinary" scope

_.extend( Cloudinary, global.Cloudinary) if global.Cloudinary
global.Cloudinary = Cloudinary
