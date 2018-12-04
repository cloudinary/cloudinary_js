import Layer from './layer'
import {isString} from '../util'

class FetchLayer extends Layer
  ###*
   * @constructor FetchLayer
   * @param {Object|string} options - layer parameters or a url
   * @param {string} options.url the url of the image to fetch
  ###
  constructor: (options)->
    super(options)
    if( isString(options))
      @options.url = options
    else if options?.url
      @options.url = options.url

  url: (url)->
    @options.url = url
    @

  ###*
   * generate the string representation of the layer
   * @function FetchLayer#toString
   * @return {String}
  ###
  toString: ()->
    "fetch:#{cloudinary.Util.base64EncodeURL(@options.url)}"

export default FetchLayer;