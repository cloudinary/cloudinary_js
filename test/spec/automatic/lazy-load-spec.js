describe("Lazy Loaded Image", function() {
  it("should return empty src", function() {
    cl = cloudinary.Cloudinary.new({cloud_name: 'sdk-test'});
    let options = {loading: "lazy"};
    let img = cl.image("sample", options);
    img.removeAttribute('src');
    cl.cloudinary_update(img, options);
    expect(img).not.toContain('src');
  });
});
