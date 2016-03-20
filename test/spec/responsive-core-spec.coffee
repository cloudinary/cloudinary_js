describe 'cloudinary', ()->
  defaultConfig = cloud_name: 'demo'
  cl = null
  describe "responsive", ()->
    fixtureContainer = undefined
    testDocument = null
    container = undefined
    testWindow = null

    beforeAll (done)->
      # Open a new window with test HTML. A dynamic title is required in order to open a *new* window each time even if
      # previous window was not closed.
      testWindow = window.open( "responsive-core-test.html","Cloudinary test #{(new Date()).toLocaleString()}", "width=500, height=500")

      testWindow.addEventListener 'load', ()=>
          testDocument = testWindow.document
          image1 = testDocument.getElementById('image1')
          expect(image1.getAttribute('src')).toBeDefined()
          done()
        , false

    afterAll ()->
      testWindow.close()

    beforeEach ()->
      cl = new cloudinary.Cloudinary(cloud_name: 'demo')
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
      divContainer = document.createElement('div')
      divContainer.style.width = 101
      fixtureContainer.appendChild(divContainer)
      aContainer = document.createElement('a')
      divContainer.appendChild( aContainer)
      img = cl.image('sample.jpg',
        width: 'auto'
        dpr: 'auto'
        crop: 'scale'
        responsive: true
      )
      aContainer.appendChild(img)
      cl.responsive()
      expect(img.getAttribute('src')).not.toEqual undefined

    it 'should compute breakpoints correctly', ()->
      el = document.createElement('img')
      fixtureContainer.appendChild(el)
      expect(cl.calc_breakpoint(el, 1)).toEqual 100
      expect(cl.calc_breakpoint(el, 10)).toEqual 100
      expect(cl.calc_breakpoint(el, 110)).toEqual 200
      cl.config('breakpoints', [
        50
        150
      ])
      expect(cl.calc_breakpoint(el, 1)).toEqual 50
      expect(cl.calc_breakpoint(el, 100)).toEqual 150
      expect(cl.calc_breakpoint(el, 180)).toEqual 150

      cl.config 'breakpoints', (width) ->
        width / 2

      expect(cl.calc_breakpoint(el, 100)).toEqual 50

      el.setAttribute( 'data-breakpoints', '70,140')
      expect(cl.calc_breakpoint(el, 1)).toEqual 70
      expect(cl.calc_breakpoint(el, 100)).toEqual 140

    it 'should correctly resize responsive images', (done) ->
      container = undefined
      img = undefined
      dpr = cl.device_pixel_ratio()
      container = document.createElement('div')
      container.style.width = "101px"
      fixtureContainer.appendChild(container)
      img = cl.image('sample.jpg',
          width: 'auto'
          dpr: 'auto'
          crop: 'scale'
          responsive: true)
      container.appendChild(img)
      expect(img.getAttribute('src')).toBeFalsy()
      expect(cloudinary.Util.hasClass(img, 'cld-responsive')).toBeTruthy()
      cl.responsive()
      expect(img.getAttribute('src')).toEqual window.location.protocol + '//res.cloudinary.com/demo/image/upload/c_scale,dpr_' + dpr + ',w_200/sample.jpg'
      container.style.width = "211px"
      expect(img.getAttribute('src')).toEqual window.location.protocol + '//res.cloudinary.com/demo/image/upload/c_scale,dpr_' + dpr + ',w_200/sample.jpg'
      triggerResize window
      window.setTimeout ()->
          # wait(200)
          expect(img.getAttribute('src')).toEqual window.location.protocol + '//res.cloudinary.com/demo/image/upload/c_scale,dpr_' + dpr + ',w_300/sample.jpg'
          container.style.width = "101px"
          window.setTimeout ()->
              # wait(200)
              expect(img.getAttribute('src')).toEqual window.location.protocol + '//res.cloudinary.com/demo/image/upload/c_scale,dpr_' + dpr + ',w_300/sample.jpg'
              done()
            , 200
        , 200

    it "should not resize images with fixed width containers", (done)->
      image1 = testDocument.getElementById('image1')
      src = image1.getAttribute('src')
      expect(src).toBeDefined()
      currentWidth = src.match(/w_(\d+)/)[1]
      handler = ()->
        src = image1.getAttribute('src')
        expect(src).toBeDefined()
        newWidth = src.match(/w_(\d+)/)[1]
        expect(newWidth).toEqual currentWidth
        done()
      testWindow.addEventListener 'resize', handler
      testWindow.resizeBy(200,0)

    describe "responsive_class", ->
      it "should set the class used for responsive functionality", ->
        img = cl.image( "sample", responsive: true, responsive_class: "cl-foobar")
        expect(cloudinary.Util.hasClass(img, "cl-foobar")).toBeTruthy()
      