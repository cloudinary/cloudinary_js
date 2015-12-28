cl = {}
test_cloudinary_url = (public_id, options, expected_url, expected_options) ->
  result = cl.url(public_id, options)
  expect(new cloudinary.Transformation(options).toHtmlAttributes()).toEqual(expected_options)
  expect(result).toEqual(expected_url)

protocol = if window.location.protocol == "file:" then "http:" else window.location.protocol

describe "Cloudinary::Utils", ->
  beforeEach ->
    cl = new cloudinary.Cloudinary
      cloud_name: "test123"
      secure_distribution: null
      private_cdn: false
      secure: false
      cname: null
      cdn_subdomain: false
      api_key: "1234"
      api_secret: "b"
  root_path = "#{protocol}//res.cloudinary.com/test123"
  upload_path = "#{root_path}/video/upload"

  describe "cloudinary_url", ->

    describe ":video_codec", ->
      it 'should support a string value', ->
        test_cloudinary_url("video_id", { resource_type: 'video', video_codec: 'auto' }, "#{upload_path}/vc_auto/video_id", {})
      it 'should support a hash value', ->
        test_cloudinary_url("video_id", { resource_type: 'video', video_codec: { codec: 'h264', profile: 'basic', level: '3.1' } },
                            "#{upload_path}/vc_h264:basic:3.1/video_id", {})
    describe ":audio_codec", ->
      it 'should support a string value', ->
        test_cloudinary_url("video_id", { resource_type: 'video', audio_codec: 'acc' }, "#{upload_path}/ac_acc/video_id", {})
    describe ":bit_rate", ->
      it 'should support an integer value', ->
        test_cloudinary_url("video_id", { resource_type: 'video', bit_rate: 2048 }, "#{upload_path}/br_2048/video_id", {})
      it 'should support "<integer>k" ', ->
        test_cloudinary_url("video_id", { resource_type: 'video', bit_rate: '44k' }, "#{upload_path}/br_44k/video_id", {})
      it 'should support "<integer>m"', ->
        test_cloudinary_url("video_id", { resource_type: 'video', bit_rate: '1m' }, "#{upload_path}/br_1m/video_id", {})
    describe ":audio_frequency", ->
      it 'should support an integer value', ->
        test_cloudinary_url("video_id", { resource_type: 'video', audio_frequency: 44100 }, "#{upload_path}/af_44100/video_id", {})
    describe ":video_sampling", ->
      it "should support an integer value", ->
        test_cloudinary_url("video_id", { resource_type: 'video', video_sampling: 20 }, "#{upload_path}/vs_20/video_id", {})
      it "should support an string value in the a form of \"<float>s\"", ->
        test_cloudinary_url("video_id", { resource_type: 'video', video_sampling: "2.3s" }, "#{upload_path}/vs_2.3s/video_id", {})
    for short, long in { so: 'start_offset', eo: 'end_offset', du: 'duration' }
      describe ":#{long}", ->
        it "should support decimal seconds ", ->
          op = { resource_type: 'video'}
          op[long] = 2.63
          test_cloudinary_url("video_id", op, "#{upload_path}/#{short}_2.63/video_id", {})
        it 'should support percents of the video length as "<number>p"', ->
          op = { resource_type: 'video'}
          op[long] = '35p'
        test_cloudinary_url("video_id", op, "#{upload_path}/#{short}_35p/video_id", {})
        it 'should support percents of the video length as "<number>%"', ->
          op = { resource_type: 'video'}
          op[long] = '35%'
        test_cloudinary_url("video_id", op, "#{upload_path}/#{short}_35p/video_id", {})

    describe ":offset", ->
      subject = (options)->
        cl.url("video_id", options)
      params = [
        ['string range', 'so_2.66,eo_3.21', '2.66..3.21'],
        ['array', 'so_2.66,eo_3.21', [2.66, 3.21]],
#        ['range of floats', 'so_2.66,eo_3.21', 2.66..3.21],
        ['array of % strings', 'so_35p,eo_70p', ["35%", "70%"]],
        ['array of p strings', 'so_35p,eo_70p', ["35p", "70p"]],
        ['array of float percent', 'so_35.5p,eo_70.5p', ["35.5p", "70.5p"]]
      ]
      for test in params
        [name, url_param, range ]= test

        describe "when provided with #{name} #{range}", ->
          it "should produce a range transformation in the format of #{url_param}", ->
            options = { resource_type: 'video', offset: range }
          #            expect( subject(options) ).to change { options }.to({})
            url = cl.url("video_id", options)
#            expect( new cloudinary.Cloudinary.Transformation(options).toHtmlAttributes() ).toEqual( {})
            matched = /([^\/]*)\/video_id$/.exec(url)
            transformation = if matched then matched[1] else ''
            # we can't rely on the order of the parameters so we sort them before comparing
            expect(transformation.split(',').sort().reverse().join(',')).toEqual(url_param)
          true
        true
    describe "when given existing relevant parameters: 'quality', :background, :crop, :width, :height, :gravity, :overlay", ->
      for param, letter in { overlay: 'l', underlay: 'u' }
        it "should support #{param}", ->
          op = { resource_type: 'video'}
          op[param ]= "text:hello"
          test_cloudinary_url("test", op, "#{upload_path}/#{letter}_text:hello/test", {})
        it "should not pass width/height to html for #{param}", ->
          op = { resource_type: 'video', height: 100, width: 100}
          op[param ]= "text:hello"
          test_cloudinary_url("test", op, "#{upload_path}/h_100,#{letter}_text:hello,w_100/test", {})
      it "should produce the transformation string", ->
        test_cloudinary_url("test", { resource_type: 'video', background: "#112233" }, "#{upload_path}/b_rgb:112233/test", {})
        test_cloudinary_url("test", {
          resource_type: 'video',
          x: 1, y: 2, radius: 3,
          gravity: 'center',
          quality: 0.4,
          prefix: "a" }, "#{upload_path}/g_center,p_a,q_0.4,r_3,x_1,y_2/test", {})

  describe 'cloudinary.video_thumbnail_url', ->
    it "should generate a cloudinary URI to the video thumbnail", ->
      source =  "movie_id"
      options =  {cloud_name: "test123"}
      path =  cl.video_thumbnail_url(source, options)
      expect(path).toEqual("#{upload_path}/movie_id.jpg")

describe "video", ->
  VIDEO_UPLOAD_PATH = "#{protocol}//res.cloudinary.com/test123/video/upload/"
  DEFAULT_UPLOAD_PATH = "#{protocol}//res.cloudinary.com/test123/image/upload/"

  beforeEach ->
    cl = new cloudinary.Cloudinary(cloud_name: "test123", api_secret: "1234")

  it "should generate video tag", ->
    expected_url = VIDEO_UPLOAD_PATH + "movie"
    tag = cl.video("movie")
    expect(tag).toContain("<video poster=\"#{expected_url}.jpg\">")
    expect(tag).toContain("<source src=\"#{expected_url}.webm\" type=\"video/webm\">")
    expect(tag).toContain("<source src=\"#{expected_url}.mp4\" type=\"video/mp4\">")
    expect(tag).toContain("<source src=\"#{expected_url}.ogv\" type=\"video/ogg\">")


  it "should generate video tag with html5 attributes", ->
    expected_url = VIDEO_UPLOAD_PATH + "movie"
    tag = cl.video("movie",
                            autoplay: 1,
                            controls: true,
                            loop: true,
                            muted: "true",
                            preload: true,
                            style: "border: 1px")
    expect(tag).toContain("<video autoplay=\"1\" controls loop muted=\"true\" poster=\"#{expected_url}.jpg\" preload style=\"border: 1px\">")
    expect(tag).toContain("<source src=\"#{expected_url}.webm\" type=\"video/webm\">")
    expect(tag).toContain("<source src=\"#{expected_url}.mp4\" type=\"video/mp4\">")
    expect(tag).toContain("<source src=\"#{expected_url}.ogv\" type=\"video/ogg\">")


  it "should generate video tag with various attributes", ->
    options = {
      source_types: "mp4",
      html_height : "100",
      html_width  : "200",
      video_codec : {codec: "h264"},
      audio_codec : "acc",
      start_offset: 3
    }
    expected_url = VIDEO_UPLOAD_PATH + "ac_acc,so_3,vc_h264/movie"
    expect(cl.video("movie", options)).toEqual(
      "<video height=\"100\" poster=\"#{expected_url}.jpg\" src=\"#{expected_url}.mp4\" width=\"200\"></video>")

    delete options['source_types']
    expect(cl.video("movie", options)).toEqual(
      "<video height=\"100\" poster=\"#{expected_url}.jpg\" width=\"200\">" +
      "<source src=\"#{expected_url}.webm\" type=\"video/webm\">" +
      "<source src=\"#{expected_url}.mp4\" type=\"video/mp4\">" +
      "<source src=\"#{expected_url}.ogv\" type=\"video/ogg\">" +
      "</video>")

    delete options['html_height']
    delete options['html_width']
    options['width'] = 250
    options['crop'] = 'scale'
    expected_url = VIDEO_UPLOAD_PATH + "ac_acc,c_scale,so_3,vc_h264,w_250/movie"
    expect(cl.video("movie", options)).toEqual(
      "<video poster=\"#{expected_url}.jpg\" width=\"250\">" +
      "<source src=\"#{expected_url}.webm\" type=\"video/webm\">" +
      "<source src=\"#{expected_url}.mp4\" type=\"video/mp4\">" +
      "<source src=\"#{expected_url}.ogv\" type=\"video/ogg\">" +
      "</video>")

    expected_url = VIDEO_UPLOAD_PATH + "ac_acc,c_fit,so_3,vc_h264,w_250/movie"
    options['crop'] = 'fit'
    expect(cl.video("movie", options)).toEqual(
      "<video poster=\"#{expected_url}.jpg\">" +
      "<source src=\"#{expected_url}.webm\" type=\"video/webm\">" +
      "<source src=\"#{expected_url}.mp4\" type=\"video/mp4\">" +
      "<source src=\"#{expected_url}.ogv\" type=\"video/ogg\">" +
      "</video>")

  it "should generate video tag with fallback", ->
    expected_url = VIDEO_UPLOAD_PATH + "movie"
    fallback = "<span id=\"spanid\">Cannot display video</span>"
    expect(cl.video("movie", fallback_content: fallback),
      "<video poster=\"#{expected_url}.jpg\">" +
      "<source src=\"#{expected_url}.webm\" type=\"video/webm\">" +
      "<source src=\"#{expected_url}.mp4\" type=\"video/mp4\">" +
      "<source src=\"#{expected_url}.ogv\" type=\"video/ogg\">" +
      fallback +
      "</video>")
    expect(cl.video("movie", fallback_content: fallback, source_types: "mp4")).toEqual(
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

  describe "poster", ->
    expected_url = VIDEO_UPLOAD_PATH + "movie"

    it "should accept a URL", ->
      expected_poster_url = 'http://image/somewhere.jpg'
      expect(cl.video("movie", poster: expected_poster_url, source_types: "mp4")).toEqual(
        "<video poster=\"#{expected_poster_url}\" src=\"#{expected_url}.mp4\"></video>")

    it "should accept an object", ->
      expected_poster_url = VIDEO_UPLOAD_PATH + "g_north/movie.jpg"
      expect(cl.video("movie", poster: {'gravity': 'north'}, source_types: "mp4")).toEqual(
        "<video poster=\"#{expected_poster_url}\" src=\"#{expected_url}.mp4\"></video>")

    it "should accept a different public ID", ->
      expected_poster_url = DEFAULT_UPLOAD_PATH + "g_north/my_poster.jpg"
      expect(cl.video("movie", poster: {'gravity': 'north', 'public_id': 'my_poster', 'format': 'jpg'}, source_types: "mp4")).toEqual(
        "<video poster=\"#{expected_poster_url}\" src=\"#{expected_url}.mp4\"></video>")

    it "should accept an empty string", ->
      expect(cl.video("movie", poster: "", source_types: "mp4")).toEqual(
        "<video src=\"#{expected_url}.mp4\"></video>")

    it "should accept 'false'", ->
      expect(cl.video("movie", poster: false, source_types: "mp4")).toEqual(
        "<video src=\"#{expected_url}.mp4\"></video>")

