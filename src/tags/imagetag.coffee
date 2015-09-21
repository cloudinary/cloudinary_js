
###*
* Creates an HTML (DOM) Image tag using Cloudinary as the source.
###
class ImageTag extends HtmlTag

  ###*
   * Creates an HTML (DOM) Image tag using Cloudinary as the source.
   * @param {String} [publicId]
   * @param {Object} [options]
  ###
  constructor: (publicId, options={})->
    super("img", publicId, options)

  closeTag: ()->
    ""

  attributes: ()->
    attr = super() || []
    attr['src'] ?= new Cloudinary(@getOptions()).url( @publicId)
    attr

cloudinary.ImageTag = ImageTag
