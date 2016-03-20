describe 'Cloudinary', ()->
  defaultConfig = cloud_name: 'demo'
  cl =null
  describe "responsive", ()->
    fixtureContainer = undefined
    testDocument = null
    container = undefined
    testWindow = null
    beforeAll (done)->
      # Open a new window with test HTML. A dynamic title is required in order to open a *new* window each time even if
      # previous window was not closed.
      testWindow = window.open( "responsive-jquery-test.html","Cloudinary test #{(new Date()).toLocaleString()}", "width=500, height=500")

      testWindow.addEventListener 'load', ()=>
          testDocument = testWindow.document
          image1 = testDocument.getElementById('image1')
          expect(image1.getAttribute('src')).toBeDefined()
          done()
        , false

    afterAll ()->
      testWindow.close()

    beforeEach ()->
      cl = $.cloudinary = new (cloudinary.CloudinaryJQuery)(defaultConfig)
      fixtureContainer = document.createElement('div')
      fixtureContainer.id="fixture";
      document.body.appendChild(fixtureContainer)

    afterEach ()->
      fixtureContainer.remove()

    triggerResize = (window)->
      evt = window.document.createEvent('UIEvents')
      evt.initUIEvent 'resize', true, false, window, 0
      window.dispatchEvent evt


    it 'should traverse up the DOM to find a parent that has clientWidth', ->
      aContainer = undefined
      divContainer = undefined
      img = undefined
      divContainer = $('<div>')
        .css(width: 101)
        .appendTo(fixtureContainer)
      aContainer = $('<a>')
        .appendTo(divContainer)
      img = cl.image('sample.jpg',
          width: 'auto'
          dpr: 'auto'
          crop: 'scale'
          responsive: true
      )
      img.appendTo(aContainer)
      cl.responsive()
      expect(img.attr('src')).not.toEqual undefined

    it 'should compute breakpoints correctly', ->
      el = $('<img/>')
      expect(cl.calc_breakpoint(el, 1)).toEqual 100
      expect(cl.calc_breakpoint(el, 10)).toEqual 100
      expect(cl.calc_breakpoint(el, 110)).toEqual 200
      cl.config().breakpoints = [
          50
          150
      ]
      expect(cl.calc_breakpoint(el, 1)).toEqual 50
      expect(cl.calc_breakpoint(el, 100)).toEqual 150
      expect(cl.calc_breakpoint(el, 180)).toEqual 150

      cl.config().breakpoints = (width) ->
        width / 2

      expect(cl.calc_breakpoint(el, 100)).toEqual 50

      $(el).data 'breakpoints', '70,140'
      expect(cl.calc_breakpoint(el, 1)).toEqual 70
      expect(cl.calc_breakpoint(el, 100)).toEqual 140

    it 'should correctly resize responsive images', (done) ->
      container = undefined
      img = undefined
      dpr = cl.device_pixel_ratio()
      container = $('<div></div>').css(width: 101).appendTo(fixtureContainer)
      img = cl.image('sample.jpg',
        width: 'auto'
        dpr: 'auto'
        crop: 'scale'
        responsive: true)
      img.appendTo(container)
      expect(img.attr('src')).toBeFalsy()
      cl.responsive()
      expect(img.attr('src')).toEqual window.location.protocol + '//res.cloudinary.com/demo/image/upload/c_scale,dpr_' + dpr + ',w_200/sample.jpg'
      container.css 'width', 211
      expect(img.attr('src')).toEqual window.location.protocol + '//res.cloudinary.com/demo/image/upload/c_scale,dpr_' + dpr + ',w_200/sample.jpg'
      $(window).resize()
      window.setTimeout (->
        # wait(200)
        expect(img.attr('src')).toEqual window.location.protocol + '//res.cloudinary.com/demo/image/upload/c_scale,dpr_' + dpr + ',w_300/sample.jpg'
        container.css 'width', 101
        window.setTimeout (->
          # wait(200)
          expect(img.attr('src')).toEqual window.location.protocol + '//res.cloudinary.com/demo/image/upload/c_scale,dpr_' + dpr + ',w_300/sample.jpg'
          done()
        ), 200
      ), 200

    it "should not resize images with fixed width containers", (done)->
      image1 = testDocument.getElementById('image1')
      src = image1.getAttribute('src')
      expect(src).toBeDefined()
      currentWidth = src.match(/w_(\d+)/)[1]
      handler = ()->
        src = image1.getAttribute('src')
        newWidth = src.match(/w_(\d+)/)[1]
        expect(newWidth).toEqual currentWidth
        done()
      testWindow.addEventListener 'resize', handler
      testWindow.resizeBy(200,0)

