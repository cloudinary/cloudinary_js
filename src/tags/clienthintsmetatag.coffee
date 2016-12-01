###*
 * Image Tag
 * Depends on 'tags/htmltag', 'cloudinary'
###
class ClientHintsMetaTag extends HtmlTag

  ###*
   * Creates an HTML (DOM) Meta tag that enables client-hints.
   * @constructor ClientHintsMetaTag
   * @extends HtmlTag
  ###
  constructor: (options)->
    super('meta', undefined, Util.assign({"http-equiv": "Accept-CH", content: "DPR, Viewport-Width, Width"}, options))

  ###* @override ###
  closeTag: ()->
    ""