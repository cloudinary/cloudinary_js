describe("cloudinary", function() {
  var result;
  beforeEach(function() {
    $.cloudinary.config({
      cloud_name: "test123"
    });
  });
  
  it("should use cloud_name from config", function() {    
    result = $.cloudinary.url_internal("test");
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/test") ;
  });

  it("should allow overriding cloud_name in options", function() {
    options = {"cloud_name": "test321"};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test321/image/upload/test") ;
  });

  it("should default to akamai if secure", function() {
    options = {secure: true};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual("https://res.cloudinary.com/test123/image/upload/test") ;
  });

  it("should default to akamai if secure is given with private_cdn and no secure_distribution", function() {
    options = {secure: true, private_cdn: true};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual("https://test123-res.cloudinary.com/image/upload/test") ;
  });

  it("should not add cloud_name if secure private_cdn and secure non akamai secure_distribution", function() {
    options = {secure: true, private_cdn: true, secure_distribution: "something.cloudfront.net"};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual("https://something.cloudfront.net/image/upload/test") ;
  });

  it("should not add cloud_name if private_cdn and not secure", function() {
    options = {private_cdn: true};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//test123-res.cloudinary.com/image/upload/test") ;
  });
  
  it("should use format from options", function() {    
    options = {"format": "jpg"};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/test.jpg") ;
  });

  it("should use width and height from options only if crop is given", function() {
    options = {"width": 100, "height": 100};
    result = $.cloudinary.url_internal("test", options);
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/test") ;
    expect(options).toEqual({"width": 100, "height": 100});
    options = {"width": 100, "height": 100, "crop": "crop"};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({"width": 100, "height": 100});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/c_crop,h_100,w_100/test") ;
  });

  it("should not pass width and height to html in case of fit, lfill or limit crop", function() {
    options = {"width": 100, "height": 100, "crop": "limit"};
    result = $.cloudinary.url_internal("test", options);
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/c_limit,h_100,w_100/test") ;
    expect(options).toEqual({});
    options = {"width": 100, "height": 100, "crop": "lfill"};
    result = $.cloudinary.url_internal("test", options);
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/c_lfill,h_100,w_100/test") ;
    expect(options).toEqual({});
    options = {"width": 100, "height": 100, "crop": "fit"};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/c_fit,h_100,w_100/test") ;
  });

  it("should not pass width and height to html in case angle was used", function() {
    options = {"width": 100, "height": 100, "crop": "scale", "angle": "auto"};
    result = $.cloudinary.url_internal("test", options);
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/a_auto,c_scale,h_100,w_100/test") ;
    expect(options).toEqual({});
  });
  
  it("should use x, y, radius, prefix, gravity and quality from options", function() {    
    options = {"x": 1, "y": 2, "radius": 3, "gravity": "center", "quality": 0.4, "prefix": "a"};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/g_center,p_a,q_0.4,r_3,x_1,y_2/test") ;
  });
  
  it("should support named tranformation", function() {    
    options = {"transformation": "blip"};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/t_blip/test") ;
  });

  it("should support array of named tranformations", function() {    
    options = {"transformation": ["blip", "blop"]};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/t_blip.blop/test") ;
  });

  it("should support base tranformation", function() {    
    options = {"transformation": {"x": 100, "y": 100, "crop": "fill"}, "crop": "crop", "width": 100};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({"width": 100});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/c_fill,x_100,y_100/c_crop,w_100/test") ;
  });

  it("should support array of base tranformations", function() {    
    options = {"transformation": [{"x": 100, "y": 100, "width": 200, "crop": "fill"}, {"radius": 10}], "crop": "crop", "width": 100};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({"width": 100});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/c_fill,w_200,x_100,y_100/r_10/c_crop,w_100/test") ;
  });

  it("should not include empty tranformations", function() {    
    options = {"transformation": [{}, {"x": 100, "y": 100, "crop": "fill"}, {}]};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/c_fill,x_100,y_100/test") ;
  });

  it("should support size", function() {    
    options = {"size": "10x10", "crop": "crop"};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({"width": "10", "height": "10"});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/c_crop,h_10,w_10/test") ;
  });

  it("should use type from options", function() {
    options = {"type": "facebook"};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/facebook/test") ;
  });

  it("should use resource_type from options", function() {
    options = {"resource_type": "raw"};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/raw/upload/test") ;
  });

  it("should ignore http links only if type is not given or is asset", function() {
    options = {"type": undefined};
    result = $.cloudinary.url_internal("http://example.com/", options);
    expect(options).toEqual({});
    expect(result).toEqual("http://example.com/") ;
    options = {"type": "asset"};
    result = $.cloudinary.url_internal("http://example.com/", options);
    expect(options).toEqual({});
    expect(result).toEqual("http://example.com/") ;
    options = {"type": "fetch"};
    result = $.cloudinary.url_internal("http://example.com/", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/fetch/http://example.com/") ;
  });

  it("should escape fetch urls", function() {
    options = {"type": "fetch"}
    result = $.cloudinary.url_internal("http://blah.com/hello?a=b", options)
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/fetch/http://blah.com/hello%3Fa%3Db") 
  }); 

  it("should escape http urls", function() {
    options = {"type": "youtube"};
    result = $.cloudinary.url_internal("http://www.youtube.com/watch?v=d9NF2edxy-M", options)
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/youtube/http://www.youtube.com/watch%3Fv%3Dd9NF2edxy-M") 
  });
  
  it("should support background", function() {
    options = {"background": "red"}
    result = $.cloudinary.url_internal("test", options)
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/b_red/test") 
    options = {"background": "#112233"}
    result = $.cloudinary.url_internal("test", options)
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/b_rgb:112233/test") 
  });
  
  it("should support default_image", function() {
    options = {"default_image": "default"}
    result = $.cloudinary.url_internal("test", options)
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/d_default/test") 
  });
  
  it("should support angle", function() {
    options = {"angle": 12}
    result = $.cloudinary.url_internal("test", options)
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/a_12/test") 
  });
  
  it("should support format for fetch urls", function() {
    options = {"format": "jpg", "type": "fetch"}
    result = $.cloudinary.url_internal("http://cloudinary.com/images/logo.png", options)
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/fetch/f_jpg/http://cloudinary.com/images/logo.png") 
  });

  it("should support extenal cname", function() {
    options = {"cname": "hello.com"}
    result = $.cloudinary.url_internal("test", options)
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//hello.com/test123/image/upload/test") 
  });

  it("should support extenal cname with cdn_subdomain on", function() {
    options = {"cname": "hello.com", "cdn_subdomain": true}
    result = $.cloudinary.url_internal("test", options)
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//a2.hello.com/test123/image/upload/test") 
  });

  it("should support effect", function() {
    options = {"effect": "sepia"}
    result = $.cloudinary.url_internal("test", options)
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/e_sepia/test") 
  });
  
  it("should support effect with param", function() {
    options = {"effect": ["sepia", 10]}
    result = $.cloudinary.url_internal("test", options)
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/e_sepia:10/test") 
  });
  
  it("should support fetch_image", function() {
    result = $.cloudinary.fetch_image("http://example.com/hello.jpg?a=b").attr("src");
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/fetch/http://example.com/hello.jpg%3Fa%3Db") 
  });
  
  layers = {overlay: "l", underlay: "u"};
  for (var layer in layers) {
    it("should support " + layer, function() {
      options = {}; options[layer] = "text:hello";
      result = $.cloudinary.url_internal("test", options)
      expect(options).toEqual({});
      expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/" + layers[layer] + "_text:hello/test") 
    });
    it("should not pass width/height to html for " + layer, function() {
      options = {height: 100, width: 100}; options[layer] = "text:hello";
      result = $.cloudinary.url_internal("test", options)
      expect(options).toEqual({});
      expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/h_100," + layers[layer] + "_text:hello,w_100/test") 
    });
  }

  it("should support density", function() {
    options = {density: 150};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/dn_150/test");
  });

  it("should support page", function() {
    options = {page: 5};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/pg_5/test");
  });

  it("should support border", function() {
    options = {border: {width: 5}};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/bo_5px_solid_black/test");
    options = {border: {width: 5, color: "#ffaabbdd"}};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/bo_5px_solid_rgb:ffaabbdd/test");
    options = {border: "1px_solid_blue"};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/bo_1px_solid_blue/test");
  });

  it("should support flags", function() {
    options = {flags: "abc"};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/fl_abc/test");
    options = {flags: ["abc", "def"]};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/fl_abc.def/test");
  });

  it("should support opacity", function() {
    options = {opacity: 30};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/o_30/test");
  });

  it("should add version if public_id contains /", function() {
    result = $.cloudinary.url_internal("folder/test");
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/v1/folder/test"); 
    result = $.cloudinary.url_internal("folder/test", {version: 123});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/v123/folder/test"); 
  });

  it("should not add version if public_id contains version already", function() {
    result = $.cloudinary.url_internal("v1234/test");
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/v1234/test"); 
  });

  it("should allow to shorted image/upload urls", function() {
    result = $.cloudinary.url_internal("test", {shorten: true});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/iu/test"); 
  });
  
  it("should generate sprite css urls", function() {
    result = $.cloudinary.sprite_css("test");
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/sprite/test.css"); 
    result = $.cloudinary.sprite_css("test.css");
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/sprite/test.css"); 
  });

  it("should escape public_ids", function() {
    var tests = {
        "a b": "a%20b",
        "a+b": "a%2Bb",
        "a%20b": "a%20b",
        "a-b": "a-b",
        "a??b": "a%3F%3Fb"};
    for (var source in tests) {
      var target = tests[source]; 
      var result = $.cloudinary.url(source);
      expect(result).toEqual(window.location.protocol + "//res.cloudinary.com/test123/image/upload/" + target);
    }
  });

  it("should allow to override protocol", function() {
    options = {"protocol": "custom:"};
    result = $.cloudinary.url_internal("test", options);
    expect(options).toEqual({});
    expect(result).toEqual("custom://res.cloudinary.com/test123/image/upload/test") ;
  });
});
