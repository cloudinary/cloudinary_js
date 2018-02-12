describe 'Cloudinary', ->
  cl = {}
  fixtureContainer = undefined
  protocol = if window.location.protocol == "file:" then "http:" else window.location.protocol

  test_cloudinary_url = (public_id, options, expected_url, expected_options) ->
    result = cl.url(public_id, options)
    expect(new cloudinary.Transformation(options).toHtmlAttributes()).toEqual(expected_options);
    expect(result).toEqual expected_url

  beforeEach ->
    if jQuery?
      $.cloudinary = new (cloudinary.CloudinaryJQuery)(cloud_name: 'test123')
      cl = $.cloudinary
      fixtureContainer = $('<div id="fixture" " >')
      fixtureContainer.appendTo 'body'
    else
      cl = new cloudinary.Cloudinary(cloud_name: 'test123')
      fixtureContainer = document.createElement('div')
      fixtureContainer.id="fixture";
      document.body.appendChild(fixtureContainer)

  afterEach ->
    fixtureContainer.remove()

  it 'should use cloud_name from config', ->
    test_cloudinary_url 'test', {}, protocol + '//res.cloudinary.com/test123/image/upload/test', {}

  it 'should allow overriding cloud_name in options', ->
    test_cloudinary_url 'test', { cloud_name: 'test321' }, protocol + '//res.cloudinary.com/test321/image/upload/test', {}

  it 'should default to akamai if secure', ->
    test_cloudinary_url 'test', { secure: true }, 'https://res.cloudinary.com/test123/image/upload/test', {}

  it 'should default to akamai if secure is given with private_cdn and no secure_distribution', ->
    test_cloudinary_url 'test', {
      secure: true
      private_cdn: true
    }, 'https://test123-res.cloudinary.com/image/upload/test', {}

  it 'should not add cloud_name if secure private_cdn and secure non akamai secure_distribution', ->
    test_cloudinary_url 'test', {
      secure: true
      private_cdn: true
      secure_distribution: 'something.cloudfront.net'
    }, 'https://something.cloudfront.net/image/upload/test', {}

  it 'should use protocol based on secure if given', ->
    if window.location.protocol == 'http:'
      test_cloudinary_url 'test', { secure: true }, 'https://res.cloudinary.com/test123/image/upload/test', {}
      test_cloudinary_url 'test', { secure: false }, 'http://res.cloudinary.com/test123/image/upload/test', {}
      test_cloudinary_url 'test', {}, 'http://res.cloudinary.com/test123/image/upload/test', {}
    if window.location.protocol == 'https:'
      test_cloudinary_url 'test', { secure: true }, 'https://res.cloudinary.com/test123/image/upload/test', {}
      test_cloudinary_url 'test', { secure: false }, 'http://res.cloudinary.com/test123/image/upload/test', {}
      test_cloudinary_url 'test', {}, 'https://res.cloudinary.com/test123/image/upload/test', {}

  it 'should not add cloud_name if private_cdn and not secure', ->
    test_cloudinary_url 'test', { private_cdn: true }, protocol + '//test123-res.cloudinary.com/image/upload/test', {}

  it 'should use format from options', ->
    test_cloudinary_url 'test', { format: 'jpg' }, protocol + '//res.cloudinary.com/test123/image/upload/test.jpg', {}


  it 'should use type from options', ->
    test_cloudinary_url 'test', { type: 'facebook' }, protocol + '//res.cloudinary.com/test123/image/facebook/test', {}

  it 'should use resource_type from options', ->
    test_cloudinary_url 'test', { resource_type: 'raw' }, protocol + '//res.cloudinary.com/test123/raw/upload/test', {}

  it 'should ignore http links only if type is not given or is asset', ->
    test_cloudinary_url 'http://example.com/', { type: undefined }, 'http://example.com/', {}
    test_cloudinary_url 'http://example.com/', { type: 'asset' }, 'http://example.com/', {}
    test_cloudinary_url 'http://example.com/', { type: 'fetch' }, protocol + '//res.cloudinary.com/test123/image/fetch/http://example.com/', {}

  it 'should escape fetch urls', ->
    test_cloudinary_url 'http://blah.com/hello?a=b', { type: 'fetch' }, protocol + '//res.cloudinary.com/test123/image/fetch/http://blah.com/hello%3Fa%3Db', {}

  it 'should escape http urls', ->
    test_cloudinary_url 'http://www.youtube.com/watch?v=d9NF2edxy-M', { type: 'youtube' }, protocol + '//res.cloudinary.com/test123/image/youtube/http://www.youtube.com/watch%3Fv%3Dd9NF2edxy-M', {}

  it 'should support extenal cname', ->
    test_cloudinary_url 'test', { cname: 'hello.com' }, protocol + '//hello.com/test123/image/upload/test', {}

  it 'should support extenal cname with cdn_subdomain on', ->
    test_cloudinary_url 'test', {
      cname: 'hello.com'
      cdn_subdomain: true
    }, protocol + '//a2.hello.com/test123/image/upload/test', {}

  it 'should support new cdn_subdomain format', ->
    test_cloudinary_url 'test', { cdn_subdomain: true }, protocol + '//res-2.cloudinary.com/test123/image/upload/test', {}

  it 'should support secure_cdn_subdomain false override with secure', ->
    test_cloudinary_url 'test', {
      secure: true
      cdn_subdomain: true
      secure_cdn_subdomain: false
    }, 'https://res.cloudinary.com/test123/image/upload/test', {}

  it 'should support secure_cdn_subdomain true override with secure', ->
    test_cloudinary_url 'test', {
      secure: true
      cdn_subdomain: true
      secure_cdn_subdomain: true
      private_cdn: true
    }, 'https://test123-res-2.cloudinary.com/image/upload/test', {}

  it 'should support fetch_image', ->
    tag = cl.fetch_image('http://example.com/hello.jpg?a=b')
    result = cloudinary.Util.getAttribute(tag, 'src')
    expect(result).toEqual protocol + '//res.cloudinary.com/test123/image/fetch/http://example.com/hello.jpg%3Fa%3Db'


  it 'should add version if public_id contains /', ->
    test_cloudinary_url 'folder/test', {}, protocol + '//res.cloudinary.com/test123/image/upload/v1/folder/test', {}
    test_cloudinary_url 'folder/test', { version: 123 }, protocol + '//res.cloudinary.com/test123/image/upload/v123/folder/test', {}

  it 'should not add version if public_id contains version already', ->
    test_cloudinary_url 'v1234/test', {}, protocol + '//res.cloudinary.com/test123/image/upload/v1234/test', {}

  it 'should allow to shorted image/upload urls', ->
    test_cloudinary_url 'test', { shorten: true }, protocol + '//res.cloudinary.com/test123/iu/test', {}

  it "should support url_suffix in shared distribution", ->
    test_cloudinary_url("test", {url_suffix:"hello"}, protocol + "//res.cloudinary.com/test123/images/test/hello", {})
    test_cloudinary_url("test", {url_suffix:"hello", angle: 0}, protocol + "//res.cloudinary.com/test123/images/a_0/test/hello", {})

  it 'should disallow url_suffix in non upload types', ->
    expect(->
      cl.url 'test',
        url_suffix: 'hello'
        private_cdn: true
        type: 'facebook'

    ).toThrow()

  it 'should disallow url_suffix with / or .', ->
    expect(->
      cl.url 'test',
        url_suffix: 'hello/world'
        private_cdn: true

    ).toThrow()
    expect(->
      cl.url 'test',
        url_suffix: 'hello.world'
        private_cdn: true

    ).toThrow()

  it 'should support url_suffix for private_cdn', ->
    test_cloudinary_url 'test', {
      url_suffix: 'hello'
      private_cdn: true
    }, protocol + '//test123-res.cloudinary.com/images/test/hello', {}
    test_cloudinary_url 'test', {
      url_suffix: 'hello'
      angle: 0
      private_cdn: true
    }, protocol + '//test123-res.cloudinary.com/images/a_0/test/hello', {}

  it 'should put format after url_suffix', ->
    test_cloudinary_url 'test', {
      url_suffix: 'hello'
      private_cdn: true
      format: 'jpg'
    }, protocol + '//test123-res.cloudinary.com/images/test/hello.jpg', {}

  it 'should support url_suffix for raw uploads', ->
    test_cloudinary_url 'test', {
      url_suffix: 'hello'
      private_cdn: true
      resource_type: 'raw'
    }, protocol + '//test123-res.cloudinary.com/files/test/hello', {}

  it 'should support url_suffix for raw uploads', ->
    test_cloudinary_url 'test', {
      url_suffix: 'hello'
      private_cdn: true
      resource_type: 'image'
      type: 'private'
    }, protocol + '//test123-res.cloudinary.com/private_images/test/hello', {}

  it 'should support use_root_path in shared distribution', ->
    test_cloudinary_url 'test', {
      use_root_path: true
      private_cdn: false
    }, protocol + '//res.cloudinary.com/test123/test', {}
    test_cloudinary_url 'test', {
      use_root_path: true
      angle: 0
      private_cdn: false
    }, protocol + '//res.cloudinary.com/test123/a_0/test', {}

  it 'should support root_path for private_cdn', ->
    test_cloudinary_url 'test', {
      use_root_path: true
      private_cdn: true
    }, protocol + '//test123-res.cloudinary.com/test', {}
    test_cloudinary_url 'test', {
      use_root_path: true
      angle: 0
      private_cdn: true
    }, protocol + '//test123-res.cloudinary.com/a_0/test', {}

  it 'should support globally set use_root_path for private_cdn', ->
    cl.config('use_root_path', true)
    test_cloudinary_url 'test', { private_cdn: true }, protocol + '//test123-res.cloudinary.com/test', {}
    delete cl.config().use_root_path

  it 'should support use_root_path together with url_suffix for private_cdn', ->
    test_cloudinary_url 'test', {
      use_root_path: true
      private_cdn: true
      url_suffix: 'hello'
    }, protocol + '//test123-res.cloudinary.com/test/hello', {}

  it 'should disallow use_root_path if not image/upload', ->
    expect(->
      cl.url 'test',
        use_root_path: true
        private_cdn: true
        type: 'facebook'

    ).toThrow()
    expect(->
      cl.url 'test',
        use_root_path: true
        private_cdn: true
        resource_type: 'raw'

    ).toThrow()

  it 'should generate sprite css urls', ->
    result = cl.sprite_css('test')
    expect(result).toEqual protocol + '//res.cloudinary.com/test123/image/sprite/test.css'
    result = cl.sprite_css('test.css')
    expect(result).toEqual protocol + '//res.cloudinary.com/test123/image/sprite/test.css'

  it 'should escape public_ids', ->
    tests =
      'a b': 'a%20b'
      'a+b': 'a%2Bb'
      'a%20b': 'a%20b'
      'a-b': 'a-b'
      'a??b': 'a%3F%3Fb'
    for source of tests
      test_cloudinary_url source, {}, protocol + '//res.cloudinary.com/test123/image/upload/' + tests[source], {}

  it 'should accept public_id with special characters', ->
    test_cloudinary_url 'public%id', {},  protocol + '//res.cloudinary.com/test123/image/upload/public%25id', {}

  it 'should allow to override protocol', ->
    options = 'protocol': 'custom:'
    result = cl.url('test', options)
    #expect(new Cloudinary.Transformation(options).toHtmlAttributes()).toEqual({});
    expect(result).toEqual 'custom://res.cloudinary.com/test123/image/upload/test'

  it 'should not fail on falsy public_id', ->
    expect(cl.url(null)).toEqual null
    expect(cl.url(undefined)).toEqual undefined

  describe 'window.devicePixelRatio', ->
    dpr = window.devicePixelRatio
    options = {}
    beforeEach ->
      window.devicePixelRatio = 2
      options = dpr: 'auto'

    afterEach ->
      window.devicePixelRatio = dpr

    it 'should update dpr when creating an image tag using $.cloudinary.image()', ->
      result = cl.image('test', options)
      expect(cloudinary.Util.getAttribute(result, 'src')).toBe protocol + '//res.cloudinary.com/test123/image/upload/dpr_2.0/test'
    describe "round_dpr", ->
      describe "false", ->
        it "should not round up dpr", ->
          window.devicePixelRatio = 1.3
          options.round_dpr = false
          result = cl.image('test', options)
          expect(cloudinary.Util.getAttribute(result, 'src')).toBe protocol + '//res.cloudinary.com/test123/image/upload/dpr_1.3/test'
      describe "true", ->
        it "should round up DPR values", ->
          options.round_dpr = true
          result = cl.image('test', options)
          expect(cloudinary.Util.getAttribute(result, 'src')).toBe protocol + '//res.cloudinary.com/test123/image/upload/dpr_2.0/test'

    if jQuery?
      it 'should update dpr when creating an image tag using $(\'<img/>\').attr(\'data-src\', \'test\').cloudinary(options)', ->
        result = $('<img/>').attr('data-src', 'test').cloudinary(options)
        expect($(result).attr('src')).toEqual protocol + '//res.cloudinary.com/test123/image/upload/dpr_2.0/test'

