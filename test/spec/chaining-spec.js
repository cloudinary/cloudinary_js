var protocol, simpleAssign, simpleClone;

simpleAssign = function(dest, source) {
  var key, value;
  for (key in source) {
    value = source[key];
    dest[key] = value;
  }
  return dest;
};

simpleClone = function(source) {
  return simpleAssign({}, source);
};

protocol = window.location.protocol === "file:" ? "http:" : window.location.protocol;

describe("Chaining", function() {
  var DEFAULT_UPLOAD_PATH, VIDEO_UPLOAD_PATH, config, options;
  VIDEO_UPLOAD_PATH = protocol + "//res.cloudinary.com/test123/video/upload/";
  DEFAULT_UPLOAD_PATH = protocol + "//res.cloudinary.com/test123/image/upload/";
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
    return options = simpleClone(config);
  });
  describe("Cloudinary.transformation", function() {
    var cl, t;
    cl = cloudinary.Cloudinary["new"]();
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
      tag = new cloudinary.Cloudinary(options).videoTag("movie").setSourceTypes('mp4').transformation().htmlHeight("100").htmlWidth("200").videoCodec({
        codec: "h264"
      }).audioCodec("acc").startOffset(3).toHtml();
      return expect(tag).toEqual("<video height=\"100\" poster=\"" + expected_url + ".jpg\" src=\"" + expected_url + ".mp4\" width=\"200\"></video>");
    });
  });
});

//# sourceMappingURL=chaining-spec.js.map
