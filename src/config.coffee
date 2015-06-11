
#_ = require("lodash")
cloudinary_config = undefined

class CloudinaryConfiguration
  constructor: (@configuration)->

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
        @cloudinary_config[el.getAttribute('name').replace('cloudinary_', '')] = el.getAttribute('content')
    this

  fromEnvironment: ->
    cloudinary_url = process?.env?.CLOUDINARY_URL
    if cloudinary_url?
      uri = require('url').parse(cloudinary_url, true)
      cloudinary_config =
        cloud_name: uri.host,
        api_key: uri.auth and uri.auth.split(":")[0],
        api_secret: uri.auth and uri.auth.split(":")[1],
        private_cdn: uri.pathname?,
        secure_distribution: uri.pathname and uri.pathname.substring(1)
      if uri.query?
        for k, v of uri.query
          cloudinary_config[k] = v
    this

  # Create or modify the Cloudinary client configuration
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



if module?.exports
#On a server
# module.exports = (new_config, new_value) ->
  exports.config = config
else
#On a client
  window.config = config
