describe("Lazy Loaded Image", function() {
  it("should return empty src on Firefox", function() {
    cl = cloudinary.Cloudinary.new({cloud_name: 'sdk-test'});
    var img;
    let options = {loading: "lazy", width: "300"}
    img = cl.image("sample", {
      options
    });
    cl.setImgOnLazyLoad(img, options);
    if(navigator.userAgent.toLowerCase().indexOf('firefox') > -1) {
      expect(img.getAttribute('src')).toEqual('null');
      expect(img.getAttribute('width')).toEqual('null');
    }
    if(navigator.userAgent.toLowerCase().indexOf('chrome') > -1) {
      expect(img.getAttribute('src')).toEqual('http://res.cloudinary.com/sdk-test/image/upload/sample');
    }
  });
});
