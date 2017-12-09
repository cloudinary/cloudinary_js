TextLayer = cloudinary.TextLayer
FetchLayer = cloudinary.FetchLayer
describe "TextLayer", ->
  it "should serialize a text layer object", ->
    options =
      text: "Cloudinary for the win!",
      fontFamily: "Arial",
      fontSize: 18
    layer = new TextLayer(options)
    expect(layer.textStyleIdentifier()).toEqual("Arial_18")
    expect(layer.toString()).toEqual("text:Arial_18:Cloudinary%20for%20the%20win%21")
    transformation = new Transformation().overlay(options).toString()
    expect(transformation.toString()).toEqual("l_text:Arial_18:Cloudinary%20for%20the%20win%21")
    
describe "FetchLayer", ->
  it "should serialize a fetch url layer", ->
    layer = new FetchLayer({url: 'http://res.cloudinary.com/demo/sample.jpg'}).toString()
    expect(layer).toEqual('fetch:aHR0cDovL3Jlcy5jbG91ZGluYXJ5LmNvbS9kZW1vL3NhbXBsZS5qcGc=')
  it "should accept a url in the constructor", ->
    layer = new FetchLayer('http://res.cloudinary.com/demo/sample.jpg').toString()
    expect(layer).toEqual('fetch:aHR0cDovL3Jlcy5jbG91ZGluYXJ5LmNvbS9kZW1vL3NhbXBsZS5qcGc=')
  it "should support unicode URLs", ->
    layer = new FetchLayer("https://upload.wikimedia.org/wikipedia/commons/2/2b/고창갯벌.jpg").toString()
    expect(layer).toEqual("fetch:aHR0cHM6Ly91cGxvYWQud2lraW1lZGlhLm9yZy93aWtpcGVkaWEvY29tbW9ucy8yLzJiLyVFQSVCMyVBMCVFQyVCMCVCRCVFQSVCMCVBRiVFQiVCMiU4Qy5qcGc=")
    transformation = new Transformation().overlay(
      resourceType: 'fetch'
      url: "https://upload.wikimedia.org/wikipedia/commons/2/2b/고창갯벌.jpg"
    )
    expect(transformation.toString()).toEqual("l_fetch:aHR0cHM6Ly91cGxvYWQud2lraW1lZGlhLm9yZy93aWtpcGVkaWEvY29tbW9ucy8yLzJiLyVFQSVCMyVBMCVFQyVCMCVCRCVFQSVCMCVBRiVFQiVCMiU4Qy5qcGc=")
    