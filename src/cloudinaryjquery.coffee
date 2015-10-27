((root, factory) ->
  if (typeof define == 'function') && define.amd
    define ['jquery', 'util', 'transformation', 'cloudinary'], factory
  else if typeof exports == 'object'
    module.exports = factory(require('jquery'), require('util'), require('transformation'), require('cloudinary'))
  else
    root.cloudinary ||= {}
    root.cloudinary.CloudinaryJQuery = factory(jQuery, root.cloudinary.Util, root.cloudinary.Transformation, root.cloudinary.Cloudinary)

)(this,  (jQuery, Util, Transformation, Cloudinary)->
  class CloudinaryJQuery extends Cloudinary
    ###*
     * Cloudinary class with jQuery support
     * @constructor CloudinaryJQuery
     * @extends Cloudinary
    ###
    constructor: (options)->
      super(options)

    image: (publicId, options={})->
      # generate a tag without the image src
      tag_options = Util.merge( {src: ''}, options)
      img = @imageTag(publicId, tag_options).toHtml()
      # cache the image src
      url = @url(publicId, options)
      # set image src taking responsiveness in account
      jQuery(img).data('src-cache', url).cloudinary_update(options);

    responsive: (options) ->
      responsiveConfig = jQuery.extend(responsiveConfig or {}, options)
      jQuery('img.cld-responsive, img.cld-hidpi').cloudinary_update responsiveConfig
      responsive_resize = responsiveConfig['responsive_resize'] ? @config('responsive_resize') ? true
      if responsive_resize and !responsiveResizeInitialized
        responsiveConfig.resizing = responsiveResizeInitialized  = true
        timeout = null
        jQuery(window).on 'resize', =>
          debounce = responsiveConfig['responsive_debounce'] ? @config('responsive_debounce') ? 100

          reset = ->
            if timeout
              clearTimeout timeout
              timeout = null

          run = ->
            jQuery('img.cld-responsive').cloudinary_update responsiveConfig

          wait = ->
            reset()
            setTimeout (->
              reset()
              run()
            ), debounce

          if debounce
            wait()
          else
            run()


  jQuery.fn.cloudinary = (options) ->
    @filter('img').each(->
      img_options = jQuery.extend({
        width: jQuery(this).attr('width')
        height: jQuery(this).attr('height')
        src: jQuery(this).attr('src')
      }, jQuery(this).data(), options)
      public_id = img_options.source || img_options.src
      delete img_options.source
      delete img_options.src
      url = jQuery.cloudinary.url(public_id, img_options)
      img_options = new Transformation(img_options).toHtmlAttributes()
      jQuery(this).data('src-cache', url).attr
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
  *            Note that jQuery.cloudinary.responsive() should be called once on the page.
  * - responsive_preserve_height: if set to true, original css height is perserved. Should only be used if the transformation supports different aspect ratios.
  ###

  jQuery.fn.cloudinary_update = (options = {}) ->
    responsive_use_stoppoints = options['responsive_use_stoppoints'] ? jQuery.cloudinary.config('responsive_use_stoppoints') ? 'resize'
    exact = !responsive_use_stoppoints || responsive_use_stoppoints == 'resize' and !options.resizing
    @filter('img').each ->
      if options.responsive
          jQuery(this).addClass 'cld-responsive'
      attrs = {}
      src = Util.getData(this, 'src-cache') or Util.getData(this, 'src')
      if !src
        return
      responsive = Util.hasClass(this, 'cld-responsive') and src.match(/\bw_auto\b/)
      if responsive
        container = this.parentNode
        containerWidth = 0
        while container and containerWidth == 0
          containerWidth = container.clientWidth || 0
          container = container.parentNode
        if containerWidth == 0
          # container doesn't know the size yet. Usually because the image is hidden or outside the DOM.
          return
        requestedWidth = if exact then containerWidth else jQuery.cloudinary.calc_stoppoint(this, containerWidth)
        currentWidth = Util.getData(this, 'width') or 0
        if requestedWidth > currentWidth
          # requested width is larger, fetch new image
          Util.setData(this, 'width', requestedWidth)
        else
          # requested width is not larger - keep previous
          requestedWidth = currentWidth
        src = src.replace(/\bw_auto\b/g, 'w_' + requestedWidth)
        attrs.width = null
        if !options.responsive_preserve_height
          attrs.height = null
      # Update dpr according to the device's devicePixelRatio
      attrs.src = src.replace(/\bdpr_(1\.0|auto)\b/g, 'dpr_' + jQuery.cloudinary.device_pixel_ratio())
      jQuery(this).attr attrs
    this

  webp = null

  jQuery.fn.webpify = (options = {}, webp_options) ->
    that = this
    webp_options = webp_options ? options
    if !webp
      webp = jQuery.Deferred()
      webp_canary = new Image
      webp_canary.onerror = webp.reject
      webp_canary.onload = webp.resolve
      webp_canary.src = 'data:image/webp;base64,UklGRi4AAABXRUJQVlA4TCEAAAAvAUAAEB8wAiMwAgSSNtse/cXjxyCCmrYNWPwmHRH9jwMA'
    jQuery ->
      webp.done(->
        jQuery(that).cloudinary jQuery.extend({}, webp_options, format: 'webp')
      ).fail ->
        jQuery(that).cloudinary options
    this

  jQuery.fn.fetchify = (options) ->
    @cloudinary jQuery.extend(options, 'type': 'fetch')

  cloudinary.CloudinaryJQuery = CloudinaryJQuery


  jQuery.cloudinary = new CloudinaryJQuery()
  jQuery.cloudinary.fromDocument()
  CloudinaryJQuery
)