describe("Lazy Loaded Image", function() {
  it("should return empty src on Firefox", function() {
    cl = cloudinary.Cloudinary.new({cloud_name: 'sdk-test'});
    var img;
    let options = {loading: "lazy"}
    img = cl.image("sample", options);
    img.removeAttribute('src');
    cl.cloudinary_update(img, options);

    if(navigator.userAgent.toLowerCase().indexOf('firefox') > -1) {
      expect(img).not.toContain('src');
    }
    if(navigator.userAgent.toLowerCase().indexOf('chrome') > -1) {
      expect(img.getAttribute('src')).toEqual('http://res.cloudinary.com/sdk-test/image/upload/sample');
    }
  });
});
