(function() {
  var cloudinary, getTag, test_cloudinary_url;

  cloudinary = {};

  getTag = function(tag) {
    var next;
    next = /<.*?>/.exec(tag);
    if (next) {
      return [tag.substr(next[0].length), next[0]];
    } else {
      return [tag, null];
    }
  };

  test_cloudinary_url = function(public_id, options, expected_url, expected_options) {
    var result;
    result = cloudinary.url(public_id, options);
    expect(new Cloudinary.Transformation(options).toHtmlAttributes()).toEqual(expected_options);
    return expect(result).toEqual(expected_url);
  };

  describe("Cloudinary.HtmlTag", function() {
    return describe("constructor", function() {
      it('should create a new tag with 3 parameters', function() {
        return expect(function() {
          return new Cloudinary.HtmlTag('div', "publicId", {});
        }).not.toThrow();
      });
      return it('should create a new tag with 2 parameters', function() {
        return expect(function() {
          return new Cloudinary.HtmlTag('div', {});
        }).not.toThrow();
      });
    });
  });

  describe("Cloudinary.ImageTag", function() {
    var DEFAULT_UPLOAD_PATH, options;
    DEFAULT_UPLOAD_PATH = window.location.protocol + "//res.cloudinary.com/test123/image/upload/";
    options = {
      'cloud_name': 'test123'
    };
    return it("should create an image tag", function() {
      var tag;
      tag = new Cloudinary.ImageTag('image_id', options).toHtml();
      return expect(tag).toBe("<img src=\"" + DEFAULT_UPLOAD_PATH + "image_id\">");
    });
  });

  describe("Cloudinary.VideoTag", function() {
    var DEFAULT_UPLOAD_PATH, VIDEO_UPLOAD_PATH, config, options, root_path, upload_path;
    VIDEO_UPLOAD_PATH = window.location.protocol + "//res.cloudinary.com/test123/video/upload/";
    DEFAULT_UPLOAD_PATH = window.location.protocol + "//res.cloudinary.com/test123/image/upload/";
    config = {
      cloud_name: "test123",
      secure_distribution: null,
      private_cdn: false,
      secure: false,
      cname: null,
      cdn_subdomain: false,
      api_key: "1234",
      api_secret: "b"
    };
    options = {};
    beforeEach(function() {
      cloudinary = new Cloudinary(config);
      return options = _.clone(config);
    });
    root_path = window.location.protocol + "//res.cloudinary.com/test123";
    upload_path = root_path + "/video/upload";
    describe("constructor", function() {
      var v;
      v = new Cloudinary.VideoTag("pubid");
      return it('should create a new Cloudinary.VideoTag object', function() {
        return expect(v.constructor.name).toBe("VideoTag");
      });
    });
    it("should generate video tag", function() {
      var expected_url, ref, ref1, ref2, ref3, tag, videoTag;
      expected_url = VIDEO_UPLOAD_PATH + "movie";
      videoTag = new Cloudinary.VideoTag("movie", options).toHtml();
      ref = getTag(videoTag), videoTag = ref[0], tag = ref[1];
      expect(tag).toBe("<video poster=\"" + expected_url + ".jpg\">");
      ref1 = getTag(videoTag), videoTag = ref1[0], tag = ref1[1];
      expect(tag).toBe("<source src=\"" + expected_url + ".webm\" type=\"video/webm\">");
      ref2 = getTag(videoTag), videoTag = ref2[0], tag = ref2[1];
      expect(tag).toBe("<source src=\"" + expected_url + ".mp4\" type=\"video/mp4\">");
      ref3 = getTag(videoTag), videoTag = ref3[0], tag = ref3[1];
      return expect(tag).toBe("<source src=\"" + expected_url + ".ogv\" type=\"video/ogg\">");
    });
    it("should generate video tag with html5 attributes", function() {
      var expected_url, ref, ref1, ref2, ref3, tag, videoTag;
      expected_url = VIDEO_UPLOAD_PATH + "movie";
      videoTag = new Cloudinary.VideoTag("movie", _.assign({
        autoplay: 1,
        controls: true,
        loop: true,
        muted: "true",
        preload: true,
        style: "border: 1px"
      }, options)).toHtml();
      ref = getTag(videoTag), videoTag = ref[0], tag = ref[1];
      expect(tag).toBe("<video autoplay=\"1\" controls loop muted=\"true\" poster=\"" + expected_url + ".jpg\" preload style=\"border: 1px\">");
      ref1 = getTag(videoTag), videoTag = ref1[0], tag = ref1[1];
      expect(tag).toBe("<source src=\"" + expected_url + ".webm\" type=\"video/webm\">");
      ref2 = getTag(videoTag), videoTag = ref2[0], tag = ref2[1];
      expect(tag).toBe("<source src=\"" + expected_url + ".mp4\" type=\"video/mp4\">");
      ref3 = getTag(videoTag), videoTag = ref3[0], tag = ref3[1];
      return expect(tag).toBe("<source src=\"" + expected_url + ".ogv\" type=\"video/ogg\">");
    });
    it("should generate video tag with various attributes", function() {
      var expected_url, options2, tag;
      options2 = _.assign(options, {
        source_types: "mp4",
        html_height: "100",
        html_width: "200",
        video_codec: {
          codec: "h264"
        },
        audio_codec: "acc",
        start_offset: 3
      });
      expected_url = VIDEO_UPLOAD_PATH + "ac_acc,so_3,vc_h264/movie";
      expect(new Cloudinary.VideoTag("movie", options2).toHtml()).toEqual("<video height=\"100\" poster=\"" + expected_url + ".jpg\" src=\"" + expected_url + ".mp4\" width=\"200\"></video>");
      delete options2['source_types'];
      tag = new Cloudinary.VideoTag("movie", options2).toHtml();
      expect(tag).toContain("<video height=\"100\" poster=\"" + expected_url + ".jpg\" width=\"200\">");
      expect(tag).toContain("<source src=\"" + expected_url + ".webm\" type=\"video/webm\">");
      expect(tag).toContain("<source src=\"" + expected_url + ".mp4\" type=\"video/mp4\">");
      expect(tag).toContain("<source src=\"" + expected_url + ".ogv\" type=\"video/ogg\">");
      delete options2['html_height'];
      delete options2['html_width'];
      options2['width'] = 250;
      options2['crop'] = 'scale';
      expected_url = VIDEO_UPLOAD_PATH + "ac_acc,c_scale,so_3,vc_h264,w_250/movie";
      expect(new Cloudinary.VideoTag("movie", options2).toHtml()).toEqual(("<video poster=\"" + expected_url + ".jpg\" width=\"250\">") + ("<source src=\"" + expected_url + ".webm\" type=\"video/webm\">") + ("<source src=\"" + expected_url + ".mp4\" type=\"video/mp4\">") + ("<source src=\"" + expected_url + ".ogv\" type=\"video/ogg\">") + "</video>");
      expected_url = VIDEO_UPLOAD_PATH + "ac_acc,c_fit,so_3,vc_h264,w_250/movie";
      options2['crop'] = 'fit';
      return expect(new Cloudinary.VideoTag("movie", options2).toHtml()).toEqual(("<video poster=\"" + expected_url + ".jpg\">") + ("<source src=\"" + expected_url + ".webm\" type=\"video/webm\">") + ("<source src=\"" + expected_url + ".mp4\" type=\"video/mp4\">") + ("<source src=\"" + expected_url + ".ogv\" type=\"video/ogg\">") + "</video>");
    });
    it("should generate video tag with fallback", function() {
      var expected_url, fallback;
      expected_url = VIDEO_UPLOAD_PATH + "movie";
      fallback = "<span id=\"spanid\">Cannot display video</span>";
      expect(new Cloudinary.VideoTag("movie", _.defaults({
        fallback_content: fallback
      }, options)).toHtml()).toBe(("<video poster=\"" + expected_url + ".jpg\">") + ("<source src=\"" + expected_url + ".webm\" type=\"video/webm\">") + ("<source src=\"" + expected_url + ".mp4\" type=\"video/mp4\">") + ("<source src=\"" + expected_url + ".ogv\" type=\"video/ogg\">") + fallback + "</video>");
      return expect(new Cloudinary.VideoTag("movie", _.defaults({
        fallback_content: fallback,
        source_types: "mp4"
      }, options)).toHtml()).toEqual(("<video poster=\"" + expected_url + ".jpg\" src=\"" + expected_url + ".mp4\">") + fallback + "</video>");
    });
    it("should generate video tag with source types", function() {
      var expected_url;
      expected_url = VIDEO_UPLOAD_PATH + "movie";
      return expect(cloudinary.video("movie", {
        source_types: ['ogv', 'mp4']
      })).toEqual(("<video poster=\"" + expected_url + ".jpg\">") + ("<source src=\"" + expected_url + ".ogv\" type=\"video/ogg\">") + ("<source src=\"" + expected_url + ".mp4\" type=\"video/mp4\">") + "</video>");
    });
    it("should generate video tag with source transformation", function() {
      var expected_mp4_url, expected_ogv_url, expected_url;
      expected_url = VIDEO_UPLOAD_PATH + "q_50/c_scale,w_100/movie";
      expected_ogv_url = VIDEO_UPLOAD_PATH + "q_50/c_scale,q_70,w_100/movie";
      expected_mp4_url = VIDEO_UPLOAD_PATH + "q_50/c_scale,q_30,w_100/movie";
      expect(cloudinary.video("movie", {
        width: 100,
        crop: "scale",
        transformation: {
          'quality': 50
        },
        source_transformation: {
          'ogv': {
            'quality': 70
          },
          'mp4': {
            'quality': 30
          }
        }
      })).toEqual(("<video poster=\"" + expected_url + ".jpg\" width=\"100\">") + ("<source src=\"" + expected_url + ".webm\" type=\"video/webm\">") + ("<source src=\"" + expected_mp4_url + ".mp4\" type=\"video/mp4\">") + ("<source src=\"" + expected_ogv_url + ".ogv\" type=\"video/ogg\">") + "</video>");
      return expect(cloudinary.video("movie", {
        width: 100,
        crop: "scale",
        transformation: {
          'quality': 50
        },
        source_transformation: {
          'ogv': {
            'quality': 70
          },
          'mp4': {
            'quality': 30
          }
        },
        source_types: ['webm', 'mp4']
      })).toEqual(("<video poster=\"" + expected_url + ".jpg\" width=\"100\">") + ("<source src=\"" + expected_url + ".webm\" type=\"video/webm\">") + ("<source src=\"" + expected_mp4_url + ".mp4\" type=\"video/mp4\">") + "</video>");
    });
    it("should generate video tag with configurable poster", function() {
      var expected_poster_url, expected_url;
      expected_url = VIDEO_UPLOAD_PATH + "movie";
      expected_poster_url = 'http://image/somewhere.jpg';
      expect(cloudinary.video("movie", {
        poster: expected_poster_url,
        source_types: "mp4"
      })).toEqual("<video poster=\"" + expected_poster_url + "\" src=\"" + expected_url + ".mp4\"></video>");
      expected_poster_url = VIDEO_UPLOAD_PATH + "g_north/movie.jpg";
      expect(cloudinary.video("movie", {
        poster: {
          'gravity': 'north'
        },
        source_types: "mp4"
      })).toEqual("<video poster=\"" + expected_poster_url + "\" src=\"" + expected_url + ".mp4\"></video>");
      expected_poster_url = DEFAULT_UPLOAD_PATH + "g_north/my_poster.jpg";
      expect(cloudinary.video("movie", {
        poster: {
          'gravity': 'north',
          'public_id': 'my_poster',
          'format': 'jpg'
        },
        source_types: "mp4"
      })).toEqual("<video poster=\"" + expected_poster_url + "\" src=\"" + expected_url + ".mp4\"></video>");
      expect(cloudinary.video("movie", {
        poster: "",
        source_types: "mp4"
      })).toEqual("<video src=\"" + expected_url + ".mp4\"></video>");
      return expect(cloudinary.video("movie", {
        poster: false,
        source_types: "mp4"
      })).toEqual("<video src=\"" + expected_url + ".mp4\"></video>");
    });
    return describe("attributes", function() {
      var tag;
      tag = Cloudinary.HtmlTag["new"]("div", {
        id: "foobar"
      });
      return describe("removeAttr()", function() {
        tag.removeAttr("id");
        return it("should remove that attribute from the tag", function() {
          return expect(_.keys(tag.attributes())).not.toContain("id");
        });
      });
    });
  });

}).call(this);
