simpleAssign = (dest, source)->
  dest[key]= value for key, value of source
  dest

simpleClone = (source)->
  simpleAssign({}, source)

protocol = if window.location.protocol == "file:" then "http:" else window.location.protocol

describe "Chaining", () ->
  VIDEO_UPLOAD_PATH = "#{protocol}//res.cloudinary.com/test123/video/upload/"
  DEFAULT_UPLOAD_PATH = "#{protocol}//res.cloudinary.com/test123/image/upload/"
  config =
    cloud_name: "test123"
    secure_distribution: null
    private_cdn: false
    secure: false
    cname: null
    cdn_subdomain: false
    api_key: "1234"
    api_secret: "b"
  options = {}
  beforeEach ->
    options = simpleClone(config)

  describe "Cloudinary.transformation", () ->
    cl = cloudinary.Cloudinary.new();
    t= cl.transformation()
    it "should return a transformation object", () ->
      expect(t.constructor.name).toBe( "Transformation")
    it "should return the calling object with getParent()", ()->
      expect(t.getParent()).toBe(cl)
  describe "Cloudinary.ImageTag", ()->
    it "should generate video tag with various attributes", ->
      expected_url = VIDEO_UPLOAD_PATH + "ac_acc,so_3,vc_h264/movie"
      tag = new cloudinary.Cloudinary(options).videoTag("movie").setSourceTypes('mp4')
             .transformation()
             .htmlHeight("100")
             .htmlWidth("200")
             .videoCodec({codec: "h264"})
             .audioCodec("acc")
             .startOffset(3)
             .toHtml()
      expect(tag).toEqual(
         "<video height=\"100\" poster=\"#{expected_url}.jpg\" src=\"#{expected_url}.mp4\" width=\"200\"></video>")
