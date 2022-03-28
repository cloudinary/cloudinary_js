describe('Cloudinary', function() {
  const publicId = "test";
  var cl, fixtureContainer, protocol, test_cloudinary_url;
  cl = {};
  fixtureContainer = void 0;
  protocol = window.location.protocol === "file:" ? "http:" : window.location.protocol;
  test_cloudinary_url = function(public_id, options, expected_url, expected_options) {
    var result;
    result = cl.url(public_id, options);
    expect(new cloudinary.Transformation(options).toHtmlAttributes()).toEqual(expected_options);
    return expect(result).toEqual(expected_url);
  };
  beforeEach(function() {
    if (typeof jQuery !== "undefined" && jQuery !== null) {
      $.cloudinary = new cloudinary.CloudinaryJQuery({
        cloud_name: 'test123'
      });
      cl = $.cloudinary;
      fixtureContainer = $('<div id="fixture" " >');
      return fixtureContainer.appendTo('body');
    } else {
      cl = new cloudinary.Cloudinary({
        cloud_name: 'test123'
      });
      fixtureContainer = document.createElement('div');
      fixtureContainer.id = "fixture";
      return document.body.appendChild(fixtureContainer);
    }
  });
  afterEach(function() {
    return fixtureContainer.remove();
  });
  it('should have constants', function(){
    expect(cloudinary.Cloudinary.DEFAULT_VIDEO_PARAMS).not.toBe(undefined);
  });
  it('should use cloud_name from config', function() {
    return test_cloudinary_url('test', {}, protocol + '//res.cloudinary.com/test123/image/upload/test', {});
  });
  it('should allow overriding cloud_name in options', function() {
    return test_cloudinary_url('test', {
      cloud_name: 'test321'
    }, protocol + '//res.cloudinary.com/test321/image/upload/test', {});
  });
  it('should default to akamai if secure', function() {
    return test_cloudinary_url('test', {
      secure: true
    }, 'https://res.cloudinary.com/test123/image/upload/test', {});
  });
  it('should default to akamai if secure is given with private_cdn and no secure_distribution', function() {
    return test_cloudinary_url('test', {
      secure: true,
      private_cdn: true
    }, 'https://test123-res.cloudinary.com/image/upload/test', {});
  });
  it('should not add cloud_name if secure private_cdn and secure non akamai secure_distribution', function() {
    return test_cloudinary_url('test', {
      secure: true,
      private_cdn: true,
      secure_distribution: 'something.cloudfront.net'
    }, 'https://something.cloudfront.net/image/upload/test', {});
  });
  it('should use protocol based on secure if given', function() {
    if (window.location.protocol === 'http:') {
      test_cloudinary_url('test', {
        secure: true
      }, 'https://res.cloudinary.com/test123/image/upload/test', {});
      test_cloudinary_url('test', {
        secure: false
      }, 'http://res.cloudinary.com/test123/image/upload/test', {});
      test_cloudinary_url('test', {}, 'http://res.cloudinary.com/test123/image/upload/test', {});
    }
    if (window.location.protocol === 'https:') {
      test_cloudinary_url('test', {
        secure: true
      }, 'https://res.cloudinary.com/test123/image/upload/test', {});
      test_cloudinary_url('test', {
        secure: false
      }, 'http://res.cloudinary.com/test123/image/upload/test', {});
      return test_cloudinary_url('test', {}, 'https://res.cloudinary.com/test123/image/upload/test', {});
    }
  });
  it('should not add cloud_name if private_cdn and not secure', function() {
    return test_cloudinary_url('test', {
      private_cdn: true
    }, protocol + '//test123-res.cloudinary.com/image/upload/test', {});
  });
  it('should use format from options', function() {
    return test_cloudinary_url('test', {
      format: 'jpg'
    }, protocol + '//res.cloudinary.com/test123/image/upload/test.jpg', {});
  });
  it('should use type from options', function() {
    return test_cloudinary_url('test', {
      type: 'facebook'
    }, protocol + '//res.cloudinary.com/test123/image/facebook/test', {});
  });
  it('should use resource_type from options', function() {
    return test_cloudinary_url('test', {
      resource_type: 'raw'
    }, protocol + '//res.cloudinary.com/test123/raw/upload/test', {});
  });
  it('should ignore http links only if type is not given or is asset', function() {
    test_cloudinary_url('http://example.com/', {
      type: void 0
    }, 'http://example.com/', {});
    test_cloudinary_url('http://example.com/', {
      type: 'asset'
    }, 'http://example.com/', {});
    return test_cloudinary_url('http://example.com/', {
      type: 'fetch'
    }, protocol + '//res.cloudinary.com/test123/image/fetch/http://example.com/', {});
  });
  it('should escape fetch urls', function() {
    return test_cloudinary_url('http://blah.com/hello?a=b', {
      type: 'fetch'
    }, protocol + '//res.cloudinary.com/test123/image/fetch/http://blah.com/hello%3Fa%3Db', {});
  });
  it('should escape http urls', function() {
    return test_cloudinary_url('http://www.youtube.com/watch?v=d9NF2edxy-M', {
      type: 'youtube'
    }, protocol + '//res.cloudinary.com/test123/image/youtube/http://www.youtube.com/watch%3Fv%3Dd9NF2edxy-M', {});
  });
  it('should support external cname', function() {
    return test_cloudinary_url('test', {
      cname: 'hello.com'
    }, protocol + '//hello.com/test123/image/upload/test', {});
  });
  it('should support external cname with cdn_subdomain on', function() {
    return test_cloudinary_url('test', {
      cname: 'hello.com',
      cdn_subdomain: true
    }, protocol + '//a2.hello.com/test123/image/upload/test', {});
  });
  it('should support new cdn_subdomain format', function() {
    return test_cloudinary_url('test', {
      cdn_subdomain: true
    }, protocol + '//res-2.cloudinary.com/test123/image/upload/test', {});
  });
  it('should support secure_cdn_subdomain false override with secure', function() {
    return test_cloudinary_url('test', {
      secure: true,
      cdn_subdomain: true,
      secure_cdn_subdomain: false
    }, 'https://res.cloudinary.com/test123/image/upload/test', {});
  });
  it('should support secure_cdn_subdomain true override with secure', function() {
    return test_cloudinary_url('test', {
      secure: true,
      cdn_subdomain: true,
      secure_cdn_subdomain: true,
      private_cdn: true
    }, 'https://test123-res-2.cloudinary.com/image/upload/test', {});
  });
  it('should support fetch_image', function() {
    var result, tag;
    tag = cl.fetch_image('http://example.com/hello.jpg?a=b');
    result = cloudinary.Util.getAttribute(tag, 'src');
    return expect(result).toEqual(protocol + '//res.cloudinary.com/test123/image/fetch/http://example.com/hello.jpg%3Fa%3Db');
  });
  it('should add version if public_id contains /', function() {
    test_cloudinary_url('folder/test', {}, protocol + '//res.cloudinary.com/test123/image/upload/v1/folder/test', {});
    test_cloudinary_url('folder/test', {
      version: 123,
      force_version:false
    }, protocol + '//res.cloudinary.com/test123/image/upload/v123/folder/test', {force_version:false});
    test_cloudinary_url('folder/test', {
      version: 123,
      force_version:true
    }, protocol + '//res.cloudinary.com/test123/image/upload/v123/folder/test', {force_version:true});
    return test_cloudinary_url('folder/test', {
      version: 123
    }, protocol + '//res.cloudinary.com/test123/image/upload/v123/folder/test', {});
  });
  it('should not add version if public_id contains version already', function() {
    return test_cloudinary_url('v1234/test', {}, protocol + '//res.cloudinary.com/test123/image/upload/v1234/test', {});
  });
  it('should allow to shorted image/upload urls', function() {
    return test_cloudinary_url('test', {
      shorten: true
    }, protocol + '//res.cloudinary.com/test123/iu/test', {});
  });
  it('Should not set default version if force_version is set to false', function() {
    test_cloudinary_url('folder/test', {force_version:false}, protocol + '//res.cloudinary.com/test123/image/upload/folder/test', {force_version:false});
    return test_cloudinary_url('sample.jpg', {force_version:false}, protocol + '//res.cloudinary.com/test123/image/upload/sample.jpg', {force_version:false});
  });
  it("should support url_suffix in shared distribution", function() {
    test_cloudinary_url("test", {
      url_suffix: "hello"
    }, protocol + "//res.cloudinary.com/test123/images/test/hello", {});
    return test_cloudinary_url("test", {
      url_suffix: "hello",
      angle: 0
    }, protocol + "//res.cloudinary.com/test123/images/a_0/test/hello", {});
  });
  it('should disallow url_suffix in non upload types', function() {
    return expect(function() {
      return cl.url('test', {
        url_suffix: 'hello',
        private_cdn: true,
        type: 'facebook'
      });
    }).toThrow();
  });
  it('should disallow url_suffix with / or .', function() {
    expect(function() {
      return cl.url('test', {
        url_suffix: 'hello/world',
        private_cdn: true
      });
    }).toThrow();
    return expect(function() {
      return cl.url('test', {
        url_suffix: 'hello.world',
        private_cdn: true
      });
    }).toThrow();
  });
  it('should support url_suffix for private_cdn', function() {
    test_cloudinary_url('test', {
      url_suffix: 'hello',
      private_cdn: true
    }, protocol + '//test123-res.cloudinary.com/images/test/hello', {});
    return test_cloudinary_url('test', {
      url_suffix: 'hello',
      angle: 0,
      private_cdn: true
    }, protocol + '//test123-res.cloudinary.com/images/a_0/test/hello', {});
  });
  it('should put format after url_suffix', function() {
    return test_cloudinary_url('test', {
      url_suffix: 'hello',
      private_cdn: true,
      format: 'jpg'
    }, protocol + '//test123-res.cloudinary.com/images/test/hello.jpg', {});
  });
  it('should support url_suffix for raw uploads', function() {
    return test_cloudinary_url('test', {
      url_suffix: 'hello',
      private_cdn: true,
      resource_type: 'raw'
    }, protocol + '//test123-res.cloudinary.com/files/test/hello', {});
  });
  it('should support url_suffix for raw uploads', function() {
    return test_cloudinary_url('test', {
      url_suffix: 'hello',
      private_cdn: true,
      resource_type: 'image',
      type: 'private'
    }, protocol + '//test123-res.cloudinary.com/private_images/test/hello', {});
  });
  it('should support use_root_path in shared distribution', function() {
    test_cloudinary_url('test', {
      use_root_path: true,
      private_cdn: false
    }, protocol + '//res.cloudinary.com/test123/test', {});
    return test_cloudinary_url('test', {
      use_root_path: true,
      angle: 0,
      private_cdn: false
    }, protocol + '//res.cloudinary.com/test123/a_0/test', {});
  });
  it('should support root_path for private_cdn', function() {
    test_cloudinary_url('test', {
      use_root_path: true,
      private_cdn: true
    }, protocol + '//test123-res.cloudinary.com/test', {});
    return test_cloudinary_url('test', {
      use_root_path: true,
      angle: 0,
      private_cdn: true
    }, protocol + '//test123-res.cloudinary.com/a_0/test', {});
  });
  it('should support globally set use_root_path for private_cdn', function() {
    cl.config('use_root_path', true);
    test_cloudinary_url('test', {
      private_cdn: true
    }, protocol + '//test123-res.cloudinary.com/test', {});
    return delete cl.config().use_root_path;
  });
  it('should support use_root_path together with url_suffix for private_cdn', function() {
    return test_cloudinary_url('test', {
      use_root_path: true,
      private_cdn: true,
      url_suffix: 'hello'
    }, protocol + '//test123-res.cloudinary.com/test/hello', {});
  });
  it('should disallow use_root_path if not image/upload', function() {
    expect(function() {
      return cl.url('test', {
        use_root_path: true,
        private_cdn: true,
        type: 'facebook'
      });
    }).toThrow();
    return expect(function() {
      return cl.url('test', {
        use_root_path: true,
        private_cdn: true,
        resource_type: 'raw'
      });
    }).toThrow();
  });
  it('should generate sprite css urls', function() {
    var result;
    result = cl.sprite_css('test');
    expect(result).toEqual(protocol + '//res.cloudinary.com/test123/image/sprite/test.css');
    result = cl.sprite_css('test.css');
    return expect(result).toEqual(protocol + '//res.cloudinary.com/test123/image/sprite/test.css');
  });
  it('should escape public_ids', function() {
    var results, source, tests;
    tests = {
      'a b': 'a%20b',
      'a+b': 'a%2Bb',
      'a%20b': 'a%20b',
      'a-b': 'a-b',
      'a??b': 'a%3F%3Fb'
    };
    results = [];
    for (source in tests) {
      results.push(test_cloudinary_url(source, {}, protocol + '//res.cloudinary.com/test123/image/upload/' + tests[source], {}));
    }
    return results;
  });
  it('should accept public_id with special characters', function() {
    return test_cloudinary_url('public%id', {}, protocol + '//res.cloudinary.com/test123/image/upload/public%25id', {});
  });
  it('should allow to override protocol', function() {
    var options, result;
    options = {
      'protocol': 'custom:'
    };
    result = cl.url('test', options);
    return expect(result).toEqual('custom://res.cloudinary.com/test123/image/upload/test');
  });
  it('should not fail on falsy public_id', function() {
    expect(cl.url(null)).toEqual(null);
    return expect(cl.url(void 0)).toEqual(void 0);
  });
  it('url() should support signature option', function () {
    const publicId = 'test';
    const host = `${protocol}//res.cloudinary.com/test123/image/upload`;
    const transformation = 'c_limit,h_100,w_100';
    let options = {signature: "signature", width: 100, height: 100, crop: 'limit'};

    const expected = `${host}/s--${options.signature}--/${transformation}/${publicId}`;

    let result = cl.url(publicId, options);
    expect(result).toEqual(expected);

    options.signature = `s--${options.signature}--`;

    result = cl.url(publicId, options);
    expect(result).toEqual(expected);
  });
  describe('window.devicePixelRatio', function() {
    var dpr, options;
    dpr = window.devicePixelRatio;
    options = {};
    beforeEach(function() {
      window.devicePixelRatio = 2;
      return options = {
        dpr: 'auto'
      };
    });
    afterEach(function() {
      return window.devicePixelRatio = dpr;
    });
    it('should update dpr when creating an image tag using $.cloudinary.image()', function() {
      var result;
      result = cl.image('test', options);
      return expect(cloudinary.Util.getAttribute(result, 'src')).toBe(protocol + '//res.cloudinary.com/test123/image/upload/dpr_2.0/test');
    });
    describe("round_dpr", function() {
      describe("false", function() {
        return it("should not round up dpr", function() {
          var result;
          window.devicePixelRatio = 1.3;
          options.round_dpr = false;
          result = cl.image('test', options);
          return expect(cloudinary.Util.getAttribute(result, 'src')).toBe(protocol + '//res.cloudinary.com/test123/image/upload/dpr_1.3/test');
        });
      });
      return describe("true", function() {
        return it("should round up DPR values", function() {
          var result;
          options.round_dpr = true;
          result = cl.image('test', options);
          return expect(cloudinary.Util.getAttribute(result, 'src')).toBe(protocol + '//res.cloudinary.com/test123/image/upload/dpr_2.0/test');
        });
      });
    });
    if (typeof jQuery !== "undefined" && jQuery !== null) {
      return it('should update dpr when creating an image tag using $(\'<img/>\').attr(\'data-src\', \'test\').cloudinary(options)', function() {
        var result;
        result = $('<img/>').attr('data-src', 'test').cloudinary(options);
        return expect($(result).attr('src')).toEqual(protocol + '//res.cloudinary.com/test123/image/upload/dpr_2.0/test');
      });
    }
  });
  describe("placeholder_url", function () {
    it(`should generate blur placeholder image for nonexistent placeholder type`, function () {
      test_cloudinary_url(publicId, {
        placeholder: 'non_existing_type',
      }, `${protocol}//res.cloudinary.com/test123/image/upload/e_blur:2000,f_auto,q_1/${publicId}`, {});
    });
    it(`should generate blur placeholder image`, function () {
      test_cloudinary_url(publicId, {
        placeholder: 'blur',
      }, `${protocol}//res.cloudinary.com/test123/image/upload/e_blur:2000,f_auto,q_1/${publicId}`, {});
    });
    it(`should generate vectorize placeholder image`, function () {
      test_cloudinary_url(publicId, {
        placeholder: 'vectorize',
      }, `${protocol}//res.cloudinary.com/test123/image/upload/e_vectorize:3:0.1,f_svg/${publicId}`, {});
    });
    it(`should generate pixelate placeholder image`, function () {
      test_cloudinary_url(publicId, {
        placeholder: 'pixelate',
      }, `${protocol}//res.cloudinary.com/test123/image/upload/e_pixelate,f_auto,q_1/${publicId}`, {});
    });
    it(`should generate predominant-color placeholder image`, function () {
      test_cloudinary_url(publicId, {
        placeholder: 'predominant-color',
      }, `${protocol}//res.cloudinary.com/test123/image/upload/$currWidth_w,$currHeight_h/ar_1,b_auto,c_pad,w_iw_div_2/c_crop,g_north_east,h_10,w_10/c_fill,h_$currHeight,w_$currWidth/f_auto,q_auto/${publicId}`, {});
    });
    it(`should generate a predominant-color-pixel placeholder image and aggregate scale transforamtion`, function () {
      test_cloudinary_url(publicId, {
          placeholder: 'predominant-color',
          width: 100,
          height: 100,
          crop: 'scale'
        },
        `${protocol}//res.cloudinary.com/test123/image/upload/c_scale,h_100,w_100/ar_1,b_auto,c_pad,w_iw_div_2/c_crop,g_north_east,h_1,w_1/f_auto,q_auto/${publicId}`, {
          width: 100,
          height: 100
        }
      );
    });
    it(`should aggregate transformation with placeholder`, function () {
      test_cloudinary_url(publicId, {
        placeholder: 'blur',
        angle: 0,
        width: 300,
        crop: 'scale'
      }, `${protocol}//res.cloudinary.com/test123/image/upload/a_0,c_scale,w_300/e_blur:2000,f_auto,q_1/${publicId}`, {});
    });
    it(`should aggregate Transformation with placeholder`, function () {
      test_cloudinary_url(publicId, {
        placeholder: 'blur',
        transformation: new cloudinary.Transformation({transformation: [{angle: 0}, {width: 300, crop: "scale"}]})
      }, `${protocol}//res.cloudinary.com/test123/image/upload/a_0/c_scale,w_300/e_blur:2000,f_auto,q_1/${publicId}`, {});
    });
    it(`should aggregate config & transformation with placeholder`, function () {
      test_cloudinary_url(publicId, {
        placeholder: 'blur',
        transformation: new cloudinary.Transformation({transformation: [{angle: 0}, {width: 300, crop: "scale"}]}),
        secure: true
      }, `https://res.cloudinary.com/test123/image/upload/a_0/c_scale,w_300/e_blur:2000,f_auto,q_1/${publicId}`, {});
    });
  });
  describe("Accessibility", function () {
    it('should support darkmode', function () {
      return test_cloudinary_url(publicId, {
        accessibility: 'darkmode'
      }, `${protocol}//res.cloudinary.com/test123/image/upload/e_tint:75:black/${publicId}`, {});
    });
    it('should support brightmode', function () {
      return test_cloudinary_url(publicId, {
        accessibility: 'brightmode'
      }, `${protocol}//res.cloudinary.com/test123/image/upload/e_tint:50:white/${publicId}`, {});
    });
    it('should support monochrome', function () {
      return test_cloudinary_url(publicId, {
        accessibility: 'monochrome'
      }, `${protocol}//res.cloudinary.com/test123/image/upload/e_grayscale/${publicId}`, {});
    });
    it('should support colorblind', function () {
      return test_cloudinary_url(publicId, {
        accessibility: 'colorblind'
      }, `${protocol}//res.cloudinary.com/test123/image/upload/e_assist_colorblind/${publicId}`, {});
    });
  });
  describe("Auth token", function () {
    it('should support auth_token', function () {
      const authToken = 'ip=111.222.111.222~exp=1512982559~acl=%2fimage%2fauthenticated%2f%2a~hmac=b17360091889151e9c2e2a7c713a074fdd29dc4ef1cc2fb897a0764664f3c48d';
      return test_cloudinary_url(publicId, {
        auth_token: authToken
      }, `${protocol}//res.cloudinary.com/test123/image/upload/${publicId}?__cld_token__=${authToken}`, {});
    });
  });
});

//# sourceMappingURL=cloudinary-spec.js.map
