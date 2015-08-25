(function() {
  describe("Chaining", function() {
    var DEFAULT_UPLOAD_PATH, VIDEO_UPLOAD_PATH, config, options;
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
      return options = _.clone(config);
    });
    describe("Cloudinary.transformation", function() {
      var cl, t;
      cl = Cloudinary["new"]();
      t = cl.transformation();
      it("should return a transformation object", function() {
        return expect(t.constructor.name).toBe("Transformation");
      });
      return it("should return the calling object with getParent()", function() {
        return expect(t.getParent()).toBe(cl);
      });
    });
    return describe("Cloudinary.ImageTag", function() {
      return it("should generate video tag with various attributes", function() {
        var expected_url, tag;
        expected_url = VIDEO_UPLOAD_PATH + "ac_acc,so_3,vc_h264/movie";
        tag = new Cloudinary(options).videoTag("movie").setSourceTypes('mp4').transformation().htmlHeight("100").htmlWidth("200").videoCodec({
          codec: "h264"
        }).audioCodec("acc").startOffset(3).toHtml();
        return expect(tag).toEqual("<video height=\"100\" poster=\"" + expected_url + ".jpg\" src=\"" + expected_url + ".mp4\" width=\"200\"></video>");
      });
    });
  });

}).call(this);
