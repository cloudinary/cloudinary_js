###*
 * Image Tag
 * Depends on 'tags/htmltag', 'cloudinary'
###
class ClientHintsMetaTag extends HtmlTag

  ###*
   * Creates an HTML (DOM) Meta tag that enables Client-Hints for the HTML page. <br/>Browsers that support Client-Hints will send information about the available width for an image on a user’s device and the pixel density of their screen. Cloudinary can then decide on the size of the image the browser needs for displaying the image to the user, and select and deliver an optimal resource – all at the CDN level. See <a href="https://cloudinary.com/documentation/responsive_images#automating_responsive_images_with_client_hints" target="_new">Automating responsive images with Client Hints</a> for more details.
   * @constructor ClientHintsMetaTag
   * @extends HtmlTag  
   * @example 
   * tag = new ClientHintsMetaTag()
   * //returns: <meta http-equiv="Accept-CH" content="DPR, Viewport-Width, Width">
  ###
  constructor: (options)->
    super('meta', undefined, Util.assign({"http-equiv": "Accept-CH", content: "DPR, Viewport-Width, Width"}, options))

  ###* @override ###
  closeTag: ()->
    ""