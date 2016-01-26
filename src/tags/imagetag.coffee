((root, factory) ->
  if (typeof define == 'function') && define.amd
    define ['tags/htmltag', 'cloudinary', 'require'], factory
  else if typeof exports == 'object'
    module.exports = factory(require('./tags/htmltag'), require('./cloudinary'), require)
  else
    root.cloudinary ||= {}
    root.cloudinary.ImageTag = factory(root.cloudinary.HtmlTag, root.cloudinary.Cloudinary, ()-> root.cloudinary.Cloudinary)
)(this, (HtmlTag, Cloudinary, require)->
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
      Cloudinary ||= require('./cloudinary') # Circular reference
      attr = super() || []
      attr['src'] ?= new Cloudinary(@getOptions()).url(@publicId)
      attr

)