
#_ = require("lodash")
cloudinary_config = undefined

class CloudinaryConfiguration
  ###*
  # Defaults values for parameters.
  #
  # (Previously defined using option_consume() )
  ###
  default_transformation_params ={
    fallback_content: ''
    resource_type: "image"
    secure: window?.location?.protocol == 'https:'
    source_transformation: {}
    source_types: []
    transformation: []
    type: 'upload'
  }

  constructor: (options ={})->
    @configuration = _.cloneDeep(options)
    _.defaults( @configuration, default_transformation_params)


  # Set or update the configuration
  # @param {String|Object} config
  set:(config, value)->
    if _.isUndefined(value)
      @merge(config) if _.isPlainObject(config)
    else
      @config[config] = value
    this

  get: (name)->
    @configuration[name]

  merge: (config={})->
    _.assign(@configuration, config)
  fromDocument: ->
    meta_elements = document?.getElementsByTagName("meta");
    if meta_elements
      for el in meta_elements
        @cloudinary[el.getAttribute('name').replace('cloudinary_', '')] = el.getAttribute('content')
    this

  fromEnvironment: ->
    cloudinary_url = process?.env?.CLOUDINARY_URL
    if cloudinary_url?
      uri = require('url').parse(cloudinary_url, true)
      cloudinary =
        cloud_name: uri.host,
        api_key: uri.auth and uri.auth.split(":")[0],
        api_secret: uri.auth and uri.auth.split(":")[1],
        private_cdn: uri.pathname?,
        secure_distribution: uri.pathname and uri.pathname.substring(1)
      if uri.query?
        for k, v of uri.query
          cloudinary[k] = v
    this

  # Create or modify the Cloudinary client configuration
  #
  # This is a backward compatibility method. For new code, use get(), merge() etc.
  #
  # @param {Hash|String|true} new_config
  # @param {String} new_value
  # @returns {*}
  config: (new_config, new_value) ->
    if !@configuration? || new_config == true
      @fromEnvironment()
      @fromDocument() unless @configuration
    unless _.isUndefined(new_value)
      @set(new_config, new_value)
      @configuration
    else if _.isString(new_config)
      @get(new_config)
    else if _.isObject(new_config)
      @merge(new_config)
      @configuration
    else
      @configuration

  # Whitelisted default options
  defaults: ()->
    _.pick(@configuration, [
      "cdn_subdomain"
      "cloud_name"
      "cname"
      "dpr"
      "fallback_content"
      "private_cdn"
      "protocol"
      "resource_type"
      "responsive_width"
      "secure"
      "secure_cdn_subdomain"
      "secure_distribution"
      "shorten"
      "source_transformation"
      "source_types"
      "transformation"
      "type"
      "use_root_path"

    ])


if module?.exports
#On a server
# module.exports = (new_config, new_value) ->
  exports.config = config
else
#On a client
  window.config = config
