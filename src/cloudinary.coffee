class Cloudinary
  VERSION = "2.5.0"
  CF_SHARED_CDN = "d3jpl91pxevbkh.cloudfront.net"
  OLD_AKAMAI_SHARED_CDN = "cloudinary-a.akamaihd.net"
  AKAMAI_SHARED_CDN = "res.cloudinary.com"
  SHARED_CDN = AKAMAI_SHARED_CDN
  DEFAULT_POSTER_OPTIONS = { format: 'jpg', resource_type: 'video' }
  DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv']
  SEO_TYPES =
    "image/upload": "images",
    "image/private": "private_images",
    "image/authenticated": "authenticated_images",
    "raw/upload": "files",
    "video/upload": "videos"

  ###*
  * @const {Object} Cloudinary.DEFAULT_IMAGE_PARAMS
  * Defaults values for image parameters.
  *
  * (Previously defined using option_consume() )
  ###
  @DEFAULT_IMAGE_PARAMS =
    resource_type: "image"
    transformation: []
    type: 'upload'

  ###*
  * Defaults values for video parameters.
  * @const {Object} Cloudinary.DEFAULT_VIDEO_PARAMS
  * (Previously defined using option_consume() )
  ###
  @DEFAULT_VIDEO_PARAMS =
    fallback_content: ''
    resource_type: "video"
    source_transformation: {}
    source_types: DEFAULT_VIDEO_SOURCE_TYPES
    transformation: []
    type: 'upload'

  ###*
   * Main Cloudinary class
   * @class Cloudinary
   * @param {Object} options - options to configure Cloudinary
   * @see Configuration for more details
   * @example
   *    var cl = new cloudinary.Cloudinary( { cloud_name: "mycloud"});
   *    var imgTag = cl.image("myPicID");
  ###
  constructor: (options)->

    @devicePixelRatioCache= {}
    @responsiveConfig= {}
    @responsiveResizeInitialized= false

    configuration = new Configuration(options)

    # Provided for backward compatibility
    @config= (newConfig, newValue) ->
      configuration.config(newConfig, newValue)

    ###*
     * Use \<meta\> tags in the document to configure this Cloudinary instance.
     * @return {Cloudinary} this for chaining
    ###
    @fromDocument = ()->
      configuration.fromDocument()
      @


    ###*
     * Use environment variables to configure this Cloudinary instance.
     * @return {Cloudinary} this for chaining
    ###
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

  ###*
   * Convenience constructor
   * @param {Object} options
   * @return {Cloudinary}
   * @example cl = cloudinary.Cloudinary.new( { cloud_name: "mycloud"})
  ###
  @new = (options)-> new @(options)

  ###*
   * Return the resource type and action type based on the given configuration
   * @function Cloudinary#finalizeResourceType
   * @param {Object|string} resourceType
   * @param {string} [type='upload']
   * @param {string} [urlSuffix]
   * @param {boolean} [useRootPath]
   * @param {boolean} [shorten]
   * @returns {string} resource_type/type
   * @ignore
  ###
  finalizeResourceType = (resourceType = "image",type = "upload",urlSuffix,useRootPath,shorten) ->
    if Util.isPlainObject(resourceType)
      options = resourceType
      resourceType = options.resource_type
      type = options.type
      urlSuffix = options.url_suffix
      useRootPath = options.use_root_path
      shorten = options.shorten

    type?='upload'
    if urlSuffix?
      resourceType = SEO_TYPES[ "#{resourceType}/#{type}"]
      type = null
      unless resourceType?
        throw new Error("URL Suffix only supported for #{(key for key of SEO_TYPES).join(', ')}")
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
   * @return {string} The resource URL
  ###

  url: (publicId, options = {}) ->
    if (!publicId)
      return publicId
    options = options.toOptions() if options instanceof Transformation
    options = Util.defaults({}, options, @config(), Cloudinary.DEFAULT_IMAGE_PARAMS)
    if options.type == 'fetch'
      options.fetch_format = options.fetch_format or options.format
      publicId = absolutize(publicId)

    transformation = new Transformation(options)
    transformationString = transformation.serialize()

    throw 'Unknown cloud_name' unless options.cloud_name

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
      try
        publicId = decodeURIComponent(publicId)
      catch error

      publicId = encodeURIComponent(publicId).replace(/%3A/g, ':').replace(/%2F/g, '/')
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

  ###*
   * Generate an video resource URL.
   * @function Cloudinary#video_url
   * @param {string} publicId - the public ID of the resource
   * @param {Object} [options] - options for the tag and transformations, possible values include all {@link Transformation} parameters
   *                          and {@link Configuration} parameters
   * @param {string} [options.type='upload'] - the classification of the resource
   * @return {string} The video URL
  ###
  video_url: (publicId, options) ->
    options = Util.assign({ resource_type: 'video' }, options)
    @url(publicId, options)

  ###*
   * Generate an video thumbnail URL.
   * @function Cloudinary#video_thumbnail_url
   * @param {string} publicId - the public ID of the resource
   * @param {Object} [options] - options for the tag and transformations, possible values include all {@link Transformation} parameters
   *                          and {@link Configuration} parameters
   * @param {string} [options.type='upload'] - the classification of the resource
   * @return {string} The video thumbnail URL
  ###
  video_thumbnail_url: (publicId, options) ->
    options = Util.assign({}, DEFAULT_POSTER_OPTIONS, options)
    @url(publicId, options)

  ###*
   * Generate a string representation of the provided transformation options.
   * @function Cloudinary#transformation_string
   * @param {Object} options - the transformation options
   * @returns {string} The transformation string
  ###
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
    img = @imageTag(publicId, options)
    client_hints = options.client_hints ? @config('client_hints') ? false
    # src must be removed before creating the DOM element to avoid loading the image
    img.setAttr("src", '') unless options.src? || client_hints
    img = img.toDOM()
    unless client_hints
      # cache the image src
      Util.setData(img, 'src-cache', @url(publicId, options))
      # set image src taking responsiveness in account
      @cloudinary_update(img, options)
    img

  ###*
   * Creates a new ImageTag instance, configured using this own's configuration.
   * @function Cloudinary#imageTag
   * @param {string} publicId - the public ID of the resource
   * @param {Object} options - additional options to pass to the new ImageTag instance
   * @return {ImageTag} An ImageTag that is attached (chained) to this Cloudinary instance
  ###
  imageTag: (publicId, options)->
    tag = new ImageTag(publicId, @config())
    tag.transformation().fromOptions( options)
    tag

  ###*
   * Generate an image tag for the video thumbnail.
   * @function Cloudinary#video_thumbnail
   * @param {string} publicId - the public ID of the video
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} An image tag element
  ###
  video_thumbnail: (publicId, options) ->
    @image publicId, Util.merge( {}, DEFAULT_POSTER_OPTIONS, options)

  ###*
   * @function Cloudinary#facebook_profile_image
   * @param {string} publicId - the public ID of the image
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} an image tag element
  ###
  facebook_profile_image: (publicId, options) ->
    @image publicId, Util.assign({type: 'facebook'}, options)

  ###*
   * @function Cloudinary#twitter_profile_image
   * @param {string} publicId - the public ID of the image
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} an image tag element
  ###
  twitter_profile_image: (publicId, options) ->
    @image publicId, Util.assign({type: 'twitter'}, options)

  ###*
   * @function Cloudinary#twitter_name_profile_image
   * @param {string} publicId - the public ID of the image
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} an image tag element
  ###
  twitter_name_profile_image: (publicId, options) ->
    @image publicId, Util.assign({type: 'twitter_name'}, options)

  ###*
   * @function Cloudinary#gravatar_image
   * @param {string} publicId - the public ID of the image
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} an image tag element
  ###
  gravatar_image: (publicId, options) ->
    @image publicId, Util.assign({type: 'gravatar'}, options)

  ###*
   * @function Cloudinary#fetch_image
   * @param {string} publicId - the public ID of the image
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} an image tag element
  ###
  fetch_image: (publicId, options) ->
    @image publicId, Util.assign({type: 'fetch'}, options)

  ###*
   * @function Cloudinary#video
   * @param {string} publicId - the public ID of the image
   * @param {Object} [options] - options for the tag and transformations
   * @return {HTMLImageElement} an image tag element
  ###
  video: (publicId, options = {}) ->
    @videoTag(publicId, options).toHtml()

  ###*
   * Creates a new VideoTag instance, configured using this own's configuration.
   * @function Cloudinary#videoTag
   * @param {string} publicId - the public ID of the resource
   * @param {Object} options - additional options to pass to the new VideoTag instance
   * @return {VideoTag} A VideoTag that is attached (chained) to this Cloudinary instance
  ###
  videoTag: (publicId, options)->
    options = Util.defaults({}, options, @config())
    new VideoTag(publicId, options)

  ###*
   * Generate the URL of the sprite image
   * @function Cloudinary#sprite_css
   * @param {string} publicId - the public ID of the resource
   * @param {Object} [options] - options for the tag and transformations
   * @see {@link http://cloudinary.com/documentation/sprite_generation Sprite generation}
  ###
  sprite_css: (publicId, options) ->
    options = Util.assign({ type: 'sprite' }, options)
    if !publicId.match(/.css$/)
      options.format = 'css'
    @url publicId, options

  ###*
  * Initialize the responsive behaviour.<br>
  * Calls {@link Cloudinary#cloudinary_update} to modify image tags.
   * @function Cloudinary#responsive
  * @param {Object} options
  * @param {String} [options.responsive_class='cld-responsive'] - provide an alternative class used to locate img tags
  * @param {number} [options.responsive_debounce=100] - the debounce interval in milliseconds.
  * @param {boolean} [bootstrap=true] if true processes the img tags by calling cloudinary_update. When false the tags will be processed only after a resize event.
  * @see {@link Cloudinary#cloudinary_update} for additional configuration parameters
  ###
  responsive: (options, bootstrap = true) ->
    @responsiveConfig = Util.merge(@responsiveConfig or {}, options)
    responsiveClass = @responsiveConfig['responsive_class'] ? @config('responsive_class')
    @cloudinary_update( "img.#{responsiveClass}, img.cld-hidpi", @responsiveConfig) if bootstrap
    responsiveResize = @responsiveConfig['responsive_resize'] ? @config('responsive_resize') ? true
    if responsiveResize and !@responsiveResizeInitialized
      @responsiveConfig.resizing = @responsiveResizeInitialized = true
      timeout = null
      window.addEventListener 'resize', =>
        debounce = @responsiveConfig['responsive_debounce'] ? @config('responsive_debounce') ? 100

        reset = ->
          if timeout
            clearTimeout timeout
            timeout = null

        run = =>
          @cloudinary_update "img.#{responsiveClass}", @responsiveConfig

        waitFunc = ()->
          reset()
          run()

        wait = ->
          reset()
          timeout = setTimeout(waitFunc,debounce)
        if debounce
          wait()
        else
          run()

  ###*
   * @function Cloudinary#calc_breakpoint
   * @private
   * @ignore
  ###
  calc_breakpoint: (element, width, steps) ->
    breakpoints = Util.getData(element, 'breakpoints') or Util.getData(element, 'stoppoints') or @config('breakpoints') or @config('stoppoints') or defaultBreakpoints
    if Util.isFunction breakpoints
      breakpoints(width, steps)
    else
      if Util.isString breakpoints
        breakpoints = (parseInt(point) for point in breakpoints.split(',')).sort((a, b) -> a - b)
      closestAbove breakpoints, width

  ###*
   * @function Cloudinary#calc_stoppoint
   * @deprecated Use {@link calc_breakpoint} instead.
   * @private
   * @ignore
  ###
  calc_stoppoint: @::calc_breakpoint

  ###*
   * @function Cloudinary#device_pixel_ratio
   * @private
  ###
  device_pixel_ratio: (roundDpr = true)->
    dpr = window?.devicePixelRatio or 1
    dpr = Math.ceil(dpr) if roundDpr
    if( dpr <= 0 || dpr == NaN)
      dpr = 1
    dprString = dpr.toString()
    if dprString.match(/^\d+$/)
      dprString += '.0'
    dprString

  defaultBreakpoints = (width, steps = 100) ->
    steps * Math.ceil(width / steps)

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

    if options.private_cdn
      cdnPart = options.cloud_name + "-"
      path = ""

    if options.cdn_subdomain
      subdomain = "res-" + cdnSubdomainNumber(publicId)

    if options.secure
      protocol = "https://"
      subdomain = "res" if options.secure_cdn_subdomain == false
      if options.secure_distribution? && options.secure_distribution != OLD_AKAMAI_SHARED_CDN && options.secure_distribution != SHARED_CDN
        cdnPart = ""
        subdomain = ""
        host = options.secure_distribution

    else if options.cname
      protocol = "http://"
      cdnPart = ""
      subdomain = if options.cdn_subdomain then 'a'+((crc32(publicId)%5)+1)+'.' else ''
      host = options.cname

    [protocol, cdnPart, subdomain, host, path].join("")


  ###*
  * Finds all `img` tags under each node and sets it up to provide the image through Cloudinary
  * @param {Element[]} nodes the parent nodes to search for img under
  * @param {Object} [options={}] options and transformations params
  * @function Cloudinary#processImageTags
  ###
  processImageTags: (nodes, options = {}) ->
# similar to `$.fn.cloudinary`
    return this if Util.isEmpty(nodes)
    options = Util.defaults({}, options, @config())
    images = for node in nodes when node.tagName?.toUpperCase() == 'IMG'
      imgOptions = Util.assign(
        {
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
      node
      
    @cloudinary_update( images, options)
    this

  applyBreakpoints = (tag, width, steps, options)->
    responsive_use_breakpoints = options['responsive_use_breakpoints'] ? options['responsive_use_stoppoints'] ? @config('responsive_use_breakpoints') ? @config('responsive_use_stoppoints')
    if (!responsive_use_breakpoints) || (responsive_use_breakpoints == 'resize' and !options.resizing)
      width
    else
      @calc_breakpoint(tag, width, steps)

  findContainerWidth = (element) ->
    containerWidth = 0
    while ((element = element?.parentNode) instanceof Element) and !containerWidth
      style = window.getComputedStyle(element);
      containerWidth = Util.width(element) unless /^inline/.test(style.display)
    containerWidth

  updateDpr = (dataSrc, roundDpr) ->
    dataSrc.replace(/\bdpr_(1\.0|auto)\b/g, 'dpr_' + @device_pixel_ratio(roundDpr))

  maxWidth = (requiredWidth, tag) ->
    imageWidth = Util.getData(tag, 'width') or 0
    if requiredWidth > imageWidth
      imageWidth = requiredWidth
      Util.setData(tag, 'width', requiredWidth)
    imageWidth

  ###*
  * Update hidpi (dpr_auto) and responsive (w_auto) fields according to the current container size and the device pixel ratio.
  * Only images marked with the cld-responsive class have w_auto updated.
  * @function Cloudinary#cloudinary_update
  * @param {(Array|string|NodeList)} elements - the elements to modify
  * @param {Object} options
  * @param {boolean|string} [options.responsive_use_breakpoints=true]
  *  - when `true`, always use breakpoints for width
  * - when `"resize"` use exact width on first render and breakpoints on resize
  * - when `false` always use exact width
  * @param {boolean} [options.responsive] - if `true`, enable responsive on this element. Can be done by adding cld-responsive.
  * @param {boolean} [options.responsive_preserve_height] - if set to true, original css height is preserved.
  *   Should only be used if the transformation supports different aspect ratios.
  ###
  cloudinary_update: (elements, options = {}) ->
    return this if elements == null

    responsive = options.responsive ? @config('responsive') ? false

    elements = switch
      when Util.isArray(elements)
        elements
      when elements.constructor.name == "NodeList"
        elements
      when Util.isString(elements)
        document.querySelectorAll(elements)
      else
        [elements]

    responsiveClass = @responsiveConfig['responsive_class']  ? options['responsive_class'] ? @config('responsive_class')
    roundDpr = options['round_dpr'] ? @config('round_dpr')

    for tag in elements when tag.tagName?.match(/img/i)
      setUrl = true

      if responsive
        Util.addClass(tag, responsiveClass)
      dataSrc = Util.getData(tag, 'src-cache') or Util.getData(tag, 'src')
      unless Util.isEmpty(dataSrc)
        # Update dpr according to the device's devicePixelRatio
        dataSrc = updateDpr.call(this, dataSrc, roundDpr)
        if HtmlTag.isResponsive(tag, responsiveClass)
          containerWidth = findContainerWidth(tag)
          if containerWidth != 0
            switch
              when /w_auto:breakpoints/.test(dataSrc)
                requiredWidth = maxWidth(containerWidth, tag)
                dataSrc = dataSrc.replace( /w_auto:breakpoints([_0-9]*)(:[0-9]+)?/, "w_auto:breakpoints$1:#{requiredWidth}")
              when match = /w_auto(:(\d+))?/.exec(dataSrc)
                requiredWidth = applyBreakpoints.call(this, tag, containerWidth, match[2] , options)
                requiredWidth = maxWidth(requiredWidth, tag)
                dataSrc = dataSrc.replace( /w_auto[^,\/]*/g, "w_#{requiredWidth}")

            Util.removeAttribute(tag, 'width')
            Util.removeAttribute(tag, 'height') unless options.responsive_preserve_height
          else
            # Container doesn't know the size yet - usually because the image is hidden or outside the DOM.
            setUrl = false
        Util.setAttribute(tag, 'src', dataSrc) if setUrl
    this

  ###*
   * Provide a transformation object, initialized with own's options, for chaining purposes.
   * @function Cloudinary#transformation
   * @param {Object} options
   * @return {Transformation}
  ###
  transformation: (options)->
    Transformation.new( @config()).fromOptions(options).setParent( this)

