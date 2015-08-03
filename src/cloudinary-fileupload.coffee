# Extend CloudinaryJQuery

CloudinaryJQuery::delete_by_token = (delete_token, options) ->
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

CloudinaryJQuery::unsigned_upload_tag = (upload_preset, upload_params, options) ->
  $('<input/>').attr(
    type: 'file'
    name: 'file').unsigned_cloudinary_upload upload_preset, upload_params, options

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


        if multiple
          add_field()
        else
          field = $(data.form).find('input[name="' + data.cloudinaryField + '"]')
          if field.length > 0
            field.val upload_info
          else
            add_field()
      $(e.target).trigger 'cloudinarydone', data

    @bind 'fileuploadsend', (e, data) ->
      # add a common unique ID to all chunks of the same uploaded file
      data.headers['X-Unique-Upload-Id'] = (Math.random() * 10000000000).toString(16)

    @bind 'fileuploadstart', (e) ->
      $(e.target).trigger 'cloudinarystart'

    @bind 'fileuploadstop', (e) ->
      $(e.target).trigger 'cloudinarystop'

    @bind 'fileuploadprogress', (e, data) ->
      $(e.target).trigger 'cloudinaryprogress', data

    @bind 'fileuploadprogressall', (e, data) ->
      $(e.target).trigger 'cloudinaryprogressall', data

    @bind 'fileuploadfail', (e, data) ->
      $(e.target).trigger 'cloudinaryfail', data

    @bind 'fileuploadalways', (e, data) ->
      $(e.target).trigger 'cloudinaryalways', data

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
  this

$.fn.unsigned_cloudinary_upload = (upload_preset, upload_params = {}, options = {}) ->
  upload_params = _.cloneDeep(upload_params)
  options = _.cloneDeep(options)
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
  html_options.class = _.trimRight("cloudinary_fileupload #{html_options.class || ''}")
  if options.multiple
    html_options.multiple = true
  @attr(html_options).cloudinary_fileupload options
  this

$.cloudinary = new CloudinaryJQuery()

