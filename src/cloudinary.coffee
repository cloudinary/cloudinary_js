

###
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
   * url_internal
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

  ###*
   * Return the resource type and action type based on the given configuration
   * @param resource_type
   * @param type
   * @param url_suffix
   * @param use_root_path
   * @param shorten
   * @returns {string} resource_type/type ###
  finalize_resource_type = (resource_type,type,url_suffix,use_root_path,shorten) ->
    if _.isPlainObject(resource_type)
      options = resource_type
      resource_type = options.resource_type
      type = options.type
      url_suffix = options.url_suffix
      use_root_path = options.use_root_path
      shorten = options.shorten

    type?='upload'
    if url_suffix?
      if resource_type=='image' && type=='upload'
        resource_type = "images"
        type = null
      else if resource_type== 'raw' && type== 'upload'
        resource_type = 'files'
        type = null
      else
        throw new Error("URL Suffix only supported for image/upload and raw/upload")
    if use_root_path
      if (resource_type== 'image' && (type== 'upload' || !type?))
        resource_type = null
        type = null
      else
        throw new Error("Root path only supported for image/upload")
    if shorten && resource_type== 'image' && type== 'upload'
      resource_type = 'iu'
      type = null
    [resource_type,type].join("/")

  absolutize = (url) ->
    if !url.match(/^https?:\//)
      prefix = document.location.protocol + '//' + document.location.host
      if url[0] == '?'
        prefix += document.location.pathname
      else if url[0] != '/'
        prefix += document.location.pathname.replace(/\/[^\/]*$/, '/')
      url = prefix + url
    url

  cloudinary_url = (public_id, options = {}) ->
    _.defaults(options, @configuration.defaults())
    if options.type == 'fetch'
      options.fetch_format = options.fetch_format or options.format
      public_id = absolutize(public_id)

    transformation = new Transformation(options)
    transformation_string = transformation.flatten()

    throw 'Unknown cloud_name' unless options.cloud_name

    throw 'URL Suffix only supported in private CDN' if options.url_suffix and !options.private_cdn

    # if public_id has a '/' and doesn't begin with v<number> and doesn't start with http[s]:/ and version is empty
    if public_id.search('/') >= 0 and !public_id.match(/^v[0-9]+/) and !public_id.match(/^https?:\//) and _.isEmpty(options.version)
      options.version = 1

    if public_id.match(/^https?:/)
      if options.type == 'upload' or options.type == 'asset'
        url = public_id
      else
        public_id = encodeURIComponent(public_id).replace(/%3A/g, ':').replace(/%2F/g, '/')
    else
      # Make sure public_id is URI encoded.
      public_id = encodeURIComponent(decodeURIComponent(public_id)).replace(/%3A/g, ':').replace(/%2F/g, '/')
      if options.url_suffix
        if options.url_suffix.match(/[\.\/]/)
          throw 'url_suffix should not include . or /'
        public_id = public_id + '/' + options.url_suffix
      if options.format
        if !options.trust_public_id
          public_id = public_id.replace(/\.(jpg|png|gif|webp)$/, '')
        public_id = public_id + '.' + options.format

    prefix = cloudinary_url_prefix(public_id, options)
    resource_type_and_type = finalize_resource_type(options.resource_type, options.type, options.url_suffix, options.use_root_path, options.shorten)
    transformation.toHtmlTagOptions(options) # backward compatibility - options is muted
    version = if options.version then 'v' + options.version else ''

    url ||  _.filter([
      prefix
      resource_type_and_type
      transformation_string
      version
      public_id
    ], null).join('/').replace(/([^:])\/+/g, '$1/')

  constructor: (options)->
    @configuration = new CloudinaryConfiguration(options)

  # Provided for backward compatibility
  config: (new_config, new_value) ->
    @configuration.config(new_config, new_value)

  # Generate a resource URL
  url: (public_id, options) ->
    options = _.cloneDeep( options)
    cloudinary_url.call this, public_id, options
  video_url: (public_id, options) ->
    options = _.merge({ resource_type: 'video' }, options)
    cloudinary_url.call this,  public_id, options
  video_thumbnail_url: (public_id, options) ->
    options = _.merge(DEFAULT_POSTER_OPTIONS, options)
    cloudinary_url.call this, public_id, options
  url_internal: cloudinary_url
  transformation_string: (options) ->
    options = _.cloneDeep( options)
    generate_transformation_string options
  image: (public_id, options) ->
    options = _.cloneDeep( options)
    url = @url(public_id, options)
    if document?
      img = document.createElement("img")
      img.setAttribute("data-src-cache", url)
      img.setAttribute(name, value) for name, value of options
#      img.attr(options).cloudinary_update(options)
      img
  video_thumbnail: (public_id, options) ->
    image public_id, _.cloneDeep( DEFAULT_POSTER_OPTIONS, options)

  facebook_profile_image: (public_id, options) ->
    @image public_id, _.merge({ type: 'facebook' }, options)
  twitter_profile_image: (public_id, options) ->
    @image public_id, _.merge({ type: 'twitter' }, options)
  twitter_name_profile_image: (public_id, options) ->
    @image public_id, _.merge({ type: 'twitter_name' }, options)
  gravatar_image: (public_id, options) ->
    @image public_id, _.merge({ type: 'gravatar' }, options)
  fetch_image: (public_id, options) ->
    @image public_id, _.merge({ type: 'fetch' }, options)
  video: (public_id, options) ->
    options = options or {}
    public_id = public_id.replace(/\.(mp4|ogv|webm)$/, '')
    source_types = option_consume(options, 'source_types', [])
    source_transformation = option_consume(options, 'source_transformation', {})
    fallback = option_consume(options, 'fallback_content', '')
    if source_types.length == 0
      source_types = DEFAULT_VIDEO_SOURCE_TYPES
    video_options = _.cloneDeep(options)
    if video_options.hasOwnProperty('poster')
      if _.isPlainObject(video_options.poster)
        if video_options.poster.hasOwnProperty('public_id')
          video_options.poster = cloudinary_url.call( this, video_options.poster.public_id, video_options.poster)
        else
          video_options.poster = cloudinary_url.call( this, public_id, _.merge( DEFAULT_POSTER_OPTIONS, video_options.poster))
    else
      video_options.poster = cloudinary_url.call( this, public_id, _.merge( DEFAULT_POSTER_OPTIONS, options))
    if !video_options.poster
      delete video_options.poster
    html = '<video '
    if !video_options.hasOwnProperty('resource_type')
      video_options.resource_type = 'video'
    multi_source = _.isArray(source_types) and source_types.length > 1
    source = public_id
    if !multi_source
      source = source + '.' + build_array(source_types)[0]
    src = cloudinary_url.call( this, source, video_options)
    if !multi_source
      video_options.src = src
    if video_options.hasOwnProperty('html_width')
      video_options.width = option_consume(video_options, 'html_width')
    if video_options.hasOwnProperty('html_height')
      video_options.height = option_consume(video_options, 'html_height')
    html = html + html_attrs(video_options) + '>'
    if multi_source
      i = 0
      while i < source_types.length
        source_type = source_types[i]
        transformation = source_transformation[source_type] or {}
        src = cloudinary_url.call( this, source + '.' +
            source_type,
            _.merge({ resource_type: 'video' },
                      _.cloneDeep(options),
                      _.cloneDeep(transformation)))
        video_type = if source_type == 'ogv' then 'ogg' else source_type
        mime_type = 'video/' + video_type
        html = html + '<source ' + html_attrs(
            src: src
            type: mime_type) + '>'
        i++
    html = html + fallback
    html = html + '</video>'
    html
  sprite_css: (public_id, options) ->
    options = _.merge({ type: 'sprite' }, options)
    if !public_id.match(/.css$/)
      options.format = 'css'
    @url public_id, options
  responsive: (options) ->
    responsive_config = _.merge(responsive_config or {}, options)
    $('img.cld-responsive, img.cld-hidpi').cloudinary_update responsive_config
    responsive_resize = get_config('responsive_resize', responsive_config, true)
    if responsive_resize and !responsive_resize_initialized
      responsive_config.resizing = responsive_resize_initialized = true
      timeout = null
      $(window).on 'resize', ->
        debounce = get_config('responsive_debounce', responsive_config, 100)

        reset = ->
          if timeout
            clearTimeout timeout
            timeout = null
          return

        run = ->
          $('img.cld-responsive').cloudinary_update responsive_config
          return

        wait = ->
          reset()
          setTimeout (->
            reset()
            run()
            return
          ), debounce
          return

        if debounce
          wait()
        else
          run()
        return
    return
  calc_stoppoint: (element, width) ->
    stoppoints = $(element).data('stoppoints') or @config().stoppoints or default_stoppoints
    if typeof stoppoints == 'function'
      return stoppoints(width)
    if typeof stoppoints == 'string'
      stoppoints = _.map(stoppoints.split(','), (val) ->
        parseInt val
      )
    closest_above stoppoints, width
  device_pixel_ratio: ->
    dpr = window.devicePixelRatio or 1
    dpr_string = device_pixel_ratio_cache[dpr]
    if !dpr_string
      # Find closest supported DPR (to work correctly with device zoom)
      dpr_used = closest_above(@supported_dpr_values, dpr)
      dpr_string = dpr_used.toString()
      if dpr_string.match(/^\d+$/)
        dpr_string += '.0'
      device_pixel_ratio_cache[dpr] = dpr_string
    dpr_string
  supported_dpr_values: [
    0.75
    1.0
    1.3
    1.5
    2.0
    3.0
  ]


  # Produce a number between 1 and 5 to be used for cdn sub domains designation
  cdn_subdomain_number = (public_id)->
    crc32(public_id) % 5 + 1

  #  * cdn_subdomain - Boolean (default: false). Whether to automatically build URLs with multiple CDN sub-domains. See this blog post for more details.
  #  * private_cdn - Boolean (default: false). Should be set to true for Advanced plan's users that have a private CDN distribution.
  #  * secure_distribution - The domain name of the CDN distribution to use for building HTTPS URLs. Relevant only for Advanced plan's users that have a private CDN distribution.
  #  * cname - Custom domain name to use for building HTTP URLs. Relevant only for Advanced plan's users that have a private CDN distribution and a custom CNAME.
  #  * secure - Boolean (default: false). Force HTTPS URLs of images even if embedded in non-secure HTTP pages.
  cloudinary_url_prefix = (public_id, options) ->
    return '/res'+options.cloud_name if options.cloud_name?.indexOf("/")==0

    # defaults
    protocol = "http://"
    cdn_part = ""
    subdomain = "res"
    host = ".cloudinary.com"
    path = "/" + options.cloud_name

    # modifications
    if options.protocol
      protocol += '//'
    else if window?.location?.protocol == 'file:'
      protocol = 'file://'

    if options.private_cdn
      cdn_part = options.cloud_name + "-"
      path = ""

    if options.cdn_subdomain
      subdomain = "res-" + cdn_subdomain_number(public_id)

    if options.secure
      protocol = "https://"
      subdomain = "res" if options.secure_cdn_subdomain == false
      if options.secure_distribution? &&
         options.secure_distribution != OLD_AKAMAI_SHARED_CDN &&
         options.secure_distribution != SHARED_CDN
        cdn_part = ""
        subdomain = ""
        host = options.secure_distribution

    else if options.cname
      protocol = "http://"
      cdn_part = ""
      subdomain = if options.cdn_subdomain then 'a'+((crc32(public_id)%5)+1)+'.' else ''
      host = options.cname
#      path = ""

    [protocol, cdn_part, subdomain, host, path].join("")


  html_attrs = (attrs) ->
    pairs = _.map(attrs, (value, key) ->
      join_pair key, value
    )
    pairs.sort()
    pairs.filter((pair) ->
      pair
    ).join ' '

if module?.exports
#On a server
  exports.Cloudinary = Cloudinary
else
#On a client
  window.Cloudinary = Cloudinary

if window.jQuery?
  window.jQuery.cloudinary = new Cloudinary()