describe 'cloudinary', ()->
  cl = {}
  fixtureContainer = undefined
  test_cloudinary_url = (public_id, options, expected_url, expected_options) ->
    result = cl.url(public_id, options)
    expect(new cloudinary.Transformation(options).toHtmlAttributes()).toEqual(expected_options);
    expect(result).toEqual expected_url

  beforeEach ()->
    cl = new cloudinary.Cloudinary(cloud_name: 'test123')
    fixtureContainer = document.createElement('div')
    fixtureContainer.id="fixture";
    document.body.appendChild(fixtureContainer)

  afterEach ()->
    fixtureContainer.remove()

  describe "responsive", ()->
    testDocument = null
    container = undefined
    testWindow = null
    originWindow = window

    beforeAll (done)->
        testWindow = window.open( "spec-empty-window.html","Cloudinary responsive test", "width=500, height=500")
        testDocument = testWindow.document
        testWindow.addEventListener 'load', ()->
          image1 = testDocument.getElementById('image1')
          expect(image1.getAttribute('src')).toBeDefined()
          done()

    afterAll ()->
      testWindow.close()

    resizeWindow = (window)->
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
        responsive: true)
      aContainer.appendChild(img)
      cl.responsive()
      expect(img.getAttribute('src')).not.toEqual undefined

    it 'should compute breakpoints correctly', ()->
      el = document.createElement('img')
      expect(cl.calc_breakpoint(el, 1)).toEqual 10
      expect(cl.calc_breakpoint(el, 10)).toEqual 10
      expect(cl.calc_breakpoint(el, 11)).toEqual 20
      cl.config('breakpoints', [
        50
        150
      ])
      expect(cl.calc_breakpoint(el, 1)).toEqual 50
      expect(cl.calc_breakpoint(el, 100)).toEqual 150
      expect(cl.calc_breakpoint(el, 180)).toEqual 150

      cl.config('breakpoints', (width) ->
        width / 2
      )
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
      cl.responsive()
      expect(img.getAttribute('src')).toEqual window.location.protocol + '//res.cloudinary.com/test123/image/upload/c_scale,dpr_' + dpr + ',w_101/sample.jpg'
      container.style.width = "111px"
      expect(img.getAttribute('src')).toEqual window.location.protocol + '//res.cloudinary.com/test123/image/upload/c_scale,dpr_' + dpr + ',w_101/sample.jpg'
      window.dispatchEvent(new Event('resize'))
      window.setTimeout ()->
          # wait(200)
          expect(img.getAttribute('src')).toEqual window.location.protocol + '//res.cloudinary.com/test123/image/upload/c_scale,dpr_' + dpr + ',w_120/sample.jpg'
          container.style.width = "101px"
          window.setTimeout ()->
              # wait(200)
              expect(img.getAttribute('src')).toEqual window.location.protocol + '//res.cloudinary.com/test123/image/upload/c_scale,dpr_' + dpr + ',w_120/sample.jpg'
              done()
            ,
              200
        ,
          200

    it "should not resize images with fixed width containers", ()->
      image1 = testDocument.getElementById('image1')
      src = image1.getAttribute('src')
      expect(src).toBeDefined()
      currentWidth = src.match(/w_(\d+)/)[1]

