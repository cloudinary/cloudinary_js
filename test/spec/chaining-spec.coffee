
describe "Chaining", () ->
  describe "Cloudinary.transformation", () ->
    t = cloudinary.transformation()
    it "should return a transformation object", () ->
      expect(t.constructor).toBe( "Transformation")
    it "should return the calling object with getParent()", ()->
      expect(t.getParent()).toBe(cloudinary)