var TextLayer;

TextLayer = cloudinary.TextLayer;

describe("TextLayer", function() {
  return it("should serialize a text layer object", function() {
    var layer, options;
    options = {
      text: "Cloudinary for the win!",
      fontFamily: "Arial",
      fontSize: 18
    };
    layer = new TextLayer(options);
    expect(layer.textStyleIdentifier()).toEqual("Arial_18");
    return expect(layer.toString()).toEqual("text:Arial_18:Cloudinary%20for%20the%20win%21");
  });
});

//# sourceMappingURL=layer-spec.js.map
