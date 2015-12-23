(function() {
  describe('cloudinary', function() {
    var cl, fixtureContainer, layer, layers, protocol, test_cloudinary_url;
    cl = {};
    protocol = window.location.protocol === "file:" ? "http:" : window.location.protocol;
    fixtureContainer = void 0;
    test_cloudinary_url = function(public_id, options, expected_url, expected_options) {
      var result;
      result = cl.url(public_id, options);
      expect(new cloudinary.Transformation(options).toHtmlAttributes()).toEqual(expected_options);
      return expect(result).toEqual(expected_url);
    };
    beforeEach(function() {
      cl = new cloudinary.Cloudinary({
        cloud_name: 'test123'
      });
      fixtureContainer = document.createElement('div');
      fixtureContainer.id = "fixture";
      return document.body.appendChild(fixtureContainer);
    });
    afterEach(function() {
      return fixtureContainer.remove();
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
    it('should ignore empty values', function() {
      expect(cl.url('test', {
        width: void 0,
        crop: 'crop',
        flags: void 0,
        startOffset: void 0,
        transformation: void 0
      })).toBe(protocol + '//res.cloudinary.com/test123/image/upload/c_crop/test');
      expect(cl.url('test', {
        width: '',
        crop: 'crop',
        flags: [],
        startOffset: [],
        transformation: []
      })).toBe(protocol + '//res.cloudinary.com/test123/image/upload/c_crop/test');
      expect(cl.url('test', {
        width: '',
        crop: 'crop',
        flags: [],
        startOffset: '',
        transformation: ''
      })).toBe(protocol + '//res.cloudinary.com/test123/image/upload/c_crop/test');
      return expect(cl.url('test', {
        transformation: {}
      })).toBe(protocol + '//res.cloudinary.com/test123/image/upload/test');
    });
    it('should use width and height from options only if crop is given', function() {
      expect(cl.url('test', {
        width: 100,
        height: 100
      })).toBe(protocol + '//res.cloudinary.com/test123/image/upload/test');
      return expect(cl.url('test', {
        width: 100,
        height: 100,
        crop: 'crop'
      })).toBe(protocol + '//res.cloudinary.com/test123/image/upload/c_crop,h_100,w_100/test');
    });
    it('should not pass width and height to html in case of fit, lfill or limit crop', function() {
      test_cloudinary_url('test', {
        width: 100,
        height: 100,
        crop: 'limit'
      }, protocol + '//res.cloudinary.com/test123/image/upload/c_limit,h_100,w_100/test', {});
      test_cloudinary_url('test', {
        width: 100,
        height: 100,
        crop: 'lfill'
      }, protocol + '//res.cloudinary.com/test123/image/upload/c_lfill,h_100,w_100/test', {});
      return test_cloudinary_url('test', {
        width: 100,
        height: 100,
        crop: 'fit'
      }, protocol + '//res.cloudinary.com/test123/image/upload/c_fit,h_100,w_100/test', {});
    });
    it('should not pass width and height to html in case angle was used', function() {
      return test_cloudinary_url('test', {
        width: 100,
        height: 100,
        crop: 'scale',
        angle: 'auto'
      }, protocol + '//res.cloudinary.com/test123/image/upload/a_auto,c_scale,h_100,w_100/test', {});
    });
    it('should support aspect_ratio', function() {
      test_cloudinary_url('test', {
        aspect_ratio: '1.0'
      }, protocol + '//res.cloudinary.com/test123/image/upload/ar_1.0/test', {});
      return test_cloudinary_url('test', {
        aspect_ratio: '3:2'
      }, protocol + '//res.cloudinary.com/test123/image/upload/ar_3:2/test', {});
    });
    it('should use x, y, radius, prefix, gravity and quality from options', function() {
      return test_cloudinary_url('test', {
        x: 1,
        y: 2,
        radius: 3,
        gravity: 'center',
        quality: 0.4,
        prefix: 'a'
      }, protocol + '//res.cloudinary.com/test123/image/upload/g_center,p_a,q_0.4,r_3,x_1,y_2/test', {});
    });
    it('should support named tranformation', function() {
      return test_cloudinary_url('test', {
        transformation: 'blip'
      }, protocol + '//res.cloudinary.com/test123/image/upload/t_blip/test', {});
    });
    it('should support array of named tranformations', function() {
      return test_cloudinary_url('test', {
        transformation: ['blip', 'blop']
      }, protocol + '//res.cloudinary.com/test123/image/upload/t_blip.blop/test', {});
    });
    it('should support base tranformation', function() {
      return expect(cl.url('test', {
        transformation: {
          x: 100,
          y: 100,
          crop: 'fill'
        },
        crop: 'crop',
        width: 100
      })).toBe(protocol + '//res.cloudinary.com/test123/image/upload/c_fill,x_100,y_100/c_crop,w_100/test');
    });
    it('should support array of base tranformations', function() {
      return expect(cl.url('test', {
        transformation: [
          {
            x: 100,
            y: 100,
            width: 200,
            crop: 'fill'
          }, {
            radius: 10
          }
        ],
        crop: 'crop',
        width: 100
      })).toBe(protocol + '//res.cloudinary.com/test123/image/upload/c_fill,w_200,x_100,y_100/r_10/c_crop,w_100/test');
    });
    it('should not include empty tranformations', function() {
      return expect(cl.url('test', {
        transformation: [
          {}, {
            x: 100,
            y: 100,
            crop: 'fill'
          }, {}
        ]
      })).toBe(protocol + '//res.cloudinary.com/test123/image/upload/c_fill,x_100,y_100/test');
    });
    it('should support size', function() {
      return test_cloudinary_url('test', {
        size: '10x10',
        crop: 'crop'
      }, protocol + '//res.cloudinary.com/test123/image/upload/c_crop,h_10,w_10/test', {
        width: '10',
        height: '10'
      });
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
    it('should support background', function() {
      test_cloudinary_url('test', {
        background: 'red'
      }, protocol + '//res.cloudinary.com/test123/image/upload/b_red/test', {});
      return test_cloudinary_url('test', {
        background: '#112233'
      }, protocol + '//res.cloudinary.com/test123/image/upload/b_rgb:112233/test', {});
    });
    it('should support default_image', function() {
      return test_cloudinary_url('test', {
        default_image: 'default'
      }, protocol + '//res.cloudinary.com/test123/image/upload/d_default/test', {});
    });
    it('should support angle', function() {
      return test_cloudinary_url('test', {
        angle: 12
      }, protocol + '//res.cloudinary.com/test123/image/upload/a_12/test', {});
    });
    it('should support format for fetch urls', function() {
      return test_cloudinary_url('http://cloudinary.com/images/logo.png', {
        type: 'fetch',
        format: 'jpg'
      }, protocol + '//res.cloudinary.com/test123/image/fetch/f_jpg/http://cloudinary.com/images/logo.png', {});
    });
    it('should support extenal cname', function() {
      return test_cloudinary_url('test', {
        cname: 'hello.com'
      }, protocol + '//hello.com/test123/image/upload/test', {});
    });
    it('should support extenal cname with cdn_subdomain on', function() {
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
    it('should support effect', function() {
      return test_cloudinary_url('test', {
        effect: 'sepia'
      }, protocol + '//res.cloudinary.com/test123/image/upload/e_sepia/test', {});
    });
    it('should support effect with param', function() {
      return test_cloudinary_url('test', {
        effect: ['sepia', 10]
      }, protocol + '//res.cloudinary.com/test123/image/upload/e_sepia:10/test', {});
    });
    it('should support fetch_image', function() {
      var result;
      result = cl.fetch_image('http://example.com/hello.jpg?a=b').getAttribute('src');
      return expect(result).toEqual(protocol + '//res.cloudinary.com/test123/image/fetch/http://example.com/hello.jpg%3Fa%3Db');
    });
    layers = {
      overlay: 'l',
      underlay: 'u'
    };
    for (layer in layers) {
      it('should support ' + layer, function() {
        var options;
        options = {};
        options[layer] = 'text:hello';
        return test_cloudinary_url('test', options, protocol + '//res.cloudinary.com/test123/image/upload/' + layers[layer] + '_text:hello/test', {});
      });
      it('should not pass width/height to html for ' + layer, function() {
        var options;
        options = {
          height: 100,
          width: 100
        };
        options[layer] = 'text:hello';
        return test_cloudinary_url('test', options, protocol + '//res.cloudinary.com/test123/image/upload/h_100,' + layers[layer] + '_text:hello,w_100/test', {});
      });
    }
    it('should support density', function() {
      return test_cloudinary_url('test', {
        density: 150
      }, protocol + '//res.cloudinary.com/test123/image/upload/dn_150/test', {});
    });
    it('should support page', function() {
      return test_cloudinary_url('test', {
        page: 5
      }, protocol + '//res.cloudinary.com/test123/image/upload/pg_5/test', {});
    });
    it('should support border', function() {
      test_cloudinary_url('test', {
        border: {
          width: 5
        }
      }, protocol + '//res.cloudinary.com/test123/image/upload/bo_5px_solid_black/test', {});
      test_cloudinary_url('test', {
        border: {
          width: 5,
          color: '#ffaabbdd'
        }
      }, protocol + '//res.cloudinary.com/test123/image/upload/bo_5px_solid_rgb:ffaabbdd/test', {});
      return test_cloudinary_url('test', {
        border: '1px_solid_blue'
      }, protocol + '//res.cloudinary.com/test123/image/upload/bo_1px_solid_blue/test', {});
    });
    it('should support flags', function() {
      test_cloudinary_url('test', {
        flags: 'abc'
      }, protocol + '//res.cloudinary.com/test123/image/upload/fl_abc/test', {});
      return test_cloudinary_url('test', {
        flags: ['abc', 'def']
      }, protocol + '//res.cloudinary.com/test123/image/upload/fl_abc.def/test', {});
    });
    it('should support opacity', function() {
      return test_cloudinary_url('test', {
        opacity: 30
      }, protocol + '//res.cloudinary.com/test123/image/upload/o_30/test', {});
    });
    it('should support dpr', function() {
      test_cloudinary_url('test', {
        dpr: 1
      }, protocol + '//res.cloudinary.com/test123/image/upload/dpr_1.0/test', {});
      test_cloudinary_url('test', {
        dpr: 'auto'
      }, protocol + '//res.cloudinary.com/test123/image/upload/dpr_1.0/test', {});
      return test_cloudinary_url('test', {
        dpr: 1.5
      }, protocol + '//res.cloudinary.com/test123/image/upload/dpr_1.5/test', {});
    });
    describe('zoom', function() {
      return it('should support a decimal value', function() {
        return test_cloudinary_url('test', {
          zoom: 1.2
        }, protocol + '//res.cloudinary.com/test123/image/upload/z_1.2/test', {});
      });
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
      return it('should update dpr when creating an image tag using $.cloudinary.image()', function() {
        var result;
        result = cl.image('test', options);
        return expect(result.getAttribute('src')).toBe(protocol + '//res.cloudinary.com/test123/image/upload/dpr_2.0/test');
      });
    });
    it('should add version if public_id contains /', function() {
      test_cloudinary_url('folder/test', {}, protocol + '//res.cloudinary.com/test123/image/upload/v1/folder/test', {});
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
    it('should disallow url_suffix in shared distribution', function() {
      return expect(function() {
        return cl.url('test', {
          url_suffix: 'hello',
          private_cdn: false
        });
      }).toThrow();
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
    it('should allow to override protocol', function() {
      var options, result;
      options = {
        'protocol': 'custom:'
      };
      result = cl.url('test', options);
      return expect(result).toEqual('custom://res.cloudinary.com/test123/image/upload/test');
    });
    return it('should not fail on falsy public_id', function() {
      expect(cl.url(null)).toEqual(null);
      return expect(cl.url(void 0)).toEqual(void 0);
    });
  });

}).call(this);
