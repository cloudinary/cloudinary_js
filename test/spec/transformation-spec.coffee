describe "Transformation", ->
  cl = {}
  fixtureContainer = undefined
  protocol = if window.location.protocol == "file:" then "http:" else window.location.protocol
  upload_path = "#{protocol }//res.cloudinary.com/test123/image/upload"
  # copy cloudinary namespace for easy access
  cloudinary.Util.assign(self, cloudinary)

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

  it 'should ignore empty values', ->
    expect(cl.url( 'test',
      width: undefined , # regular
      crop: 'crop',
      flags: undefined, # array
      startOffset: undefined, #range
      transformation: undefined #transformation
    )).toBe protocol + '//res.cloudinary.com/test123/image/upload/c_crop/test'
    expect(cl.url( 'test',
      width: '', # regular
      crop: 'crop',
      flags: [], # array
      startOffset: [], #range
      transformation: [] #transformation
    )).toBe protocol + '//res.cloudinary.com/test123/image/upload/c_crop/test'
    expect(cl.url( 'test',
      width: '', # regular
      crop: 'crop',
      flags: [], # array
      startOffset: '', #range
      transformation: '' #transformation
    )).toBe protocol + '//res.cloudinary.com/test123/image/upload/c_crop/test'
    expect(cl.url( 'test',
      transformation: {} #transformation
    )).toBe protocol + '//res.cloudinary.com/test123/image/upload/test'

  describe "width and height", ->
    it 'should use width and height from options only if crop is given', ->
      expect(cl.url('test',
        width: 100
        height: 100)).toBe protocol + '//res.cloudinary.com/test123/image/upload/test'
      expect(cl.url('test',
        width: 100
        height: 100
        crop: 'crop')).toBe protocol + '//res.cloudinary.com/test123/image/upload/c_crop,h_100,w_100/test'
      expect(cl.url('test',
        cloudinary.Transformation.new()
        .width( 100)
        .height( 100)
        .crop( 'crop'))).toBe protocol + '//res.cloudinary.com/test123/image/upload/c_crop,h_100,w_100/test'

    it 'should not pass width and height to html in case of fit, lfill or limit crop', ->
      test_cloudinary_url 'test', {
        width: 100
        height: 100
        crop: 'limit'
      }, protocol + '//res.cloudinary.com/test123/image/upload/c_limit,h_100,w_100/test', {}
      test_cloudinary_url 'test', {
        width: 100
        height: 100
        crop: 'lfill'
      }, protocol + '//res.cloudinary.com/test123/image/upload/c_lfill,h_100,w_100/test', {}
      test_cloudinary_url 'test', {
        width: 100
        height: 100
        crop: 'fit'
      }, protocol + '//res.cloudinary.com/test123/image/upload/c_fit,h_100,w_100/test', {}
      test_cloudinary_url 'test',
        cloudinary.Transformation.new()
        .width( 100)
        .height( 100)
        .crop( 'fit'), protocol + '//res.cloudinary.com/test123/image/upload/c_fit,h_100,w_100/test', {}

    it 'should not pass width and height to html in case angle was used', ->
      test_cloudinary_url 'test', {
        width: 100
        height: 100
        crop: 'scale'
        angle: 'auto'
      }, protocol + '//res.cloudinary.com/test123/image/upload/a_auto,c_scale,h_100,w_100/test', {}
    it "should support auto width", ->
      test_cloudinary_url("test", { width: "auto:20", crop: 'fill' }, "#{upload_path}/c_fill,w_auto:20/test", {})
      test_cloudinary_url("test", { width: "auto:20:350", crop: 'fill' }, "#{upload_path}/c_fill,w_auto:20:350/test", {})
      test_cloudinary_url("test", { width: "auto:breakpoints", crop: 'fill' }, "#{upload_path}/c_fill,w_auto:breakpoints/test", {})
      test_cloudinary_url("test", { width: "auto:breakpoints_100_1900_20_15", crop: 'fill' }, "#{upload_path}/c_fill,w_auto:breakpoints_100_1900_20_15/test", {})
      test_cloudinary_url("test", { width: "auto:breakpoints:json", crop: 'fill' }, "#{upload_path}/c_fill,w_auto:breakpoints:json/test", {})
    it 'should support oh,ow', ->
      test_cloudinary_url("test", {width: "ow", height: "oh", crop: "crop"}, "#{upload_path}/c_crop,h_oh,w_ow/test", {})
    it 'should support ih,iw', ->
      test_cloudinary_url("test", {width: "iw", height: "ih", crop: "crop"}, "#{upload_path}/c_crop,h_ih,w_iw/test", {})

  it 'should support aspect_ratio', ->
    test_cloudinary_url 'test', {
      aspect_ratio: '1.0'
    }, protocol + '//res.cloudinary.com/test123/image/upload/ar_1.0/test', {}
    test_cloudinary_url 'test', {
      aspect_ratio: '3:2'
    }, protocol + '//res.cloudinary.com/test123/image/upload/ar_3:2/test', {}

  it 'should use x, y, radius, prefix, gravity and quality from options', ->
    test_cloudinary_url 'test', {
      x: 1
      y: 2
      radius: 3
      gravity: 'center'
      quality: 0.4
      prefix: 'a'
    }, protocol + '//res.cloudinary.com/test123/image/upload/g_center,p_a,q_0.4,r_3,x_1,y_2/test', {}
  describe ":quality", ->

    it "support a percent value", ->
      test_cloudinary_url "test", { x: 1, y: 2, radius: 3, gravity:"center", quality: 80, prefix: "a" },
        "#{upload_path}/g_center,p_a,q_80,r_3,x_1,y_2/test", {}

      test_cloudinary_url "test", { x: 1, y: 2, radius: 3, gravity:"center", quality: "80:444", prefix: "a" },
        "#{upload_path}/g_center,p_a,q_80:444,r_3,x_1,y_2/test", {}
    it "should support auto value", ->

      test_cloudinary_url "test", { x: 1, y: 2, radius: 3, gravity:"center", quality: "auto", prefix: "a" },
        "#{upload_path}/g_center,p_a,q_auto,r_3,x_1,y_2/test", {}

      test_cloudinary_url "test", { x: 1, y: 2, radius: 3, gravity:"center", quality: "auto:good", prefix: "a" },
        "#{upload_path}/g_center,p_a,q_auto:good,r_3,x_1,y_2/test", {}


  it 'should support named tranformation', ->
    test_cloudinary_url 'test', { transformation: 'blip' }, protocol + '//res.cloudinary.com/test123/image/upload/t_blip/test', {}

  it 'should support array of named tranformations', ->
    test_cloudinary_url 'test', { transformation: [
      'blip'
      'blop'
    ] }, protocol + '//res.cloudinary.com/test123/image/upload/t_blip.blop/test', {}

  it 'should support base tranformation', ->
    expect(cl.url('test',
      transformation:
        x: 100
        y: 100
        crop: 'fill'
      crop: 'crop'
      width: 100)).toBe protocol + '//res.cloudinary.com/test123/image/upload/c_fill,x_100,y_100/c_crop,w_100/test'

  it 'should support array of base tranformations', ->
    expect(cl.url('test',
      transformation: [
        {
          x: 100
          y: 100
          width: 200
          crop: 'fill'
        }
        { radius: 10 }
      ]
      crop: 'crop'
      width: 100)).toBe protocol + '//res.cloudinary.com/test123/image/upload/c_fill,w_200,x_100,y_100/r_10/c_crop,w_100/test'

  it 'should not include empty tranformations', ->
    expect(cl.url('test', transformation: [
      {}
      {
        x: 100
        y: 100
        crop: 'fill'
      }
      {}
    ])).toBe protocol + '//res.cloudinary.com/test123/image/upload/c_fill,x_100,y_100/test'

  it 'should support size', ->
    test_cloudinary_url 'test', {
      size: '10x10'
      crop: 'crop'
    }, protocol + '//res.cloudinary.com/test123/image/upload/c_crop,h_10,w_10/test',
      width: '10'
      height: '10'

  it 'should support background', ->
    test_cloudinary_url 'test', { background: 'red' }, protocol + '//res.cloudinary.com/test123/image/upload/b_red/test', {}
    test_cloudinary_url 'test', { background: '#112233' }, protocol + '//res.cloudinary.com/test123/image/upload/b_rgb:112233/test', {}

  it 'should support default_image', ->
    test_cloudinary_url 'test', { default_image: 'default' }, protocol + '//res.cloudinary.com/test123/image/upload/d_default/test', {}

  it 'should support angle', ->
    test_cloudinary_url 'test', { angle: 12 }, protocol + '//res.cloudinary.com/test123/image/upload/a_12/test', {}

  it 'should support format for fetch urls', ->
    test_cloudinary_url 'http://cloudinary.com/images/logo.png', {
      type: 'fetch'
      format: 'jpg'
    }, protocol + '//res.cloudinary.com/test123/image/fetch/f_jpg/http://cloudinary.com/images/logo.png', {}

  it 'should support effect', ->
    test_cloudinary_url 'test', { effect: 'sepia' }, protocol + '//res.cloudinary.com/test123/image/upload/e_sepia/test', {}

  it 'should support effect with param', ->
    test_cloudinary_url 'test', { effect: [
      'sepia'
      -10
    ] }, protocol + '//res.cloudinary.com/test123/image/upload/e_sepia:-10/test', {}

  it 'should support density', ->
    test_cloudinary_url 'test', { density: 150 }, protocol + '//res.cloudinary.com/test123/image/upload/dn_150/test', {}

  it 'should support page', ->
    test_cloudinary_url 'test', { page: 5 }, protocol + '//res.cloudinary.com/test123/image/upload/pg_5/test', {}

  it 'should support border', ->
    test_cloudinary_url 'test', { border: width: 5 }, protocol + '//res.cloudinary.com/test123/image/upload/bo_5px_solid_black/test', {}
    test_cloudinary_url 'test', { border:
      width: 5
      color: '#ffaabbdd' }, protocol + '//res.cloudinary.com/test123/image/upload/bo_5px_solid_rgb:ffaabbdd/test', {}
    test_cloudinary_url 'test', { border: '1px_solid_blue' }, protocol + '//res.cloudinary.com/test123/image/upload/bo_1px_solid_blue/test', {}

  it 'should support flags', ->
    test_cloudinary_url 'test', { flags: 'abc' }, protocol + '//res.cloudinary.com/test123/image/upload/fl_abc/test', {}
    test_cloudinary_url 'test', { flags: [
      'abc'
      'def'
    ] }, protocol + '//res.cloudinary.com/test123/image/upload/fl_abc.def/test', {}

  it 'should support opacity', ->
    test_cloudinary_url 'test', { opacity: 30 }, protocol + '//res.cloudinary.com/test123/image/upload/o_30/test', {}

  it 'should support dpr', ->
    test_cloudinary_url 'test', { dpr: 1 }, protocol + '//res.cloudinary.com/test123/image/upload/dpr_1.0/test', {}
    test_cloudinary_url 'test', { dpr: 'auto' }, protocol + '//res.cloudinary.com/test123/image/upload/dpr_auto/test', {}
    test_cloudinary_url 'test', { dpr: 1.5 }, protocol + '//res.cloudinary.com/test123/image/upload/dpr_1.5/test', {}

  describe "keyframe_interval", ->
    it 'should support keyframe_interval in options', ->
      expect(Transformation.new( keyframe_interval: 10).toString()).toEqual("ki_10")
    it 'should support keyframeInterval()', ->
      expect(Transformation.new().keyframeInterval(10).toString()).toEqual("ki_10")
  describe "streaming_profile", ->
    it 'should support streaming_profile in options', ->
      expect(Transformation.new( streaming_profile: "somë-profilé").toString()).toEqual("sp_somë-profilé")
    it 'should support streamingProfile()', ->
      expect(Transformation.new().streamingProfile("somë-profilé").toString()).toEqual("sp_somë-profilé")

  describe 'zoom', ->
    it 'should support a decimal value', ->
      test_cloudinary_url 'test', { zoom: 1.2 }, protocol + '//res.cloudinary.com/test123/image/upload/z_1.2/test', {}

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
      expect(cloudinary.Util.getAttribute( result, 'src')).toBe protocol + '//res.cloudinary.com/test123/image/upload/dpr_2.0/test'

  describe 'Conditional Transformation', ->
    beforeEach ->
      @cl = cloudinary.Cloudinary.new({cloud_name: "sdk-test"})
    afterEach ->

    describe 'with literal condition string', ->
      it "should include the if parameter as the first component in the transformation string", ->
        url = @cl.url("sample", { if: "w_lt_200", crop: "fill", height: 120, width: 80} )
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_lt_200,c_fill,h_120,w_80/sample")
        url = @cl.url("sample", { crop: "fill", height: 120, if: "w_lt_200", width: 80} )
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_lt_200,c_fill,h_120,w_80/sample")

      it "should allow multiple conditions when chaining transformations ", ->
        url = @cl.url("sample", transformation: [{if: "w_lt_200",crop: "fill",height: 120, width: 80},
          {if: "w_gt_400",crop: "fit",width: 150,height: 150},
          {effect: "sepia"}])
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_lt_200,c_fill,h_120,w_80/if_w_gt_400,c_fit,h_150,w_150/e_sepia/sample")
      describe "including spaces and operators", ->
        it "should translate operators", ->
          url = @cl.url("sample", { if: "w < 200", crop: "fill", height: 120, width: 80} )
          expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_lt_200,c_fill,h_120,w_80/sample")

    describe 'if end', ->
      it "should include the if_end as the last parameter in its component", ->
        url = @cl.url("sample", transformation: [{if: "w_lt_200"},
          {crop: "fill", height: 120, width: 80,effect: "sharpen"},
          {effect: "brightness:50"},
          {effect: "shadow",color: "red"},
          { if: "end"}])
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_lt_200/c_fill,e_sharpen,h_120,w_80/e_brightness:50/co_red,e_shadow/if_end/sample")
      it "should support if_else with transformation parameters", ->
        url = @cl.url("sample", transformation: [{if: "w_lt_200",crop: "fill",height: 120,width: 80},
          {if: "else",crop: "fill",height: 90, width: 100}])
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_lt_200,c_fill,h_120,w_80/if_else,c_fill,h_90,w_100/sample")
      it "if_else should be without any transformation parameters", ->
        url = @cl.url("sample", transformation: [
          {if: "aspect_ratio_lt_0.7"},
          {crop: "fill",height: 120,width: 80},
          {if: "else"},
          {crop: "fill",height: 90,width: 100}])
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_lt_0.7/c_fill,h_120,w_80/if_else/c_fill,h_90,w_100/sample")

    describe 'Chaining with literal conditions', ->
      it "should add an if parameter", ->
        url = @cl.url("sample", cloudinary.Transformation.new().if("ar_gt_3:4").width(100).crop("scale"))
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_gt_3:4,c_scale,w_100/sample")

    describe 'chaining conditions', ->

      it "should passing an operator and a value adds a condition", ->
        url = @cl.url("sample", cloudinary.Transformation.new().if().aspectRatio("gt", "3:4").then().width(100).crop("scale"))
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_gt_3:4,c_scale,w_100/sample")
      it "should chaining condition with `and`", ->
        url = @cl.url("sample", cloudinary.Transformation.new().if().aspectRatio("gt", "3:4").and().width( "gt", 100).then().width(50).crop("scale"))
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_gt_3:4_and_w_gt_100,c_scale,w_50/sample")
      it "should chain conditions with `or`", ->
        url = @cl.url("sample", cloudinary.Transformation.new().if().aspectRatio("gt", "3:4").and().width( "gt", 100).or().width("gt", 200).then().width(50).crop("scale"))
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_gt_3:4_and_w_gt_100_or_w_gt_200,c_scale,w_50/sample")
      it "should translate operators", ->
        url = @cl.url("sample", cloudinary.Transformation.new().if().aspectRatio(">", "3:4").and().width( "<=", 100).or().width("gt", 200).then().width(50).crop("scale"))
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_gt_3:4_and_w_lte_100_or_w_gt_200,c_scale,w_50/sample")
        url = @cl.url("sample", cloudinary.Transformation.new().if().aspectRatio(">", "3:4").and().width( "<=", 100).or().width(">", 200).then().width(50).crop("scale"))
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_gt_3:4_and_w_lte_100_or_w_gt_200,c_scale,w_50/sample")
        url = @cl.url("sample", cloudinary.Transformation.new().if().aspectRatio(">=", "3:4").and().pageCount( ">=", 100).or().pageCount("!=", 0).then().width(50).crop("scale"))
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_gte_3:4_and_pc_gte_100_or_pc_ne_0,c_scale,w_50/sample")
      it "Chains transformations to an image tag", ->
        imgTag = @cl.imageTag("sample")
        imgHtml = imgTag.transformation().crop("fit").width(1000).chain().crop("limit").height(1000).toHtml()
        url = new RegExp("http://res.cloudinary.com/sdk-test/image/upload/c_fit,w_1000/c_limit,h_1000/sample") 
        expect(imgHtml).toMatch(url)
      it "Chains transformations with a private CDN configuration", ->
        imgTag = @cl.imageTag("sample", {private_cdn: true})
        imgHtml = imgTag.transformation().width(100).crop("scale").chain().crop("crop").width(200).toHtml()
        url = new RegExp("http://sdk-test-res.cloudinary.com/image/upload/c_scale,w_100/c_crop,w_200/sample") 
        expect(imgHtml).toMatch(url)
      it "Chains transformations to a secure configuration", ->
        imgTag = @cl.imageTag("sample", {secure: true})
        imgHtml = imgTag.transformation().width(100).crop("scale").chain().crop("crop").width(200).toHtml()
        url = new RegExp("https://res.cloudinary.com/sdk-test/image/upload/c_scale,w_100/c_crop,w_200/sample") 
        expect(imgHtml).toMatch(url)
      it "Chains transformations to a secure private CDN configuration", ->
        imgTag = @cl.imageTag("sample", {secure: true, private_cdn: true})
        imgHtml = imgTag.transformation().width(100).crop("scale").chain().crop("crop").width(200).toHtml()
        url = new RegExp("https://sdk-test-res.cloudinary.com/image/upload/c_scale,w_100/c_crop,w_200/sample") 
        expect(imgHtml).toMatch(url)
      it "should chain if_else conditions disregarding order of transformation parameters in string", ->
        url = @cl.url("sample", {"transformation":[{"if":"ils_gt_0.5","width":120,"height":150,"crop":"pad"},{"if":"else","width":120,"height":150,"crop":"fill"}]})
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ils_gt_0.5,c_pad,h_150,w_120/if_else,c_fill,h_150,w_120/sample")
        paramsOrderUrl = @cl.url("sample", {"transformation":[{"crop":"pad","height":150,"if":"ils_gt_0.5","width":120},{"crop":"fill","height":150,"if":"else","width":120}]})
        expect(paramsOrderUrl).toEqual(url)
      it "should chain if_else conditions when explicitly ending the transformation", ->
        url = @cl.url("sample", {"transformation":[{"if":"ils_gt_0.5"},{"width":120,"height":150,"crop":"pad"},{"if":"else"},{"width":120,"height":150,"crop":"fill"},{"if":"end"}]})
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ils_gt_0.5/c_pad,h_150,w_120/if_else/c_fill,h_150,w_120/if_end/sample")

      it "should support and translate operators:  '=', '!=', '<', '>', '<=', '>=', '&&', '||'", ->

        allOperators =
          'if_'           +
          'w_eq_0_and'    +
          '_h_ne_0_or'    +
          '_ar_lt_0_and'   +
          '_pc_gt_0_and'   +
          '_fc_lte_0_and'  +
          '_w_gte_0'      +
          ',e_grayscale'

        expect(cloudinary.Transformation.new().if()
          .width("=", 0).and()
          .height("!=", 0).or()
          .aspectRatio("<", 0).and()
          .pageCount(">", 0).and()
          .faceCount("<=", 0).and()
          .width(">=", 0)
          .then().effect("grayscale").serialize()).toEqual( allOperators)

        expect(cloudinary.Transformation.new()
          .if("w = 0 && height != 0 || aspectRatio < 0 and pageCount > 0 and faceCount <= 0 and width >= 0")
          .effect("grayscale")
          .serialize()).toEqual(allOperators)

      describe 'endIf()', ->
        it "should serialize to 'if_end'", ->
          url = @cl.url("sample", cloudinary.Transformation.new().if().width( "gt", 100).and().width("lt", 200).then().width(50).crop("scale").endIf())
          expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_gt_100_and_w_lt_200/c_scale,w_50/if_end/sample")
        it "force the if clause to be chained", ->
          url = @cl.url("sample", cloudinary.Transformation.new().if().width( "gt", 100).and().width("lt", 200).then().width(50).crop("scale").endIf())
          expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_gt_100_and_w_lt_200/c_scale,w_50/if_end/sample")
        it "force the if_else clause to be chained", ->
          url = @cl.url("sample", cloudinary.Transformation.new().if().width( "gt", 100).and().width("lt", 200).then().width(50).crop("scale").else().width(100).crop("crop").endIf())
          expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_gt_100_and_w_lt_200/c_scale,w_50/if_else/c_crop,w_100/if_end/sample")


  describe 'User Define Variables', ->
    it "array should define a set of variables", ->
      options = {
        if: "face_count > 2",
        variables: [ ["$z", 5], ["$foo", "$z * 2"] ],
        crop: "scale", width: "$foo * 200"
      }
      t = new Transformation( options).toString()
      expect(t).toEqual("if_fc_gt_2,$z_5,$foo_$z_mul_2,c_scale,w_$foo_mul_200")
    it "'$key' should define a variable", ->
      options = { transformation: [
        {$foo: 10 },
        {if: "face_count > 2"},
        {crop: "scale", width: "$foo * 200 / face_count"},
        {if: "end"}
      ] }
      t = new Transformation( options).toString()
      expect(t).toEqual("$foo_10/if_fc_gt_2/c_scale,w_$foo_mul_200_div_fc/if_end")
    it "should sort variables", ->
      t = new Transformation( {$second: 1, $first: 2}).toString()
      expect(t).toEqual("$first_2,$second_1")
    it "should place ordered variables after individual variables", ->
      t = new Transformation( {variables: [["$z", 5], ["$foo", "$z * 2"] ],$second: 1, $first: 2}).toString()
      expect(t).toEqual("$first_2,$second_1,$z_5,$foo_$z_mul_2")
    it "should support text values", ->
      test_cloudinary_url("sample", {
        effect: "$efname:100",
        $efname: "!blur!"
      }, "http://res.cloudinary.com/test123/image/upload/$efname_!blur!,e_$efname:100/sample", {})

    it "should support string interpolation", ->
      test_cloudinary_url("sample", {
        crop: "scale",
        overlay: {text: "$(start)Hello $(name)$(ext), $(no ) $( no)$(end)", font_family: "Arial", font_size: "18"}
      }, "http://res.cloudinary.com/test123/image/upload/c_scale,l_text:Arial_18:$(start)Hello%20$(name)$(ext)%252C%20%24%28no%20%29%20%24%28%20no%29$(end)/sample", {})

  describe "Layers", ->
    it "should accept a string", ->
      transformation = new Transformation().overlay("text:hello")
      result = transformation.serialize()
      expect(result).toEqual("l_text:hello")
    it "should not pass width/height to html if overlay", ->
      transformation = new Transformation().overlay("text:hello").width(100).height(100);
      result = transformation.serialize()
      expect(result).toEqual(  "h_100,l_text:hello,w_100")
      expect(transformation.toHtmlAttributes().height).toBeUndefined()
      expect(transformation.toHtmlAttributes().width).toBeUndefined()


    describe "chained functions", ->
      it "should produce a layer string", ->
        tests = [
          [new Layer().publicId("logo"), "logo"],
          [new Layer().publicId("folder/logo"), "folder:logo"],
          [new Layer().publicId("logo").type("private"), "private:logo"],
          [new Layer().publicId("logo").format("png"), "logo.png"],
          [new Layer().resourceType("video").publicId("cat"), "video:cat"],
          [new TextLayer().text("Hello World, Nice to meet you?").fontFamily("Arial").fontSize(18), "text:Arial_18:Hello%20World%252C%20Nice%20to%20meet%20you%3F"],
          [new TextLayer().text("Hello World, Nice to meet you?").fontFamily("Arial").fontSize(19).fontWeight("bold").fontStyle("italic").letterSpacing("4"),
            "text:Arial_19_bold_italic_letter_spacing_4:Hello%20World%252C%20Nice%20to%20meet%20you%3F"],
          [new SubtitlesLayer().publicId("sample_sub_en.srt"), "subtitles:sample_sub_en.srt"],
          [new SubtitlesLayer().publicId("sample_sub_he.srt").fontFamily("Arial").fontSize(40), "subtitles:Arial_40:sample_sub_he.srt"]
        ]

        tests.forEach (test)->
          [layer, expected] = test
          expect(layer.toString()).toEqual(expected )

      describe "TextLayer", ->
        describe "fontStyle", ->
          it "should throw an exception if fontFamily is not provided", ->
            expect( -> new TextLayer().fontStyle("italic").toString()).toThrow()

    describe "using options", ->
      text_layer   = "Hello World, /Nice to meet you?"
      text_encoded = "Hello%20World%252C%20%252FNice%20to%20meet%20you%3F"
      layers_options= [
        ["string", "text:test_text:hello", "text:test_text:hello"],
        ["explicit layer parameter", "text:test_text:#{text_encoded}", "text:test_text:#{text_encoded}"],
        ["text parameter", { public_id: "test_text", text: text_layer }, "text:test_text:#{text_encoded}"],
        ["text with font family and size parameters", { text: text_layer, font_family: "Arial", font_size: "18" }, "text:Arial_18:#{text_encoded}"],
        ["text with text style parameter", { text: text_layer, font_family: "Arial", font_size: "18", font_weight: "bold", font_style: "italic", letter_spacing: 4, line_spacing: 2 }, "text:Arial_18_bold_italic_letter_spacing_4_line_spacing_2:#{text_encoded}"],
        ["subtitles", { resource_type: "subtitles", public_id: "subtitles.srt" }, "subtitles:subtitles.srt"],
        ["subtitles with font family and size", { resource_type: "subtitles", public_id: "subtitles.srt", font_family: "Arial", font_size: "40" }, "subtitles:Arial_40:subtitles.srt"]
      ]

      layers =[
        ['overlay', 'l'],
        ['underlay', 'u']
      ]
      layers.forEach (layer)->
        [param, short] = layer
        describe param, ->
          layers_options.forEach (test)->
            [name, options, result] = test
            it "should support #{name}", ()->
              testOptions = {}
              testOptions[param] = options
              expect(new cloudinary.Transformation(testOptions).serialize()).toEqual( "#{short}_#{result}")
          it 'should not pass width/height to html for ' + param, ()->
            testOptions =
              height: 100
              width: 100
            testOptions[param] = 'text:hello'
            test_cloudinary_url 'test', testOptions, "#{protocol}//res.cloudinary.com/test123/image/upload/h_100,#{short}_text:hello,w_100/test", {}
