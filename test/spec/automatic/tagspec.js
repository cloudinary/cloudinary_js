var cl, getTag, protocol, simpleAssign, simpleClone, test_cloudinary_url;

cl = {};
const UPLOAD_PATH = "http://res.cloudinary.com/test123/image/upload";

getTag = function(tag) {
  var next;
  next = /<.*?>/.exec(tag);
  if (next) {
    return [tag.substr(next[0].length), next[0]];
  } else {
    return [tag, null];
  }
};

protocol = window.location.protocol === "file:" ? "http:" : window.location.protocol;

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

test_cloudinary_url = function(public_id, options, expected_url, expected_options) {
  var result;
  result = cl.url(public_id, options);
  expect(new cloudinary.Transformation(options).toHtmlAttributes()).toEqual(expected_options);
  return expect(result).toEqual(expected_url);
};

describe("Cloudinary.HtmlTag", function() {
  return describe("constructor", function() {
    it('should create a new tag with 3 parameters', function() {
      return expect(function() {
        return new cloudinary.HtmlTag('div', "publicId", {});
      }).not.toThrow();
    });
    return it('should create a new tag with 2 parameters', function() {
      return expect(function() {
        return new cloudinary.HtmlTag('div', {});
      }).not.toThrow();
    });
  });
});

sharedExamples("client_hints", function(options) {
  it("should not use data-src or set responsive class", function() {
    var image, tag;
    image = cl.image('sample.jpg', options);
    tag = image.outerHTML;
    expect(tag).toMatch(/<img.*>/);
    expect(tag).not.toMatch(/<.*class.*>/);
    expect(cloudinary.Util.getData(image, "src")).toBeFalsy();
    return expect(tag).toMatch(/src=["']http:\/\/res.cloudinary.com\/sdk-test\/image\/upload\/c_scale,dpr_auto,w_auto\/sample.jpg["']/);
  });
  return it("should override responsive", function() {
    var image, tag;
    cl.config().responsive = true;
    image = cl.image('sample.jpg', options);
    tag = image.outerHTML;
    expect(tag).toMatch(/<img.*>/);
    expect(tag).not.toMatch(/<.*class.*>/);
    expect(cloudinary.Util.getData(image, "src")).toBeFalsy();
    return expect(tag).toMatch(/src=["']http:\/\/res.cloudinary.com\/sdk-test\/image\/upload\/c_scale,dpr_auto,w_auto\/sample.jpg["']/);
  });
});

describe("Cloudinary.ImageTag", function() {
  var DEFAULT_UPLOAD_PATH, config;
  config = {
    'cloud_name': 'test123'
  };

  const minWidth = 100;
  const maxWidth = 399;
  const breakpointList = [minWidth, 200, 300, maxWidth];
  const commonSrcset = {'breakpoints': breakpointList};
  const publicId = 'sample';
  const imageFormat = 'jpg';
  const fullPublicId = publicId + '.' + imageFormat;
  const commonTransformation = {'effect': 'sepia'};
  const commonImageOptions = Object.assign({}, config, {
    transformation: [commonTransformation],
  });

  beforeEach(function() {
    return cl = new cloudinary.Cloudinary(config);
  });
  DEFAULT_UPLOAD_PATH = `${protocol}//res.cloudinary.com/test123/image/upload/`;

  it("Should create srcset attribute from provided breakpoints", function () {
    let tag = new cloudinary.ImageTag(
        fullPublicId,
        Object.assign({}, commonImageOptions, {srcset: commonSrcset})
    ).toHtml();

    return expect(`<img src="${DEFAULT_UPLOAD_PATH}e_sepia/${fullPublicId}" srcset="` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_100/${fullPublicId} 100w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_200/${fullPublicId} 200w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_300/${fullPublicId} 300w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_399/${fullPublicId} 399w">`)
        .toBe(tag);
  });

  it("Should create srcset attribute from provided breakpoints as float values", function () {
    let breakpointListFloat = [...breakpointList];
    breakpointListFloat.forEach(function (part, index, theArray) {
      theArray[index] += 0.1;
    });
    let commonSrcsetFloat = {'breakpoints': breakpointListFloat};

    let tag = new cloudinary.ImageTag(
        fullPublicId,
        Object.assign({}, commonImageOptions, {srcset: commonSrcsetFloat})
    ).toHtml();

    return expect(`<img src="${DEFAULT_UPLOAD_PATH}e_sepia/${fullPublicId}" srcset="` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_100.1/${fullPublicId} 100.1w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_200.1/${fullPublicId} 200.1w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_300.1/${fullPublicId} 300.1w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_399.1/${fullPublicId} 399.1w">`)
        .toBe(tag);
  });

  it("Should support srcset attribute defined by min_width, max_width, and max_images", function () {
    let srcsetParams = {'min_width': minWidth, 'max_width': maxWidth, 'max_images': breakpointList.length};

    let tag = new cloudinary.ImageTag(
        fullPublicId,
        Object.assign({}, commonImageOptions, {srcset: srcsetParams})
    ).toHtml();

    return expect(`<img src="${DEFAULT_UPLOAD_PATH}e_sepia/${fullPublicId}" srcset="` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_100/${fullPublicId} 100w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_200/${fullPublicId} 200w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_300/${fullPublicId} 300w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_399/${fullPublicId} 399w">`)
        .toBe(tag);
  });

  it("Should support 1 image in srcset", function () {
    let srcsetParams = {'min_width': minWidth, 'max_width': maxWidth, 'max_images': 1};
    let srcsetBreakpoint = {"breakpoints": [maxWidth]};

    let tagByParams = new cloudinary.ImageTag(
        fullPublicId,
        Object.assign({}, commonImageOptions, {srcset: srcsetParams})
    ).toHtml();
    let tagByBreakpoint = new cloudinary.ImageTag(
        fullPublicId,
        Object.assign({}, commonImageOptions, {srcset: srcsetBreakpoint})
    ).toHtml();

    let expectedTag = `<img src="${DEFAULT_UPLOAD_PATH}e_sepia/${fullPublicId}" srcset="` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_399/${fullPublicId} 399w">`;

    expect(expectedTag).toBe(tagByParams);
    return expect(expectedTag).toBe(tagByBreakpoint);
  });

  it("Should support custom transformation for srcset items", function () {
    let srcsetParams = Object.assign({}, commonSrcset, {
      transformation: {'crop': 'crop', 'width': 10, 'height': 20},
    });

    let tag = new cloudinary.ImageTag(
        fullPublicId,
        Object.assign({}, commonImageOptions, {srcset: srcsetParams})
    ).toHtml();

    return expect(`<img src="${DEFAULT_UPLOAD_PATH}e_sepia/${fullPublicId}" srcset="` +
        `${DEFAULT_UPLOAD_PATH}c_crop,h_20,w_10/c_scale,w_100/${fullPublicId} 100w, ` +
        `${DEFAULT_UPLOAD_PATH}c_crop,h_20,w_10/c_scale,w_200/${fullPublicId} 200w, ` +
        `${DEFAULT_UPLOAD_PATH}c_crop,h_20,w_10/c_scale,w_300/${fullPublicId} 300w, ` +
        `${DEFAULT_UPLOAD_PATH}c_crop,h_20,w_10/c_scale,w_399/${fullPublicId} 399w">`)
        .toBe(tag);
  });

  it("Should populate sizes attribute", function () {
    let srcsetParams = Object.assign({}, commonSrcset, {
      sizes: true,
    });

    let tag = new cloudinary.ImageTag(
        fullPublicId,
        Object.assign({}, commonImageOptions, {srcset: srcsetParams})
    ).toHtml();

    return expect(`<img sizes="` +
        `(max-width: 100px) 100px, (max-width: 200px) 200px, (max-width: 300px) 300px, (max-width: 399px) 399px" ` +
        `src="${DEFAULT_UPLOAD_PATH}e_sepia/${fullPublicId}" srcset="` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_100/${fullPublicId} 100w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_200/${fullPublicId} 200w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_300/${fullPublicId} 300w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_399/${fullPublicId} 399w">`)
        .toBe(tag);
  });

  it("Should support srcset string value", function () {
    let raw_srcset_value = 'some srcset data as is';
    let attributes = {'srcset': raw_srcset_value};

    let legacyTag = new cloudinary.ImageTag(
        fullPublicId,
        Object.assign({}, commonImageOptions, {srcset: raw_srcset_value})
    ).toHtml();
    let tag = new cloudinary.ImageTag(
        fullPublicId,
        Object.assign({}, commonImageOptions, {attributes: attributes})
    ).toHtml();

    let expectedTag = `<img src="${DEFAULT_UPLOAD_PATH}e_sepia/${fullPublicId}" srcset="some srcset data as is">`;

    expect(expectedTag).toBe(tag);
    return expect(expectedTag).toBe(legacyTag);
  });

  it("Should remove width and height attributes in case srcset is specified", function () {
    let tag = new cloudinary.ImageTag(
        fullPublicId,
        Object.assign({}, commonImageOptions, {
          width: 500,
          height: 500,
          srcset: commonSrcset
        })
    ).toHtml();

    return expect(`<img src="${DEFAULT_UPLOAD_PATH}e_sepia/${fullPublicId}" srcset="` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_100/${fullPublicId} 100w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_200/${fullPublicId} 200w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_300/${fullPublicId} 300w, ` +
        `${DEFAULT_UPLOAD_PATH}e_sepia/c_scale,w_399/${fullPublicId} 399w">`)
        .toBe(tag);
  });

  describe("Should raise ValueError on invalid values", function () {
    const errMsgNotSet = 'Either (min_width, max_width, max_images) or breakpoints must be provided to the image srcset attribute';
    const errMsgWidth = 'min_width must be less than max_width';
    const errMsgMaxImages = 'max_images must be a positive integer';

    let invalidSrcsetDataProvider = [
      {
        message: errMsgNotSet,
        srcset: {'sizes': true}
      },
      {
        message: errMsgNotSet,
        srcset: {'max_width': 300, 'max_images': 3}
      },
      {
        message: errMsgNotSet,
        srcset: {'min_width': 'string', 'max_width': 300, 'max_images': 3}
      },
      {
        message: errMsgNotSet,
        srcset: {'min_width': 100, 'max_images': 3}
      },
      {
        message: errMsgNotSet,
        srcset: {'min_width': 100, 'max_width': 'string', 'max_images': 3}
      },
      {
        message: errMsgWidth,
        srcset: {'min_width': 200, 'max_width': 100, 'max_images': 3}
      },
      {
        message: errMsgNotSet,
        srcset: {'min_width': 100, 'max_width': 300}
      },
      {
        message: errMsgMaxImages,
        srcset: {'min_width': 100, 'max_width': 300, 'max_images': 0}
      },
      {
        message: errMsgMaxImages,
        srcset: {'min_width': 100, 'max_width': 300, 'max_images': -17}
      },
      {
        message: errMsgNotSet,
        srcset: {'min_width': 100, 'max_width': 300, 'max_images': 'string'}
      },
    ];

    invalidSrcsetDataProvider.forEach(function (testCase) {
      it(`Should throw "${testCase.message}" on ${JSON.stringify(testCase.srcset)} params`, function () {
        expect(function () {
              new cloudinary.ImageTag(
                  fullPublicId,
                  Object.assign({}, commonImageOptions, {srcset: testCase.srcset})
              ).toHtml();
            }
        ).toThrow(testCase.message);
      });
    });
  });

  it("should create an image tag", function() {
    var tag;
    tag = new cloudinary.ImageTag('image_id', config).toHtml();
    return expect(tag).toBe(`<img src="${DEFAULT_UPLOAD_PATH}image_id">`);
  });
  it("should escape quotes in html attributes", function() {
    var tag;
    tag = new cloudinary.ImageTag('image_id', Object.assign({}, config, {
      alt: "asdfg\"'asdf"
    })).toHtml();
    return expect(tag).toBe(`<img alt="asdfg&#34;&#39;asdf" src="${DEFAULT_UPLOAD_PATH}image_id">`);
  });
  it("should create an image tag with encoded special chars", function() {
    const imageId = `test's special < \"characters\" >`;
    const encodedImageId = "test&#39;s%20special%20%3C%20%22characters%22%20%3E";
    let tag = new cloudinary.ImageTag(imageId, cloudinary.Util.assign({
      responsive: true
    }, config)).toHtml();

    return expect(tag).toBe(`<img data-src="${DEFAULT_UPLOAD_PATH}${encodedImageId}">`);
  });

  it("should set data-src instead of src when using responsive", function() {
    var tag;
    tag = new cloudinary.ImageTag('image_id', cloudinary.Util.assign({
      responsive: true
    }, config)).toHtml();
    return expect(tag).toBe(`<img data-src="${DEFAULT_UPLOAD_PATH}image_id">`);
  });
  return describe(":client_hints", function() {
    describe("as option", function() {
      return includeContext("client_hints", {
        dpr: "auto",
        cloud_name: "sdk-test",
        width: "auto",
        crop: "scale",
        client_hints: true
      });
    });
    describe("as global configuration", function() {
      beforeEach(function() {
        return cl.config().client_hints = true;
      });
      return includeContext("client_hints", {
        dpr: "auto",
        cloud_name: "sdk-test",
        width: "auto",
        crop: "scale"
      });
    });
    describe("false", function() {
      return it("should use normal responsive behaviour", function() {
        var image, tag;
        cl.config().responsive = true;
        image = cl.image('sample.jpg', {
          width: "auto",
          crop: "scale",
          cloud_name: "sdk-test",
          client_hints: false
        });
        tag = image.outerHTML;
        expect(tag).toMatch(/<img.*>/);
        expect(tag).toMatch(/class=["']cld-responsive["']/);
        return expect(cloudinary.Util.getData(image, "src-cache")).toMatch(/http:\/\/res.cloudinary.com\/sdk-test\/image\/upload\/c_scale,w_auto\/sample.jpg/);
      });
    });
    return describe("width", function() {
      return it("supports auto width", function() {
        var tag;
        tag = cl.image('sample.jpg', {
          crop: "scale",
          dpr: "auto",
          cloud_name: "sdk-test",
          width: "auto:breakpoints",
          client_hints: true
        }).outerHTML;
        return expect(tag).toMatch(/src=["']http:\/\/res.cloudinary.com\/sdk-test\/image\/upload\/c_scale,dpr_auto,w_auto:breakpoints\/sample.jpg["']/);
      });
    });
  });
});

describe("Cloudinary.VideoTag", function() {
  var DEFAULT_UPLOAD_PATH, VIDEO_UPLOAD_PATH, config, options, root_path, upload_path;
  VIDEO_UPLOAD_PATH = `${protocol}//res.cloudinary.com/test123/video/upload/`;
  DEFAULT_UPLOAD_PATH = `${protocol}//res.cloudinary.com/test123/image/upload/`;
  config = {
    cloud_name: "test123",
    private_cdn: false,
    secure: false,
    cdn_subdomain: false,
    api_key: "1234",
    api_secret: "b"
  };
  options = {};
  beforeEach(function() {
    cl = new cloudinary.Cloudinary(config);
    return options = simpleClone(config);
  });
  root_path = `${protocol}//res.cloudinary.com/test123`;
  upload_path = `${root_path}/video/upload`;
  describe("constructor", function() {
    var v;
    v = new cloudinary.VideoTag("pubid");
    return it('should create a new Cloudinary.VideoTag object', function() {
      return expect(v.constructor.name).toBe("VideoTag");
    });
  });
  //    it 'should support a hash value', ->
  //      test_cloudinary_url("video_id", { resource_type: 'video', video_codec: { codec: 'h264', profile: 'basic', level: '3.1' } },
  //                          "#{upload_path}/vc_h264:basic:3.1/video_id", {})
  it("should generate video tag", function() {
    var expected_url, tag, videoTag;
    expected_url = VIDEO_UPLOAD_PATH + "movie";
    videoTag = new cloudinary.VideoTag("movie", options).toHtml();
    [videoTag, tag] = getTag(videoTag);
    expect(tag).toBe(`<video poster="${expected_url}.jpg">`);
    [videoTag, tag] = getTag(videoTag);
    expect(tag).toBe(`<source src="${expected_url}.webm" type="video/webm">`);
    [videoTag, tag] = getTag(videoTag);
    expect(tag).toBe(`<source src="${expected_url}.mp4" type="video/mp4">`);
    [videoTag, tag] = getTag(videoTag);
    return expect(tag).toBe(`<source src="${expected_url}.ogv" type="video/ogg">`);
  });
  it("should generate video tag with html5 attributes", function() {
    var expected_url, tag, videoTag;
    expected_url = VIDEO_UPLOAD_PATH + "movie";
    videoTag = new cloudinary.VideoTag("movie", simpleAssign({
      autoplay: 1,
      controls: true,
      loop: true,
      muted: "true",
      preload: true,
      style: "border: 1px"
    }, options)).toHtml();
    [videoTag, tag] = getTag(videoTag);
    expect(tag).toBe(`<video autoplay="1" controls loop muted="true" poster="${expected_url}.jpg" preload style="border: 1px">`);
    [videoTag, tag] = getTag(videoTag);
    expect(tag).toBe(`<source src="${expected_url}.webm" type="video/webm">`);
    [videoTag, tag] = getTag(videoTag);
    expect(tag).toBe(`<source src="${expected_url}.mp4" type="video/mp4">`);
    [videoTag, tag] = getTag(videoTag);
    return expect(tag).toBe(`<source src="${expected_url}.ogv" type="video/ogg">`);
  });
  it("should generate video tag with various attributes", function() {
    var expected_url, options2, tag;
    options2 = simpleAssign(options, {
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
    expect(new cloudinary.VideoTag("movie", options2).toHtml()).toEqual(`<video height="100" poster="${expected_url}.jpg" src="${expected_url}.mp4" width="200"></video>`);
    delete options2['source_types'];
    tag = new cloudinary.VideoTag("movie", options2).toHtml();
    expect(tag).toContain(`<video height="100" poster="${expected_url}.jpg" width="200">`);
    expect(tag).toContain(`<source src="${expected_url}.webm" type="video/webm">`);
    expect(tag).toContain(`<source src="${expected_url}.mp4" type="video/mp4">`);
    expect(tag).toContain(`<source src="${expected_url}.ogv" type="video/ogg">`);
    delete options2['html_height'];
    delete options2['html_width'];
    options2['width'] = 250;
    options2['crop'] = 'scale';
    expected_url = VIDEO_UPLOAD_PATH + "ac_acc,c_scale,so_3,vc_h264,w_250/movie";
    expect(new cloudinary.VideoTag("movie", options2).toHtml()).toEqual(`<video poster="${expected_url}.jpg" width="250">` + `<source src="${expected_url}.webm" type="video/webm">` + `<source src="${expected_url}.mp4" type="video/mp4">` + `<source src="${expected_url}.ogv" type="video/ogg">` + "</video>");
    expected_url = VIDEO_UPLOAD_PATH + "ac_acc,c_fit,so_3,vc_h264,w_250/movie";
    options2['crop'] = 'fit';
    return expect(new cloudinary.VideoTag("movie", options2).toHtml()).toEqual(`<video poster="${expected_url}.jpg">` + `<source src="${expected_url}.webm" type="video/webm">` + `<source src="${expected_url}.mp4" type="video/mp4">` + `<source src="${expected_url}.ogv" type="video/ogg">` + "</video>");
  });
  it("should generate video tag with fallback", function() {
    var expected_url, fallback;
    expected_url = VIDEO_UPLOAD_PATH + "movie";
    fallback = "<span id=\"spanid\">Cannot display video</span>";
    expect(new cloudinary.VideoTag("movie", simpleAssign({
      fallback_content: fallback
    }, options)).toHtml()).toBe(`<video poster="${expected_url}.jpg">` + `<source src="${expected_url}.webm" type="video/webm">` + `<source src="${expected_url}.mp4" type="video/mp4">` + `<source src="${expected_url}.ogv" type="video/ogg">` + fallback + "</video>");
    return expect(new cloudinary.VideoTag("movie", simpleAssign({
      fallback_content: fallback,
      source_types: "mp4"
    }, options)).toHtml()).toEqual(`<video poster="${expected_url}.jpg" src="${expected_url}.mp4">` + fallback + "</video>");
  });
  it("should generate video tag with source types", function() {
    var expected_url;
    expected_url = VIDEO_UPLOAD_PATH + "movie";
    return expect(cl.video("movie", {
      source_types: ['ogv', 'mp4']
    })).toEqual(`<video poster="${expected_url}.jpg">` + `<source src="${expected_url}.ogv" type="video/ogg">` + `<source src="${expected_url}.mp4" type="video/mp4">` + "</video>");
  });
  it("should generate video tag with source transformation", function() {
    var expected_mp4_url, expected_ogv_url, expected_url;
    expected_url = VIDEO_UPLOAD_PATH + "q_50/c_scale,w_100/movie";
    expected_ogv_url = VIDEO_UPLOAD_PATH + "q_50/c_scale,q_70,w_100/movie";
    expected_mp4_url = VIDEO_UPLOAD_PATH + "q_50/c_scale,q_30,w_100/movie";
    expect(cl.video("movie", {
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
    })).toEqual(`<video poster="${expected_url}.jpg" width="100">` + `<source src="${expected_url}.webm" type="video/webm">` + `<source src="${expected_mp4_url}.mp4" type="video/mp4">` + `<source src="${expected_ogv_url}.ogv" type="video/ogg">` + "</video>");
    return expect(cl.video("movie", {
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
    })).toEqual(`<video poster="${expected_url}.jpg" width="100">` + `<source src="${expected_url}.webm" type="video/webm">` + `<source src="${expected_mp4_url}.mp4" type="video/mp4">` + "</video>");
  });
  it("should generate video tag with configurable poster", function() {
    var expected_poster_url, expected_url;
    expected_url = VIDEO_UPLOAD_PATH + "movie";
    expected_poster_url = 'http://image/somewhere.jpg';
    expect(cl.video("movie", {
      poster: expected_poster_url,
      source_types: "mp4"
    })).toEqual(`<video poster="${expected_poster_url}" src="${expected_url}.mp4"></video>`);
    expected_poster_url = VIDEO_UPLOAD_PATH + "g_north/movie.jpg";
    expect(cl.video("movie", {
      poster: {
        'gravity': 'north'
      },
      source_types: "mp4"
    })).toEqual(`<video poster="${expected_poster_url}" src="${expected_url}.mp4"></video>`);
    expected_poster_url = DEFAULT_UPLOAD_PATH + "g_north/my_poster.jpg";
    expect(cl.video("movie", {
      poster: {
        'gravity': 'north',
        'public_id': 'my_poster',
        'format': 'jpg'
      },
      source_types: "mp4"
    })).toEqual(`<video poster="${expected_poster_url}" src="${expected_url}.mp4"></video>`);
    expect(cl.video("movie", {
      poster: "",
      source_types: "mp4"
    })).toEqual(`<video src="${expected_url}.mp4"></video>`);
    return expect(cl.video("movie", {
      poster: false,
      source_types: "mp4"
    })).toEqual(`<video src="${expected_url}.mp4"></video>`);
  });
  it("should generate video tag with encoded special chars", function() {
    const movieId = `test's special < \"characters\" >`;
    const encodedMovieId = "test&#39;s%20special%20%3C%20%22characters%22%20%3E";
    let tag, videoTag;
    const expected_url = VIDEO_UPLOAD_PATH + encodedMovieId;
    videoTag = new cloudinary.VideoTag(movieId, options).toHtml();
    [videoTag, tag] = getTag(videoTag);
    expect(tag).toBe(`<video poster="${expected_url}.jpg">`);
    [videoTag, tag] = getTag(videoTag);
    expect(tag).toBe(`<source src="${expected_url}.webm" type="video/webm">`);
    [videoTag, tag] = getTag(videoTag);
    expect(tag).toBe(`<source src="${expected_url}.mp4" type="video/mp4">`);
    [videoTag, tag] = getTag(videoTag);
    return expect(tag).toBe(`<source src="${expected_url}.ogv" type="video/ogg">`);
  });
  describe("attributes", function() {
    var tag;
    tag = cloudinary.HtmlTag.new("div", {
      id: "foobar"
    });
    return describe("removeAttr()", function() {
      return it("should remove that attribute from the tag", function() {
        var key, keys;
        tag.removeAttr("id");
        keys = (function() {
          var results;
          results = [];
          for (key in tag.attributes()) {
            results.push(key);
          }
          return results;
        })();
        return expect(keys).not.toContain("id");
      });
    });
  });
  return describe("toDOM", function() {
    var element;
    element = cloudinary.HtmlTag.new("div").toDOM();
    return it("should generate a DOM Element", function() {
      expect(element != null ? element.nodeType : void 0).toBe(1); // element
      return expect(element.tagName).toMatch(/div/i);
    });
  });
});

describe("ClientHintsMetaTag", function() {
  return it("should generate a meta tag defining client hints", function() {
    var tag;
    tag = new cloudinary.ClientHintsMetaTag().toHtml();
    return expect(tag).toBe('<meta content="DPR, Viewport-Width, Width" http-equiv="Accept-CH">');
  });
});
describe("SourceTag", function(){
  const public_id = "sample";
  const image_format = "jpg";
  const FULL_PUBLIC_ID = `${public_id}.${image_format}`;
  var commonTrans = null;
  var commonTransformationStr = null;
  var customAttributes = null;
  var min_width = null;
  var max_width = null;
  var breakpoint_list = null;
  var common_srcset = null;
  var fill_transformation = null;
  var fill_transformation_str = null;
  var cl = null;
  beforeEach(function () {
    commonTrans = {
      effect: 'sepia',
      cloud_name: 'test123',
      client_hints: false
    };
    commonTransformationStr = 'e_sepia';
    customAttributes = {
      custom_attr1: 'custom_value1',
      custom_attr2: 'custom_value2'
    };
    min_width = 100;
    max_width = 399;
    breakpoint_list = [min_width, 200, 300, max_width];
    common_srcset = {
      "breakpoints": breakpoint_list
    };
    fill_transformation = {
      "width": max_width,
      "height": max_width,
      "crop": "fill"
    };
    fill_transformation_str = `c_fill,h_${max_width},w_${max_width}`;
    cl = new Cloudinary({
      cloud_name: "test123",
      api_secret: "1234"
    });
  });
  it("should generate a source tag", function () {
    expect(cl.sourceTag("sample.jpg").toHtml()).toBe(`<source srcset="${UPLOAD_PATH}/sample.jpg">`);
  });
  it("should generate source tag with media query", function () {
    var expectedMedia, expectedTag, media, tag;
    media = {min_width, max_width};
    tag = cl.sourceTag(FULL_PUBLIC_ID, {
      media: media
    });
    expectedMedia = `(min-width: ${min_width}px) and (max-width: ${max_width}px)`;
    expectedTag = `<source media="${expectedMedia}" srcset="${UPLOAD_PATH}/sample.jpg">`;
    expect(tag.toHtml()).toBe(expectedTag);
  });
  it("should generate source tag with responsive srcset", function () {
    var tag = cl.sourceTag(FULL_PUBLIC_ID, {
      srcset: common_srcset
    });
    expect(tag.toHtml()).toBe('<source srcset="' +
      "http://res.cloudinary.com/test123/image/upload/c_scale,w_100/sample.jpg 100w, " +
      "http://res.cloudinary.com/test123/image/upload/c_scale,w_200/sample.jpg 200w, " +
      "http://res.cloudinary.com/test123/image/upload/c_scale,w_300/sample.jpg 300w, " +
      "http://res.cloudinary.com/test123/image/upload/c_scale,w_399/sample.jpg 399w" + '">');
  });

});
describe("PictureTag", function(){
  it("should generate picture tag", function () {
    const min_width = 100;
    const max_width = 399;
    const fill_transformation = {
      cloud_name: "test123",
      width: max_width,
      height: max_width,
      crop: "fill"
    };
    const fill_transformation_str = `c_fill,h_${max_width},w_${max_width}`;
    const public_id = "sample";
    const image_format = "jpg";
    const FULL_PUBLIC_ID = `${public_id}.${image_format}`;

    var exp_tag, tag;
    tag = new cloudinary.PictureTag(FULL_PUBLIC_ID, fill_transformation, [
        {
          "max_width": min_width,
          "transformation": {
            "crop": "scale",
            "effect": "sepia",
            "angle": 17,
            "width": min_width
          }
        },
        {
          "min_width": min_width,
          "max_width": max_width,
          "transformation": {
            "crop": "scale",
            "effect": "colorize",
            "angle": 18,
            "width": max_width
          }
        },
        {
          "min_width": max_width,
          "transformation": {
            "crop": "scale",
            "effect": "blur",
            "angle": 19,
            "width": max_width
          }
        }
      ]
    );
    exp_tag = "<picture>" +
      '<source media="(max-width: 100px)" srcset="http://res.cloudinary.com/test123/image/upload/c_fill,h_399,w_399/a_17,c_scale,e_sepia,w_100/sample.jpg">' +
      '<source media="(min-width: 100px) and (max-width: 399px)" srcset="http://res.cloudinary.com/test123/image/upload/c_fill,h_399,w_399/a_18,c_scale,e_colorize,w_399/sample.jpg">' +
      '<source media="(min-width: 399px)" srcset="http://res.cloudinary.com/test123/image/upload/c_fill,h_399,w_399/a_19,c_scale,e_blur,w_399/sample.jpg">' +
      '<img height="399" src="http://res.cloudinary.com/test123/image/upload/c_fill,h_399,w_399/sample.jpg" width="399">' +
      "</picture>";
    expect(tag.toHtml()).toBe(exp_tag);
  });

  describe("pictureTag", function(){
    let defaultUploadPath, config, cl;
    config = {'cloud_name': 'test123'};
    defaultUploadPath = `${protocol}//res.cloudinary.com/${config.cloud_name}/image/upload/`;

    beforeEach(function () {
      cl = new Cloudinary(config);
    });

    it("should generate a picture tag", function () {
      let tag = cl.pictureTag('image_id').toHtml();
      return expect(tag).toBe(`<picture><img src="${defaultUploadPath}image_id"></picture>`);
    });

    it("should generate a picture tag with options", function () {
      let tag = cl.pictureTag('image_id', {width: 150, crop: "fill"}).toHtml();
      return expect(tag).toBe(`<picture><img src="${defaultUploadPath}c_fill,w_150/image_id" width="150"></picture>`);
    });

    it("should generate a picture tag with options and sources", function () {
      let tag = cl.pictureTag(
          'image_id',
          {
            width: 150,
            crop: "fill"
          },
          [
            {
              "max_width": 200,
              "transformation": {
                "crop": "scale",
                "effect": "sepia",
                "angle": 17,
                "width": 100
              }
            }
          ]
      ).toHtml();
      return expect(tag).toBe(
          `<picture>` +
          `<source media="(max-width: 200px)" srcset="${defaultUploadPath}c_fill,w_150/a_17,c_scale,e_sepia,w_100/image_id">` +
          `<img src="${defaultUploadPath}c_fill,w_150/image_id" width="150">` +
          `</picture>`
      );
    });
  });
});
