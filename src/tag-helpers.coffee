class HtmlTag extends Transformation
  constructor: (@name, @public_id, options={})->
    super(options)
  content: ()->
    ""
  openTag: ()->
    "<#{@name} #{_.compact(@attributes()).join(" ")}>"
  attributes: ()->
    for name, value of @toHtmlTagOptions() when value?
      if value == true
        name
      else
        "#{name}=\"#{value}\""
  closeTag:()->
    "</#{@name}>"
  content: ()->
    ""
  toHtml: ()->
    @openTag() +@content()+ @closeTag()

class ImageTag extends HtmlTag
  constructor: (@public_id, options={})->
    super("img", @public_id, options)
  toHtml: ()->
    @openTag()

class VideoTag extends HtmlTag
  DEFAULT_VIDEO_SOURCE_TYPES = ['webm', 'mp4', 'ogv']
  DEFAULT_POSTER_OPTIONS = { format: 'jpg', resource_type: 'video' }

  constructor: (@public_id, options={})->
    super("video", @public_id, options)
    @whitelist.push("source_transformation", "source_types", "poster")
  source_transformation: (value)-> @transformationParam value, "source_transformation"
  source_types: (value)->     @arrayParam value, "source_types"
  poster: (value)-> @param value, "poster"
  content: ()->
    source_types = @getValue("source_types") || Cloudinary.DEFAULT_VIDEO_SOURCE_TYPES
  toHtmlTagOptions: ()->
    super()["src"] = new Cloudinary(@options).url()

if module?.exports
#On a server
  exports.Cloudinary ?= {}
  exports.Cloudinary.ImageTag = ImageTag
  exports.Cloudinary.VideoTag = VideoTag
else
#On a client
  window.Cloudinary.ImageTag  = ImageTag
  window.Cloudinary.VideoTag  = VideoTag
