class CloudinaryJQuery extends Cloudinary
  constructor: (options)->
    super(options)


  image: (publicId, options={})->
    i = super(publicId, options)
    url= i.getAttr('src')
    i.setAttr('src', '')
    $(i.toHtml()).removeAttr('src').data('src-cache', url).cloudinary_update(options);

  video: (publicId, options = {})->
    # TODO implement

$.fn.cloudinary = (options) ->
  @filter('img').each(->
    img_options = $.extend({
      width: $(this).attr('width')
      height: $(this).attr('height')
      src: $(this).attr('src')
    }, $(this).data(), options)
    public_id = img_options.source || img_options.src
    delete img_options.source
    delete img_options.src
    url = $.cloudinary.url(public_id, img_options)
    img_options = new Transformation(img_options).toHtmlAttributes() # FIXME include own config
    $(this).data('src-cache', url).attr
      width: img_options.width
      height: img_options.height
    ).cloudinary_update options
  this



###*
* Update hidpi (dpr_auto) and responsive (w_auto) fields according to the current container size and the device pixel ratio.
* Only images marked with the cld-responsive class have w_auto updated.
* options:
* - responsive_use_stoppoints:
*   - true - always use stoppoints for width
*   - "resize" - use exact width on first render and stoppoints on resize (default)
*   - false - always use exact width
* - responsive:
*   - true - enable responsive on this element. Can be done by adding cld-responsive.
*            Note that $.cloudinary.responsive() should be called once on the page.
* - responsive_preserve_height: if set to true, original css height is perserved. Should only be used if the transformation supports different aspect ratios.
###

$.fn.cloudinary_update = (options = {}) ->
  responsive_use_stoppoints = options['responsive_use_stoppoints'] ? $.cloudinary.config('responsive_use_stoppoints') ? 'resize'
  exact = !responsive_use_stoppoints || responsive_use_stoppoints == 'resize' and !options.resizing
  @filter('img').each ->
    if options.responsive
      this.className = _.trim( "this.className  #{'cld-responsive'}") unless this.className.match( /\bcld-responsive\b/)
    attrs = {}
    src = getData(this, 'src-cache') or getData(this, 'src')
    if !src
      return
    responsive = hasClass(this, 'cld-responsive') and src.match(/\bw_auto\b/)
    if responsive
      container = this.parentNode
      containerWidth = 0
      while container and containerWidth == 0
        console.log( "First container: %o", container)
        containerWidth = container.clientWidth || 0
        container = container.parentNode
      console.log( "First width %s, second width %s", containerWidth, containerWidth)
      if containerWidth == 0
        # container doesn't know the size yet. Usually because the image is hidden or outside the DOM.
        return
      requestedWidth = if exact then containerWidth else $.cloudinary.calc_stoppoint(this, containerWidth)
      currentWidth = $(this).data('width') or 0
      if requestedWidth > currentWidth
        # requested width is larger, fetch new image
        $(this).data 'width', requestedWidth
      else
        # requested width is not larger - keep previous
        requestedWidth = currentWidth
      src = src.replace(/\bw_auto\b/g, 'w_' + requestedWidth)
      attrs.width = null
      if !options.responsive_preserve_height
        attrs.height = null
    # Update dpr according to the device's devicePixelRatio
    attrs.src = src.replace(/\bdpr_(1\.0|auto)\b/g, 'dpr_' + $.cloudinary.device_pixel_ratio())
    $(this).attr attrs
  this

webp = null

$.fn.webpify = (options = {}, webp_options) ->
  that = this
  webp_options = webp_options ? options
  if !webp
    webp = $.Deferred()
    webp_canary = new Image
    webp_canary.onerror = webp.reject
    webp_canary.onload = webp.resolve
    webp_canary.src = 'data:image/webp;base64,UklGRi4AAABXRUJQVlA4TCEAAAAvAUAAEB8wAiMwAgSSNtse/cXjxyCCmrYNWPwmHRH9jwMA'
  $ ->
    webp.done(->
      $(that).cloudinary $.extend({}, webp_options, format: 'webp')
    ).fail ->
      $(that).cloudinary options
  this

$.fn.fetchify = (options) ->
  @cloudinary $.extend(options, 'type': 'fetch')

global = module?.exports ? window
# Copy all previously defined object in the "Cloudinary" scope

global.Cloudinary.CloudinaryJQuery = CloudinaryJQuery


$.cloudinary = new CloudinaryJQuery()

