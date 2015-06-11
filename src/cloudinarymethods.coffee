class Cloudinary
  CF_SHARED_CDN = "d3jpl91pxevbkh.cloudfront.net";
  OLD_AKAMAI_SHARED_CDN = "cloudinary-a.akamaihd.net";
  AKAMAI_SHARED_CDN = "res.cloudinary.com";
  SHARED_CDN = AKAMAI_SHARED_CDN;
  DEFAULT_POSTER_OPTIONS = { format: 'jpg', resource_type: 'video' };
  DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv'];

  constructor: (configuration)->
    configure(configuration)

  configure: (new_config, new_value) ->
    unless @cloudinary_config?
      @cloudinary_config = {}
      meta_elements = document.getElementsByTagName("meta");
      for el in meta_elements
        @cloudinary_config[el.getAttribute('name').replace('cloudinary_', '')] = el.getAttribute('content')
    if new_value?
      @cloudinary_config[new_config] = new_value
    else if new_config?
      @cloudinary_config = new_config
    this
  url: (public_id, options) ->
    options = _.extend({}, options)
    cloudinary_url public_id, options

cloudinary_url = (public_id, options = {}) ->
  type = option_consume(options, 'type', 'upload')
  if type == 'fetch'
    options.fetch_format = options.fetch_format or option_consume(options, 'format')
  transformation = new Transformation(options).flatten()
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
