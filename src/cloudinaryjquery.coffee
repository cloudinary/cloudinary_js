###*
 * Cloudinary jQuery plugin
 * Depends on 'jquery', 'util', 'transformation', 'cloudinary'
###
class CloudinaryJQuery extends Cloudinary
  ###*
   * Cloudinary class with jQuery support
   * @constructor CloudinaryJQuery
   * @extends Cloudinary
  ###
  constructor: (options)->
    super(options)

  ###*
   * @override
  ###
  image: (publicId, options={})->
    img = @imageTag(publicId, options)
    client_hints = options.client_hints ? @config('client_hints') ? false
    # generate a tag without the image src
    img.setAttr("src", '') unless options.src? || client_hints
    img = jQuery(img.toHtml())
    unless client_hints
      # cache the image src
      # set image src taking responsiveness in account
      img.data('src-cache', @url(publicId, options)).cloudinary_update(options)
    img

  ###*
   * @override
  ###
  responsive: (options) ->
    responsiveConfig = jQuery.extend(responsiveConfig or {}, options)
    responsiveClass = @responsiveConfig['responsive_class'] ? @config('responsive_class')
    jQuery("img.#{responsiveClass}, img.cld-hidpi").cloudinary_update responsiveConfig
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
          jQuery("img.#{responsiveClass}").cloudinary_update responsiveConfig

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

###*
 * The following methods are provided through the jQuery class
 * @class jQuery
###

###*
 * Convert all img tags in the collection to utilize Cloudinary.
 * @function jQuery#cloudinary
 * @param {Object} [options] - options for the tag and transformations
 * @returns {jQuery}
###
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
  jQuery.cloudinary.cloudinary_update @filter('img').toArray(), options
  this

webp = null

###*
 * @function jQuery#webpify
###
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

jQuery.cloudinary = new CloudinaryJQuery()
jQuery.cloudinary.fromDocument()
