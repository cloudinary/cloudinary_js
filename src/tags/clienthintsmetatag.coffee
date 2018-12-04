###*
 * Image Tag
 * Depends on 'tags/htmltag', 'cloudinary'
###
import HtmlTag from './htmltag'
import {assign} from '../util'

export default class ClientHintsMetaTag extends HtmlTag

  ###*
   * Creates an HTML (DOM) Meta tag that enables client-hints.
   * @constructor ClientHintsMetaTag
   * @extends HtmlTag
  ###
  constructor: (options)->
    super('meta', undefined, assign({"http-equiv": "Accept-CH", content: "DPR, Viewport-Width, Width"}, options))

  ###* @override ###
  closeTag: ()->
    ""