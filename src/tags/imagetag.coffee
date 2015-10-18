((root, factory) ->
  if (typeof define == 'function') && define.amd
    define ['tags/htmltag', 'cloudinary-main', 'require'], factory
  else if typeof exports == 'object'
    module.exports = factory(require('tags/htmltag'), require('cloudinary-main'), require)
  else
    root.cloudinary ||= {}
    root.cloudinary.ImageTag = factory(cloudinary.HtmlTag, cloudinary.Cloudinary, require)

)(this, (HtmlTag, Cloudinary, require)->
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
      Cloudinary ||= require('cloudinary-main') # Circular reference
      attr = super() || []
      attr['src'] ?= new Cloudinary(@getOptions()).url( @publicId)
      attr
  
  ImageTag
)