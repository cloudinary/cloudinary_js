_ = require("lodash")
cloudinary_config = undefined
module.exports = (new_config, new_value) ->
  unless _.isUndefined(new_value)
    cloudinary_config[new_config] = new_value
  else if _.isString(new_config)
    return cloudinary_config[new_config]
  else if _.isObject(new_config)
    _.extend(cloudinary_config, new_config)
  cloudinary_config
