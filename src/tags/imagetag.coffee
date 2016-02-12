###*
 * Image Tag
 * Depends on 'tags/htmltag', 'cloudinary'
###
class ImageTag extends HtmlTag

  ###*
   * Creates an HTML (DOM) Image tag using Cloudinary as the source.
   * @constructor ImageTag
   * @extends HtmlTag
   * @param {string} [publicId]
   * @param {Object} [options]
  ###
  constructor: (publicId, options = {})->
    super("img", publicId, options)

  ###* @override ###
  closeTag: ()->
    ""

  ###* @override ###
  attributes: ()->
    attr = super() || []
    attr['src'] ?= new Cloudinary(@getOptions()).url(@publicId)
    attr
