

  $.fn.cloudinary = (options) ->
    @filter('img').each(->
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
      return
    ).cloudinary_update options
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

  $.fn.cloudinary_update = (options = {}) ->
    responsive_use_stoppoints = get_config('responsive_use_stoppoints', options, 'resize')
    exact = responsive_use_stoppoints == false or responsive_use_stoppoints == 'resize' and !options.resizing
    @filter('img').each ->
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

  $.fn.webpify = (options = {}, webp_options) ->
    that = this
    webp_options = webp_options ? options
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

  $.fn.fetchify = (options) ->
    @cloudinary $.extend(options, 'type': 'fetch')

  if !$.fn.fileupload
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

  $.fn.cloudinary_fileupload = (options) ->
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

  $.fn.cloudinary_upload_url = (remote_url) ->
    @fileupload('option', 'formData').file = remote_url
    @fileupload 'add', files: [ remote_url ]
    delete @fileupload('option', 'formData').file
    return

  $.fn.unsigned_cloudinary_upload = (upload_preset, upload_params = {}, options = {}) ->
    options = options or {}
    upload_params = extend({}, upload_params)
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
