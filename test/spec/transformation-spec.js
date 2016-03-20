describe("Transformation", function() {
  var cl, fixtureContainer, layer, layers, protocol, test_cloudinary_url;
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
  describe("width and height", function() {
    it('should use width and height from options only if crop is given', function() {
      expect(cl.url('test', {
        width: 100,
        height: 100
      })).toBe(protocol + '//res.cloudinary.com/test123/image/upload/test');
      expect(cl.url('test', {
        width: 100,
        height: 100,
        crop: 'crop'
      })).toBe(protocol + '//res.cloudinary.com/test123/image/upload/c_crop,h_100,w_100/test');
      return expect(cl.url('test', cloudinary.Transformation["new"]().width(100).height(100).crop('crop'))).toBe(protocol + '//res.cloudinary.com/test123/image/upload/c_crop,h_100,w_100/test');
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
      test_cloudinary_url('test', {
        width: 100,
        height: 100,
        crop: 'fit'
      }, protocol + '//res.cloudinary.com/test123/image/upload/c_fit,h_100,w_100/test', {});
      return test_cloudinary_url('test', cloudinary.Transformation["new"]().width(100).height(100).crop('fit'), protocol + '//res.cloudinary.com/test123/image/upload/c_fit,h_100,w_100/test', {});
    });
    return it('should not pass width and height to html in case angle was used', function() {
      return test_cloudinary_url('test', {
        width: 100,
        height: 100,
        crop: 'scale',
        angle: 'auto'
      }, protocol + '//res.cloudinary.com/test123/image/upload/a_auto,c_scale,h_100,w_100/test', {});
    });
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
      return expect(cloudinary.Util.getAttribute(result, 'src')).toBe(protocol + '//res.cloudinary.com/test123/image/upload/dpr_2.0/test');
    });
  });
  return describe('Conditional Transformation', function() {
    beforeEach(function() {
      return this.cl = cloudinary.Cloudinary["new"]({
        cloud_name: "sdk-test"
      });
    });
    afterEach(function() {});
    describe('with literal condition string', function() {
      it("should include the if parameter as the first component in the transformation string", function() {
        var url;
        url = this.cl.url("sample", {
          "if": "w_lt_200",
          crop: "fill",
          height: 120,
          width: 80
        });
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_lt_200,c_fill,h_120,w_80/sample");
        url = this.cl.url("sample", {
          crop: "fill",
          height: 120,
          "if": "w_lt_200",
          width: 80
        });
        return expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_lt_200,c_fill,h_120,w_80/sample");
      });
      it("should allow multiple conditions when chaining transformations ", function() {
        var url;
        url = this.cl.url("sample", {
          transformation: [
            {
              "if": "w_lt_200",
              crop: "fill",
              height: 120,
              width: 80
            }, {
              "if": "w_gt_400",
              crop: "fit",
              width: 150,
              height: 150
            }, {
              effect: "sepia"
            }
          ]
        });
        return expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_lt_200,c_fill,h_120,w_80/if_w_gt_400,c_fit,h_150,w_150/e_sepia/sample");
      });
      return describe("including spaces and operators", function() {
        return it("should translate operators", function() {
          var url;
          url = this.cl.url("sample", {
            "if": "w < 200",
            crop: "fill",
            height: 120,
            width: 80
          });
          return expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_lt_200,c_fill,h_120,w_80/sample");
        });
      });
    });
    describe('if end', function() {
      it("should include the if_end as the last parameter in its component", function() {
        var url;
        url = this.cl.url("sample", {
          transformation: [
            {
              "if": "w_lt_200"
            }, {
              crop: "fill",
              height: 120,
              width: 80,
              effect: "sharpen"
            }, {
              effect: "brightness:50"
            }, {
              effect: "shadow",
              color: "red"
            }, {
              "if": "end"
            }
          ]
        });
        return expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_lt_200/c_fill,e_sharpen,h_120,w_80/e_brightness:50/co_red,e_shadow/if_end/sample");
      });
      it("should support if_else with transformation parameters", function() {
        var url;
        url = this.cl.url("sample", {
          transformation: [
            {
              "if": "w_lt_200",
              crop: "fill",
              height: 120,
              width: 80
            }, {
              "if": "else",
              crop: "fill",
              height: 90,
              width: 100
            }
          ]
        });
        return expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_lt_200,c_fill,h_120,w_80/if_else,c_fill,h_90,w_100/sample");
      });
      return it("if_else should be without any transformation parameters", function() {
        var url;
        url = this.cl.url("sample", {
          transformation: [
            {
              "if": "aspect_ratio_lt_0.7"
            }, {
              crop: "fill",
              height: 120,
              width: 80
            }, {
              "if": "else"
            }, {
              crop: "fill",
              height: 90,
              width: 100
            }
          ]
        });
        return expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_lt_0.7/c_fill,h_120,w_80/if_else/c_fill,h_90,w_100/sample");
      });
    });
    describe('Chaining with literal conditions', function() {
      return it("should add an if parameter", function() {
        var url;
        url = this.cl.url("sample", cloudinary.Transformation["new"]()["if"]("ar_gt_3:4").width(100).crop("scale"));
        return expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_gt_3:4,c_scale,w_100/sample");
      });
    });
    return describe('chaining conditions', function() {
      it("should passing an operator and a value adds a condition", function() {
        var url;
        url = this.cl.url("sample", cloudinary.Transformation["new"]()["if"]().aspectRatio("gt", "3:4").then().width(100).crop("scale"));
        return expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_gt_3:4,c_scale,w_100/sample");
      });
      it("should chaining condition with `and`", function() {
        var url;
        url = this.cl.url("sample", cloudinary.Transformation["new"]()["if"]().aspectRatio("gt", "3:4").and().width("gt", 100).then().width(50).crop("scale"));
        return expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_gt_3:4_and_w_gt_100,c_scale,w_50/sample");
      });
      it("should chain conditions with `or`", function() {
        var url;
        url = this.cl.url("sample", cloudinary.Transformation["new"]()["if"]().aspectRatio("gt", "3:4").and().width("gt", 100).or().width("gt", 200).then().width(50).crop("scale"));
        return expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_gt_3:4_and_w_gt_100_or_w_gt_200,c_scale,w_50/sample");
      });
      it("should translate operators", function() {
        var url;
        url = this.cl.url("sample", cloudinary.Transformation["new"]()["if"]().aspectRatio(">", "3:4").and().width("<=", 100).or().width("gt", 200).then().width(50).crop("scale"));
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_gt_3:4_and_w_lte_100_or_w_gt_200,c_scale,w_50/sample");
        url = this.cl.url("sample", cloudinary.Transformation["new"]()["if"]().aspectRatio(">", "3:4").and().width("<=", 100).or().width(">", 200).then().width(50).crop("scale"));
        expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_gt_3:4_and_w_lte_100_or_w_gt_200,c_scale,w_50/sample");
        url = this.cl.url("sample", cloudinary.Transformation["new"]()["if"]().aspectRatio(">=", "3:4").and().pages(">=", 100).or().pages("!=", 0).then().width(50).crop("scale"));
        return expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_ar_gte_3:4_and_pg_gte_100_or_pg_ne_0,c_scale,w_50/sample");
      });
      it("should support and translate operators:  '=', '!=', '<', '>', '<=', '>=', '&&', '||'", function() {
        var allOperators;
        allOperators = 'if_' + 'w_eq_0_and' + '_w_ne_0_or' + '_w_lt_0_and' + '_w_gt_0_and' + '_w_lte_0_and' + '_w_gte_0' + ',e_grayscale';
        expect(cloudinary.Transformation["new"]()["if"]().width("=", 0).and().width("!=", 0).or().width("<", 0).and().width(">", 0).and().width("<=", 0).and().width(">=", 0).then().effect("grayscale").serialize()).toEqual(allOperators);
        return expect(cloudinary.Transformation["new"]()["if"]("width = 0 && w != 0 || w < 0 and w > 0 and w <= 0 and w >= 0").effect("grayscale").serialize()).toEqual(allOperators);
      });
      return describe('endIf()', function() {
        it("should serialize to 'if_end'", function() {
          var url;
          url = this.cl.url("sample", cloudinary.Transformation["new"]()["if"]().width("gt", 100).and().width("lt", 200).then().width(50).crop("scale").endIf());
          return expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_gt_100_and_w_lt_200/c_scale,w_50/if_end/sample");
        });
        it("force the if clause to be chained", function() {
          var url;
          url = this.cl.url("sample", cloudinary.Transformation["new"]()["if"]().width("gt", 100).and().width("lt", 200).then().width(50).crop("scale").endIf());
          return expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_gt_100_and_w_lt_200/c_scale,w_50/if_end/sample");
        });
        return it("force the if_else clause to be chained", function() {
          var url;
          url = this.cl.url("sample", cloudinary.Transformation["new"]()["if"]().width("gt", 100).and().width("lt", 200).then().width(50).crop("scale")["else"]().width(100).crop("crop").endIf());
          return expect(url).toEqual("http://res.cloudinary.com/sdk-test/image/upload/if_w_gt_100_and_w_lt_200/c_scale,w_50/if_else/c_crop,w_100/if_end/sample");
        });
      });
    });
  });
});

//# sourceMappingURL=transformation-spec.js.map
