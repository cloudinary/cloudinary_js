class Cloudinary
  constructor: (@node) ->
  option_consume = (options, option_name, default_value) ->
    result = options[option_name]
    delete options[option_name]
    if typeof result == 'undefined' then default_value else result

  build_array = (arg) ->
    if arg == null or typeof arg == 'undefined'
      []
    else if $.isArray(arg)
      arg
    else
      [ arg ]

  filter = (selector) ->
    @node.querySelectorAll(selector)

  join_array_function = (sep) ->
    (value) ->
      build_array(value).join sep

  present = (value) ->
    typeof value != 'undefined' and ('' + value).length > 0

  process_base_transformations = (options) ->
    `var i`
    transformations = build_array(options.transformation)
    all_named = true
    i = 0
    while i < transformations.length
      all_named = all_named and typeof transformations[i] == 'string'
      i++
    if all_named
      return []
    delete options.transformation
    base_transformations = []
    i = 0
    while i < transformations.length
      transformation = transformations[i]
      if typeof transformation == 'string'
        base_transformations.push 't_' + transformation
      else
        base_transformations.push generate_transformation_string($.extend({}, transformation))
      i++
    base_transformations

  process_size = (options) ->
    size = option_consume(options, 'size')
    if size
      split_size = size.split('x')
      options.width = split_size[0]
      options.height = split_size[1]
    return

  process_html_dimensions = (options) ->
    width = options.width
    height = options.height
    has_layer = options.overlay or options.underlay
    crop = options.crop
    use_as_html_dimensions = !has_layer and !options.angle and crop != 'fit' and crop != 'limit' and crop != 'lfill'
    if use_as_html_dimensions
      if width and !options.html_width and width != 'auto' and parseFloat(width) >= 1
        options.html_width = width
      if height and !options.html_height and parseFloat(height) >= 1
        options.html_height = height
    if !crop and !has_layer
      delete options.width
      delete options.height
    return

  generate_transformation_string = (options) ->
    base_transformations = process_base_transformations(options)
    process_size options
    process_html_dimensions options
    if options['offset'] != undefined
      range = split_range(options['offset'])
      delete options['offset']
      if range != null
        options['start_offset'] = range[0]
        options['end_offset'] = range[1]
    params = []
    for param of TRANSFORMATION_PARAM_NAME_MAPPING
      value = option_consume(options, param)
      if !present(value)
        i++
        continue
      if TRANSFORMATION_PARAM_VALUE_MAPPING[param]
        value = TRANSFORMATION_PARAM_VALUE_MAPPING[param](value)
      if !present(value)
        i++
        continue
      params.push TRANSFORMATION_PARAM_NAME_MAPPING[param] + '_' + value
    params.sort()
    raw_transformation = option_consume(options, 'raw_transformation')
    if present(raw_transformation)
      params.push raw_transformation
    transformation = params.join(',')
    if present(transformation)
      base_transformations.push transformation
    base_transformations.join '/'

  split_range = (range) ->
    splitted = undefined
    switch range.constructor
      when String
        offset_any_pattern_re = '(' + offset_any_pattern + ')..(' + offset_any_pattern + ')'
        if range.match(offset_any_pattern_re)
          splitted = range.split('..')
      when Array
        splitted = range
      else
        splitted = [
          null
          null
        ]
    splitted

  norm_range_value = (value) ->
    offset = String(value).match(new RegExp('^' + offset_any_pattern + '$'))
    if offset
      modifier = if present(offset[5]) then 'p' else ''
      value = (offset[1] or offset[4]) + modifier
    value

  absolutize = (url) ->
    if !url.match(/^https?:\//)
      prefix = document.location.protocol + '//' + document.location.host
      if url[0] == '?'
        prefix += document.location.pathname
      else if url[0] != '/'
        prefix += document.location.pathname.replace(/\/[^\/]*$/, '/')
      url = prefix + url
    url

  cloudinary_url_prefix = (public_id, cloud_name, private_cdn, cdn_subdomain, secure_cdn_subdomain, cname, secure, secure_distribution, protocol) ->
    if cloud_name.match(/^\//) and !secure
      return '/res' + cloud_name
    prefix = if secure then 'https://' else if window.location.protocol == 'file:' then 'file://' else 'http://'
    prefix = if protocol then protocol + '//' else prefix
    shared_domain = !private_cdn
    if secure
      if !secure_distribution or secure_distribution == OLD_AKAMAI_SHARED_CDN
        secure_distribution = if private_cdn then cloud_name + '-res.cloudinary.com' else SHARED_CDN
      shared_domain = shared_domain or secure_distribution == SHARED_CDN
      if secure_cdn_subdomain == null and shared_domain
        secure_cdn_subdomain = cdn_subdomain
      if secure_cdn_subdomain
        secure_distribution = secure_distribution.replace('res.cloudinary.com', 'res-' + crc32(public_id) % 5 + 1 + '.cloudinary.com')
      prefix += secure_distribution
    else if cname
      subdomain = if cdn_subdomain then 'a' + crc32(public_id) % 5 + 1 + '.' else ''
      prefix += subdomain + cname
    else
      prefix += if private_cdn then cloud_name + '-res' else 'res'
      prefix += if cdn_subdomain then '-' + crc32(public_id) % 5 + 1 else ''
      prefix += '.cloudinary.com'
    if shared_domain
      prefix += '/' + cloud_name
    prefix

  finalize_resource_type = (resource_type, type, url_suffix, use_root_path, shorten) ->
    resource_type_and_type = resource_type + '/' + type
    if url_suffix
      if resource_type_and_type == 'image/upload'
        resource_type_and_type = 'images'
      else if resource_type_and_type == 'raw/upload'
        resource_type_and_type = 'files'
      else
        throw 'URL Suffix only supported for image/upload and raw/upload'
    if use_root_path
      if resource_type_and_type == 'image/upload' or resource_type_and_type == 'images'
        resource_type_and_type = ''
      else
        throw 'Root path only supported for image/upload'
    if shorten and resource_type_and_type == 'image/upload'
      resource_type_and_type = 'iu'
    resource_type_and_type

  cloudinary_url = (public_id, options) ->
    options = options or {}
    type = option_consume(options, 'type', 'upload')
    if type == 'fetch'
      options.fetch_format = options.fetch_format or option_consume(options, 'format')
    transformation = generate_transformation_string(options)
    resource_type = option_consume(options, 'resource_type', 'image')
    version = option_consume(options, 'version')
    format = option_consume(options, 'format')
    cloud_name = option_consume(options, 'cloud_name', $.cloudinary.config().cloud_name)
    if !cloud_name
      throw 'Unknown cloud_name'
    private_cdn = option_consume(options, 'private_cdn', $.cloudinary.config().private_cdn)
    secure_distribution = option_consume(options, 'secure_distribution', $.cloudinary.config().secure_distribution)
    cname = option_consume(options, 'cname', $.cloudinary.config().cname)
    cdn_subdomain = option_consume(options, 'cdn_subdomain', $.cloudinary.config().cdn_subdomain)
    secure_cdn_subdomain = option_consume(options, 'secure_cdn_subdomain', $.cloudinary.config().secure_cdn_subdomain)
    shorten = option_consume(options, 'shorten', $.cloudinary.config().shorten)
    secure = option_consume(options, 'secure', window.location.protocol == 'https:')
    protocol = option_consume(options, 'protocol', $.cloudinary.config().protocol)
    trust_public_id = option_consume(options, 'trust_public_id')
    url_suffix = option_consume(options, 'url_suffix')
    use_root_path = option_consume(options, 'use_root_path', $.cloudinary.config().use_root_path)
    if url_suffix and !private_cdn
      throw 'URL Suffix only supported in private CDN'
    if type == 'fetch'
      public_id = absolutize(public_id)
    if public_id.search('/') >= 0 and !public_id.match(/^v[0-9]+/) and !public_id.match(/^https?:\//) and !present(version)
      version = 1
    if public_id.match(/^https?:/)
      if type == 'upload' or type == 'asset'
        return public_id
      public_id = encodeURIComponent(public_id).replace(/%3A/g, ':').replace(/%2F/g, '/')
    else
      # Make sure public_id is URI encoded.
      public_id = encodeURIComponent(decodeURIComponent(public_id)).replace(/%3A/g, ':').replace(/%2F/g, '/')
      if url_suffix
        if url_suffix.match(/[\.\/]/)
          throw 'url_suffix should not include . or /'
        public_id = public_id + '/' + url_suffix
      if format
        if !trust_public_id
          public_id = public_id.replace(/\.(jpg|png|gif|webp)$/, '')
        public_id = public_id + '.' + format
    resource_type_and_type = finalize_resource_type(resource_type, type, url_suffix, use_root_path, shorten)
    prefix = cloudinary_url_prefix(public_id, cloud_name, private_cdn, cdn_subdomain, secure_cdn_subdomain, cname, secure, secure_distribution, protocol)
    url = [
      prefix
      resource_type_and_type
      transformation
      if version then 'v' + version else ''
      public_id
    ].join('/').replace(/([^:])\/+/g, '$1/')
    url

  default_stoppoints = (width) ->
    10 * Math.ceil(width / 10)

  prepare_html_url = (public_id, options) ->
    if $.cloudinary.config('dpr') and !options.dpr
      options.dpr = $.cloudinary.config('dpr')
    url = cloudinary_url(public_id, options)
    width = option_consume(options, 'html_width')
    height = option_consume(options, 'html_height')
    if width
      options.width = width
    if height
      options.height = height
    url

  get_config = (name, options, default_value) ->
    value = options[name] or $.cloudinary.config(name)
    if typeof value == 'undefined'
      value = default_value
    value

  closest_above = (list, value) ->
    i = list.length - 2
    while i >= 0 and list[i] >= value
      i--
    list[i + 1]

  ###*
  # A video codec parameter can be either a String or a Hash.
  #
  # @param {object} param <code>vc_<codec>[ : <profile> : [<level>]]</code>
  #                       or <code>{ codec: 'h264', profile: 'basic', level: '3.1' }</code>
  # @return {string} <code><codec> : <profile> : [<level>]]</code> if a Hash was provided
  #                   or the param if a String was provided.
  #                   Returns NIL if param is not a Hash or String
  ###

  process_video_params = (param) ->
    switch typeof param
      when 'object'
        video = ''
        if param['codec'] != undefined
          video = param['codec']
          if param['profile'] != undefined
            video += ':' + param['profile']
            if param['level'] != undefined
              video += ':' + param['level']
        return video
      when 'string'
        return param
      else
        return null
    return

  join_pair = (key, value) ->
    if !value
      undefined
    else if value == true
      key
    else
      key + '="' + value + '"'

  html_attrs = (attrs) ->
    pairs = $.map(attrs, (value, key) ->
      join_pair key, value
    )
    pairs.sort()
    pairs.filter((pair) ->
      pair
    ).join ' '

  'use strict'
  CF_SHARED_CDN = 'd3jpl91pxevbkh.cloudfront.net'
  OLD_AKAMAI_SHARED_CDN = 'cloudinary-a.akamaihd.net'
  AKAMAI_SHARED_CDN = 'res.cloudinary.com'
  SHARED_CDN = AKAMAI_SHARED_CDN
  DEFAULT_POSTER_OPTIONS =
    format: 'jpg'
    resource_type: 'video'
  DEFAULT_VIDEO_SOURCE_TYPES = [
    'webm'
    'mp4'
    'ogv'
  ]
  TRANSFORMATION_PARAM_NAME_MAPPING =
    angle: 'a'
    audio_codec: 'ac'
    audio_frequency: 'af'
    background: 'b'
    bit_rate: 'br'
    border: 'bo'
    color: 'co'
    color_space: 'cs'
    crop: 'c'
    default_image: 'd'
    delay: 'dl'
    density: 'dn'
    duration: 'du'
    dpr: 'dpr'
    effect: 'e'
    end_offset: 'eo'
    fetch_format: 'f'
    flags: 'fl'
    gravity: 'g'
    height: 'h'
    opacity: 'o'
    overlay: 'l'
    page: 'pg'
    prefix: 'p'
    quality: 'q'
    radius: 'r'
    start_offset: 'so'
    transformation: 't'
    underlay: 'u'
    video_codec: 'vc'
    video_sampling: 'vs'
    width: 'w'
    x: 'x'
    y: 'y'
    zoom: 'z'
  TRANSFORMATION_PARAM_VALUE_MAPPING =
    angle: (angle) ->
      build_array(angle).join '.'
    background: (background) ->
      background.replace /^#/, 'rgb:'
    border: (border) ->
      if $.isPlainObject(border)
        border_width = '' + (border.width or 2)
        border_color = (border.color or 'black').replace(/^#/, 'rgb:')
        border = border_width + 'px_solid_' + border_color
      border
    color: (color) ->
      color.replace /^#/, 'rgb:'
    dpr: (dpr) ->
      dpr = dpr.toString()
      if dpr == 'auto'
        '1.0'
      else if dpr.match(/^\d+$/)
        dpr + '.0'
      else
        dpr
    effect: join_array_function(':')
    flags: join_array_function('.')
    transformation: join_array_function('.')
    video_codec: process_video_params
    start_offset: norm_range_value
    end_offset: norm_range_value
    duration: norm_range_value
  number_pattern = '([0-9]*)\\.([0-9]+)|([0-9]+)'
  offset_any_pattern = '(' + number_pattern + ')([%pP])?'
  cloudinary_config = null
  responsive_config = null
  responsive_resize_initialized = false
  device_pixel_ratio_cache = {}
  cloudinary =
    CF_SHARED_CDN: CF_SHARED_CDN
    OLD_AKAMAI_SHARED_CDN: OLD_AKAMAI_SHARED_CDN
    AKAMAI_SHARED_CDN: AKAMAI_SHARED_CDN
    SHARED_CDN: SHARED_CDN
    DEFAULT_POSTER_OPTIONS: DEFAULT_POSTER_OPTIONS
    config: (new_config, new_value) ->
      if typeof new_value != 'undefined'
        cloudinary_config[new_config] = new_value
      else if typeof new_config == 'string'
        return cloudinary_config[new_config]
      else if new_config
        cloudinary_config = new_config
      cloudinary_config
    url: (public_id, options) ->
      options = extend({}, options)
      cloudinary_url public_id, options
    video_url: (public_id, options) ->
      options = $.extend({ resource_type: 'video' }, options)
      cloudinary_url public_id, options
    video_thumbnail_url: (public_id, options) ->
      options = $.extend(DEFAULT_POSTER_OPTIONS, options)
      cloudinary_url public_id, options
    url_internal: cloudinary_url
    transformation_string: (options) ->
      options = $.extend({}, options)
      generate_transformation_string options
    image: (public_id, options) ->
      options = $.extend({}, options)
      url = prepare_html_url(public_id, options)
      img = $('<img/>').data('src-cache', url).attr(options).cloudinary_update(options)
      img
    video_thumbnail: (public_id, options) ->
      image public_id, $.merge(DEFAULT_POSTER_OPTIONS, options)
      return
    facebook_profile_image: (public_id, options) ->
      $.cloudinary.image public_id, $.extend({ type: 'facebook' }, options)
    twitter_profile_image: (public_id, options) ->
      $.cloudinary.image public_id, $.extend({ type: 'twitter' }, options)
    twitter_name_profile_image: (public_id, options) ->
      $.cloudinary.image public_id, $.extend({ type: 'twitter_name' }, options)
    gravatar_image: (public_id, options) ->
      $.cloudinary.image public_id, $.extend({ type: 'gravatar' }, options)
    fetch_image: (public_id, options) ->
      $.cloudinary.image public_id, $.extend({ type: 'fetch' }, options)
    video: (public_id, options) ->
      options = options or {}
      public_id = public_id.replace(/\.(mp4|ogv|webm)$/, '')
      source_types = option_consume(options, 'source_types', [])
      source_transformation = option_consume(options, 'source_transformation', {})
      fallback = option_consume(options, 'fallback_content', '')
      if source_types.length == 0
        source_types = DEFAULT_VIDEO_SOURCE_TYPES
      video_options = $.extend(true, {}, options)
      if video_options.hasOwnProperty('poster')
        if $.isPlainObject(video_options.poster)
          if video_options.poster.hasOwnProperty('public_id')
            video_options.poster = cloudinary_url(video_options.poster.public_id, video_options.poster)
          else
            video_options.poster = cloudinary_url(public_id, $.extend({}, DEFAULT_POSTER_OPTIONS, video_options.poster))
      else
        video_options.poster = cloudinary_url(public_id, $.extend({}, DEFAULT_POSTER_OPTIONS, options))
      if !video_options.poster
        delete video_options.poster
      html = '<video '
      if !video_options.hasOwnProperty('resource_type')
        video_options.resource_type = 'video'
      multi_source = $.isArray(source_types) and source_types.length > 1
      source = public_id
      if !multi_source
        source = source + '.' + build_array(source_types)[0]
      src = cloudinary_url(source, video_options)
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
          src = cloudinary_url(source + '.' + source_type, $.extend(true, { resource_type: 'video' }, options, transformation))
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
      options = $.extend({ type: 'sprite' }, options)
      if !public_id.match(/.css$/)
        options.format = 'css'
      $.cloudinary.url public_id, options
    responsive: (options) ->
      responsive_config = $.extend(responsive_config or {}, options)
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
      stoppoints = $(element).data('stoppoints') or $.cloudinary.config().stoppoints or default_stoppoints
      if typeof stoppoints == 'function'
        return stoppoints(width)
      if typeof stoppoints == 'string'
        stoppoints = $.map(stoppoints.split(','), (val) ->
          parseInt val
        )
      closest_above stoppoints, width
    device_pixel_ratio: ->
      dpr = window.devicePixelRatio or 1
      dpr_string = device_pixel_ratio_cache[dpr]
      if !dpr_string
        # Find closest supported DPR (to work correctly with device zoom)
        dpr_used = closest_above($.cloudinary.supported_dpr_values, dpr)
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

  cloudinary = (options) ->
    images = for img, i in filter('img')
      img_options = $.extend({
        width: $(this).attr('width')
        height: $(this).attr('height')
        src: $(this).attr('src')
      }, $(this).data(), options)
      public_id = option_consume(img_options, 'source', option_consume(img_options, 'src'))
      url = prepare_html_url(public_id, img_options)
      $(this).data('src-cache', url).attr
        width: img_options.width
        height: img_options.height

    cloudinary_update options
    this

  ###*
  # Update hidpi (dpr_auto) and responsive (w_auto) fields according to the current container size and the device pixel ratio.
  # Only images marked with the cld-responsive class have w_auto updated.
  # options:
  # - responsive_use_stoppoints:
  #   - true - always use stoppoints for width
  #   - "resize" - use exact width on first render and stoppoints on resize (default)
  #   - false - always use exact width
  # - responsive:
  #   - true - enable responsive on this element. Can be done by adding cld-responsive.
  #            Note that $.cloudinary.responsive() should be called once on the page.
  # - responsive_preserve_height: if set to true, original css height is perserved. Should only be used if the transformation supports different aspect ratios.
  ###

  cloudinary_update = (options) ->
    options = options or {}
    responsive_use_stoppoints = get_config('responsive_use_stoppoints', options, 'resize')
    exact = responsive_use_stoppoints == false or responsive_use_stoppoints == 'resize' and !options.resizing
    filter('img').each ->
      if options.responsive
        $(this).addClass 'cld-responsive'
      attrs = {}
      src = $(this).data('src-cache') or $(this).data('src')
      if !src
        return
      responsive = $(this).hasClass('cld-responsive') and src.match(/\bw_auto\b/)
      if responsive
        parents = $(this).parents()
        parentsLength = parents.length
        container = undefined
        containerWidth = 0
        nthParent = undefined
        nthParent = 0
        while nthParent < parentsLength
          container = parents[nthParent]
          if container and container.clientWidth
            containerWidth = container.clientWidth
            break
          nthParent += 1
        if containerWidth == 0
          # container doesn't know the size yet. Usually because the image is hidden or outside the DOM.
          return
        requestedWidth = if exact then containerWidth else $.cloudinary.calc_stoppoint(this, containerWidth)
        currentWidth = $(this).data('width') or 0
        if requestedWidth > currentWidth
          # requested width is larger, fetch new image
          $(this).data 'width', requestedWidth
        else
          # requested width is not larger - keep previous
          requestedWidth = currentWidth
        src = src.replace(/\bw_auto\b/g, 'w_' + requestedWidth)
        attrs.width = null
        if !options.responsive_preserve_height
          attrs.height = null
      # Update dpr according to the device's devicePixelRatio
      attrs.src = src.replace(/\bdpr_(1\.0|auto)\b/g, 'dpr_' + $.cloudinary.device_pixel_ratio())
      $(this).attr attrs
      return
    this

  webp = null

  webpify = (options, webp_options) ->
    that = this
    options = options or {}
    webp_options = webp_options or options
    if !webp
      webp = $.Deferred()
      webp_canary = new Image
      webp_canary.onerror = webp.reject
      webp_canary.onload = webp.resolve
      webp_canary.src = 'data:image/webp;base64,UklGRi4AAABXRUJQVlA4TCEAAAAvAUAAEB8wAiMwAgSSNtse/cXjxyCCmrYNWPwmHRH9jwMA'
    $ ->
      webp.done(->
        $(that).cloudinary $.extend({}, webp_options, format: 'webp')
        return
      ).fail ->
        $(that).cloudinary options
        return
      return
    this

  fetchify = (options) ->
    @cloudinary $.extend(options, 'type': 'fetch')

  if !fileupload
    return

  $.cloudinary.delete_by_token = (delete_token, options) ->
    options = options or {}
    url = options.url
    if !url
      cloud_name = options.cloud_name or $.cloudinary.config().cloud_name
      url = 'https://api.cloudinary.com/v1_1/' + cloud_name + '/delete_by_token'
    dataType = if $.support.xhrFileUpload then 'json' else 'iframe json'
    $.ajax
      url: url
      method: 'POST'
      data: token: delete_token
      headers: 'X-Requested-With': 'XMLHttpRequest'
      dataType: dataType

  cloudinary_fileupload = (options) ->
    initializing = !@data('blueimpFileupload')
    if initializing
      options = $.extend({
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
          multiple = $(e.target).prop('multiple')

          add_field = ->
            $('<input/>').attr(
              type: 'hidden'
              name: data.cloudinaryField).val(upload_info).appendTo data.form
            return

          if multiple
            add_field()
          else
            field = $(data.form).find('input[name="' + data.cloudinaryField + '"]')
            if field.length > 0
              field.val upload_info
            else
              add_field()
        $(e.target).trigger 'cloudinarydone', data
        return
      @bind 'fileuploadsend', (e, data) ->
        # add a common unique ID to all chunks of the same uploaded file
        data.headers['X-Unique-Upload-Id'] = (Math.random() * 10000000000).toString(16)
        return
      @bind 'fileuploadstart', (e) ->
        $(e.target).trigger 'cloudinarystart'
        return
      @bind 'fileuploadstop', (e) ->
        $(e.target).trigger 'cloudinarystop'
        return
      @bind 'fileuploadprogress', (e, data) ->
        $(e.target).trigger 'cloudinaryprogress', data
        return
      @bind 'fileuploadprogressall', (e, data) ->
        $(e.target).trigger 'cloudinaryprogressall', data
        return
      @bind 'fileuploadfail', (e, data) ->
        $(e.target).trigger 'cloudinaryfail', data
        return
      @bind 'fileuploadalways', (e, data) ->
        $(e.target).trigger 'cloudinaryalways', data
        return
      if !@fileupload('option').url
        cloud_name = options.cloud_name or $.cloudinary.config().cloud_name
        resource_type = options.resource_type or 'auto'
        type = options.type or 'upload'
        upload_url = 'https://api.cloudinary.com/v1_1/' + cloud_name + '/' + resource_type + '/' + type
        @fileupload 'option', 'url', upload_url
    this

  cloudinary_upload_url = (remote_url) ->
    @fileupload('option', 'formData').file = remote_url
    @fileupload 'add', files: [ remote_url ]
    delete @fileupload('option', 'formData').file
    return

  unsigned_cloudinary_upload = (upload_preset, upload_params, options) ->
    options = options or {}
    upload_params = $.extend({}, upload_params) or {}
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
      if $.isPlainObject(value)
        upload_params[key] = $.map(value, (v, k) ->
          k + '=' + v
        ).join('|')
      else if $.isArray(value)
        if value.length > 0 and $.isArray(value[0])
          upload_params[key] = $.map(value, (array_value) ->
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
    html_options['class'] = 'cloudinary_fileupload ' + (html_options['class'] or '')
    if options.multiple
      html_options.multiple = true
    @attr(html_options).cloudinary_fileupload options
    this

  $.cloudinary.unsigned_upload_tag = (upload_preset, upload_params, options) ->
    $('<input/>').attr(
      type: 'file'
      name: 'file').unsigned_cloudinary_upload upload_preset, upload_params, options
