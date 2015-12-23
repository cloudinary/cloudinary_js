cl = {}

getTag = (tag)->
  next = /<.*?>/.exec(tag)
  if next
    [tag.substr(next[0].length), next[0]]
  else
    [tag, null]
protocol = if window.location.protocol == "file:" then "http:" else window.location.protocol
simpleAssign = (dest, source)->
  dest[key]= value for key, value of source
  dest

simpleClone = (source)->
  simpleAssign({}, source)

test_cloudinary_url = (public_id, options, expected_url, expected_options) ->
  result = cl.url(public_id, options)
  expect(new cloudinary.Transformation(options).toHtmlAttributes()).toEqual(expected_options)
  expect(result).toEqual(expected_url)

describe "Cloudinary.HtmlTag", ->
  describe "constructor", ->
    it 'should create a new tag with 3 parameters', ->
      expect( -> new cloudinary.HtmlTag( 'div', "publicId", {})).not.toThrow()
    it 'should create a new tag with 2 parameters', ->
      expect( -> new cloudinary.HtmlTag( 'div', {})).not.toThrow()
describe "Cloudinary.ImageTag", ->
  DEFAULT_UPLOAD_PATH = "#{protocol}//res.cloudinary.com/test123/image/upload/"
  options =
    'cloud_name': 'test123'
  it "should create an image tag", ()->
    tag = new cloudinary.ImageTag( 'image_id', options).toHtml()
    expect(tag).toBe("<img src=\"#{DEFAULT_UPLOAD_PATH}image_id\">")

describe "Cloudinary.VideoTag", ->
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
    cl = new cloudinary.Cloudinary( config)
    options = simpleClone(config)

  root_path = "#{protocol}//res.cloudinary.com/test123"
  upload_path = "#{root_path}/video/upload"

  describe "constructor", ->
    v = new cloudinary.VideoTag("pubid" )
    it 'should create a new Cloudinary.VideoTag object', ->
      expect(v.constructor.name).toBe("VideoTag")
#    it 'should support a hash value', ->
#      test_cloudinary_url("video_id", { resource_type: 'video', video_codec: { codec: 'h264', profile: 'basic', level: '3.1' } },
#                          "#{upload_path}/vc_h264:basic:3.1/video_id", {})


  it "should generate video tag", ->
    expected_url = VIDEO_UPLOAD_PATH + "movie"
    videoTag = new cloudinary.VideoTag("movie", options).toHtml()
    [videoTag, tag] = getTag(videoTag)
    expect(tag).toBe("<video poster=\"#{expected_url}.jpg\">")
    [videoTag, tag] = getTag(videoTag)
    expect(tag).toBe("<source src=\"#{expected_url}.webm\" type=\"video/webm\">")
    [videoTag, tag] = getTag(videoTag)
    expect(tag).toBe("<source src=\"#{expected_url}.mp4\" type=\"video/mp4\">")
    [videoTag, tag] = getTag(videoTag)
    expect(tag).toBe("<source src=\"#{expected_url}.ogv\" type=\"video/ogg\">")

  it "should generate video tag with html5 attributes", ->
    expected_url = VIDEO_UPLOAD_PATH + "movie"
    videoTag = new cloudinary.VideoTag("movie", simpleAssign({
                                           autoplay: 1,
                                           controls: true,
                                           loop: true,
                                           muted: "true",
                                           preload: true,
                                           style: "border: 1px"
                                         }, options)).toHtml()
    [videoTag, tag] = getTag(videoTag)
    expect(tag).toBe("<video autoplay=\"1\" controls loop muted=\"true\" poster=\"#{expected_url}.jpg\" preload style=\"border: 1px\">" )
    [videoTag, tag] = getTag(videoTag)
    expect(tag).toBe("<source src=\"#{expected_url}.webm\" type=\"video/webm\">")
    [videoTag, tag] = getTag(videoTag)
    expect(tag).toBe("<source src=\"#{expected_url}.mp4\" type=\"video/mp4\">")
    [videoTag, tag] = getTag(videoTag)
    expect(tag).toBe("<source src=\"#{expected_url}.ogv\" type=\"video/ogg\">")


  it "should generate video tag with various attributes", ->
    options2 = simpleAssign( options, {
      source_types: "mp4",
      html_height : "100",
      html_width  : "200",
      video_codec : {codec: "h264"},
      audio_codec : "acc",
      start_offset: 3
    })
    expected_url = VIDEO_UPLOAD_PATH + "ac_acc,so_3,vc_h264/movie"
    expect(new cloudinary.VideoTag("movie", options2).toHtml()).toEqual(
      "<video height=\"100\" poster=\"#{expected_url}.jpg\" src=\"#{expected_url}.mp4\" width=\"200\"></video>")

    delete options2['source_types']
    tag = new cloudinary.VideoTag("movie", options2).toHtml()
    expect(tag).toContain("<video height=\"100\" poster=\"#{expected_url}.jpg\" width=\"200\">")
    expect(tag).toContain("<source src=\"#{expected_url}.webm\" type=\"video/webm\">")
    expect(tag).toContain("<source src=\"#{expected_url}.mp4\" type=\"video/mp4\">")
    expect(tag).toContain("<source src=\"#{expected_url}.ogv\" type=\"video/ogg\">")

    delete options2['html_height']
    delete options2['html_width']
    options2['width'] = 250
    options2['crop'] = 'scale'
    expected_url = VIDEO_UPLOAD_PATH + "ac_acc,c_scale,so_3,vc_h264,w_250/movie"
    expect(new cloudinary.VideoTag("movie", options2).toHtml()).toEqual(
      "<video poster=\"#{expected_url}.jpg\" width=\"250\">" +
      "<source src=\"#{expected_url}.webm\" type=\"video/webm\">" +
      "<source src=\"#{expected_url}.mp4\" type=\"video/mp4\">" +
      "<source src=\"#{expected_url}.ogv\" type=\"video/ogg\">" +
      "</video>")

    expected_url = VIDEO_UPLOAD_PATH + "ac_acc,c_fit,so_3,vc_h264,w_250/movie"
    options2['crop'] = 'fit'
    expect(new cloudinary.VideoTag("movie", options2).toHtml()).toEqual(
      "<video poster=\"#{expected_url}.jpg\">" +
      "<source src=\"#{expected_url}.webm\" type=\"video/webm\">" +
      "<source src=\"#{expected_url}.mp4\" type=\"video/mp4\">" +
      "<source src=\"#{expected_url}.ogv\" type=\"video/ogg\">" +
      "</video>")

  it "should generate video tag with fallback", ->
    expected_url = VIDEO_UPLOAD_PATH + "movie"
    fallback = "<span id=\"spanid\">Cannot display video</span>"
    expect(new cloudinary.VideoTag("movie", simpleAssign({fallback_content: fallback}, options)).toHtml()).toBe(
      "<video poster=\"#{expected_url}.jpg\">" +
      "<source src=\"#{expected_url}.webm\" type=\"video/webm\">" +
      "<source src=\"#{expected_url}.mp4\" type=\"video/mp4\">" +
      "<source src=\"#{expected_url}.ogv\" type=\"video/ogg\">" +
      fallback +
      "</video>")
    expect(new cloudinary.VideoTag("movie", simpleAssign({fallback_content: fallback, source_types: "mp4"}, options)).toHtml()).toEqual(
      "<video poster=\"#{expected_url}.jpg\" src=\"#{expected_url}.mp4\">" +
      fallback +
      "</video>")


  it "should generate video tag with source types", ->
    expected_url = VIDEO_UPLOAD_PATH + "movie"
    expect(cl.video("movie", source_types: ['ogv', 'mp4'])).toEqual(
      "<video poster=\"#{expected_url}.jpg\">" +
      "<source src=\"#{expected_url}.ogv\" type=\"video/ogg\">" +
      "<source src=\"#{expected_url}.mp4\" type=\"video/mp4\">" +
      "</video>")

  it "should generate video tag with source transformation", ->
    expected_url = VIDEO_UPLOAD_PATH + "q_50/c_scale,w_100/movie"
    expected_ogv_url = VIDEO_UPLOAD_PATH + "q_50/c_scale,q_70,w_100/movie"
    expected_mp4_url = VIDEO_UPLOAD_PATH + "q_50/c_scale,q_30,w_100/movie"
    expect(cl.video("movie", width: 100, crop: "scale", transformation: {'quality': 50}, source_transformation: {'ogv': {'quality': 70}, 'mp4': {'quality': 30}})).toEqual(
      "<video poster=\"#{expected_url}.jpg\" width=\"100\">" +
      "<source src=\"#{expected_url}.webm\" type=\"video/webm\">" +
      "<source src=\"#{expected_mp4_url}.mp4\" type=\"video/mp4\">" +
      "<source src=\"#{expected_ogv_url}.ogv\" type=\"video/ogg\">" +
      "</video>")

    expect(cl.video("movie", width: 100, crop: "scale", transformation: {'quality': 50}, source_transformation: {'ogv': {'quality': 70}, 'mp4': {'quality': 30}}, source_types: ['webm', 'mp4'])).toEqual(
      "<video poster=\"#{expected_url}.jpg\" width=\"100\">" +
      "<source src=\"#{expected_url}.webm\" type=\"video/webm\">" +
      "<source src=\"#{expected_mp4_url}.mp4\" type=\"video/mp4\">" +
      "</video>")

  it "should generate video tag with configurable poster", ->
    expected_url = VIDEO_UPLOAD_PATH + "movie"

    expected_poster_url = 'http://image/somewhere.jpg'
    expect(cl.video("movie", poster: expected_poster_url, source_types: "mp4")).toEqual(
      "<video poster=\"#{expected_poster_url}\" src=\"#{expected_url}.mp4\"></video>")

    expected_poster_url = VIDEO_UPLOAD_PATH + "g_north/movie.jpg"
    expect(cl.video("movie", poster: {'gravity': 'north'}, source_types: "mp4")).toEqual(
      "<video poster=\"#{expected_poster_url}\" src=\"#{expected_url}.mp4\"></video>")

    expected_poster_url = DEFAULT_UPLOAD_PATH + "g_north/my_poster.jpg"
    expect(cl.video("movie", poster: {'gravity': 'north', 'public_id': 'my_poster', 'format': 'jpg'}, source_types: "mp4")).toEqual(
      "<video poster=\"#{expected_poster_url}\" src=\"#{expected_url}.mp4\"></video>")

    expect(cl.video("movie", poster: "", source_types: "mp4")).toEqual(
      "<video src=\"#{expected_url}.mp4\"></video>")

    expect(cl.video("movie", poster: false, source_types: "mp4")).toEqual(
      "<video src=\"#{expected_url}.mp4\"></video>")
  describe "attributes", ->
    tag = cloudinary.HtmlTag.new("div", { id: "foobar"})
    describe "removeAttr()", ->
      it "should remove that attribute from the tag", ->
        tag.removeAttr("id")
        keys = for key of tag.attributes()
          key
        expect(keys).not.toContain("id")


  describe "toDOM", ->
    element = cloudinary.HtmlTag.new("div").toDOM()
    it "should generate a DOM Element", ->
      expect(element?.nodeType).toBe(1) # element
      expect(element.tagName).toMatch /div/i

