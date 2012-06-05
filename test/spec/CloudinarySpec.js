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
    options = {"type": null};
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
  
  it("should support overlay", function() {
    options = {"overlay": "text:hello"}
    result = $.cloudinary.url_internal("test", options)
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/upload/l_text:hello/test") 
  });

  it("should support format for fetch urls", function() {
    options = {"format": "jpg", "type": "fetch"}
    result = $.cloudinary.url_internal("http://cloudinary.com/images/logo.png", options)
    expect(options).toEqual({});
    expect(result).toEqual(window.location.protocol+"//res.cloudinary.com/test123/image/fetch/f_jpg/http://cloudinary.com/images/logo.png") 
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
});
