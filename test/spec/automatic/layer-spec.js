const {TextLayer, FetchLayer} = cloudinary;

describe("TextLayer", function() {
  it("should clone", function() {
    const options = {
      text: "Cloudinary for the win!",
      fontFamily: "Arial",
      fontSize: 18
    };
    const first = new TextLayer(options);
    const second = first.clone();
    expect(first).not.toBe(second);
    expect(first).toEqual(second);
    expect(first.toString()).toEqual(second.toString());
  });
  it("should serialize a text layer object", function() {
    var layer, options, transformation;
    options = {
      text: "Cloudinary for the win!",
      fontFamily: "Arial",
      fontSize: 18
    };
    layer = new TextLayer(options);
    expect(layer.textStyleIdentifier()).toEqual("Arial_18");
    expect(layer.toString()).toEqual("text:Arial_18:Cloudinary%20for%20the%20win%21");
    transformation = new Transformation().overlay(options).toString();
    return expect(transformation.toString()).toEqual("l_text:Arial_18:Cloudinary%20for%20the%20win%21");
  });
  it("should serialize a text layer object with antialiasing", function() {
    var layer, options, transformation;
    options = {
      text: "Cloudinary for the win!",
      fontFamily: "Arial",
      fontSize: 18,
      fontAntialiasing: "fast"
    };
    layer = new TextLayer(options);
    expect(layer.textStyleIdentifier()).toEqual("Arial_18_antialias_fast");
    expect(layer.toString()).toEqual("text:Arial_18_antialias_fast:Cloudinary%20for%20the%20win%21");
    transformation = new Transformation().overlay(options).toString();
    return expect(transformation.toString()).toEqual("l_text:Arial_18_antialias_fast:Cloudinary%20for%20the%20win%21");
  });
  it("should serialize a text layer object with hinting", function() {
    var layer, options, transformation;
    options = {
      text: "Cloudinary for the win!",
      fontFamily: "Arial",
      fontSize: 18,
      fontHinting: "full"
    };
    layer = new TextLayer(options);
    expect(layer.textStyleIdentifier()).toEqual("Arial_18_hinting_full");
    expect(layer.toString()).toEqual("text:Arial_18_hinting_full:Cloudinary%20for%20the%20win%21");
    transformation = new Transformation().overlay(options).toString();
    return expect(transformation.toString()).toEqual("l_text:Arial_18_hinting_full:Cloudinary%20for%20the%20win%21");
  });
  it("should support variables in text styles", function () {
    const layer = new TextLayer().text("hello-world").textStyle('$style');
    const transformation = new Transformation().variables([["$style", "!Arial_12!"]]).chain().overlay(layer.toString());
    return expect(transformation.toString()).toEqual("$style_!Arial_12!/l_text:$style:hello-world");
  });
});

describe("FetchLayer", function() {
  it("should serialize a fetch url layer", function() {
    var layer;
    layer = new FetchLayer({
      url: 'http://res.cloudinary.com/demo/sample.jpg'
    }).toString();
    return expect(layer).toEqual('fetch:aHR0cDovL3Jlcy5jbG91ZGluYXJ5LmNvbS9kZW1vL3NhbXBsZS5qcGc=');
  });
  it("should accept a url in the constructor", function() {
    var layer;
    layer = new FetchLayer('http://res.cloudinary.com/demo/sample.jpg').toString();
    return expect(layer).toEqual('fetch:aHR0cDovL3Jlcy5jbG91ZGluYXJ5LmNvbS9kZW1vL3NhbXBsZS5qcGc=');
  });
  return it("should support unicode URLs", function() {
    var layer, transformation;
    layer = new FetchLayer("https://upload.wikimedia.org/wikipedia/commons/2/2b/고창갯벌.jpg").toString();
    expect(layer).toEqual("fetch:aHR0cHM6Ly91cGxvYWQud2lraW1lZGlhLm9yZy93aWtpcGVkaWEvY29tbW9ucy8yLzJiLyVFQSVCMyVBMCVFQyVCMCVCRCVFQSVCMCVBRiVFQiVCMiU4Qy5qcGc=");
    transformation = new Transformation().overlay({
      resourceType: 'fetch',
      url: "https://upload.wikimedia.org/wikipedia/commons/2/2b/고창갯벌.jpg"
    });
    return expect(transformation.toString()).toEqual("l_fetch:aHR0cHM6Ly91cGxvYWQud2lraW1lZGlhLm9yZy93aWtpcGVkaWEvY29tbW9ucy8yLzJiLyVFQSVCMyVBMCVFQyVCMCVCRCVFQSVCMCVBRiVFQiVCMiU4Qy5qcGc=");
  });
});

//# sourceMappingURL=layer-spec.js.map
