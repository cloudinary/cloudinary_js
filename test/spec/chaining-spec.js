(function() {
  describe("Chaining", function() {
    return describe("Cloudinary.transformation", function() {
      var t;
      t = cloudinary.transformation();
      it("should return a transformation object", function() {
        return expect(t.constructor).toBe("Transformation");
      });
      return it("should return the calling object with getParent()", function() {
        return expect(t.getParent()).toBe(cloudinary);
      });
    });
  });

}).call(this);
