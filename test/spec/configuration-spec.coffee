refresh = (name)->
  delete require.cache[require.resolve(name)]
  require(name)

describe 'Configuration', ->
  describe "CLOUDINARY_URL environment variable", ->
    beforeAll ->

    it "should support api_key, api_secret, cloud_name", ->
      process?.env['CLOUDINARY_URL'] = 'cloudinary://key:secret@cloudname'

      cloudinary.Configuration = refresh('../build/cloudinary-core').Configuration
      config = new cloudinary.Configuration()
      config.fromEnvironment()
      expect(config.get("cloud_name")).toEqual("cloudname")
      expect(config.get("api_key")).toEqual("key")
      expect(config.get("api_secret")).toEqual("secret")
      process?.env.CLOUDINARY_URL = 'cloudinary://key@cloudname'
      cloudinary.Configuration = refresh('../build/cloudinary-core').Configuration
      config = new cloudinary.Configuration()
      config.fromEnvironment()
      expect(config.get("cloud_name")).toEqual("cloudname")
      expect(config.get("api_key")).toEqual("key")
      expect(config.get("api_secret")).toEqual(undefined)

    it "should support additional parameters", ->
      process?.env.CLOUDINARY_URL = 'cloudinary://key:secret@cloudname?foo=bar&one=two'
      cloudinary.Configuration = refresh('../build/cloudinary-core').Configuration
      config = new cloudinary.Configuration()
      config.fromEnvironment()
      expect(config.get("cloud_name")).toEqual("cloudname")
      expect(config.get("api_key")).toEqual("key")
      expect(config.get("api_secret")).toEqual("secret")
      expect(config.get("foo")).toEqual("bar")
      expect(config.get("one")).toEqual("two")

    it "should support secure_distribution", ->
      process?.env.CLOUDINARY_URL = 'cloudinary://key:secret@cloudname/private_cdn?foo=bar&one=two'
      cloudinary.Configuration = refresh('../build/cloudinary-core').Configuration
      config = new cloudinary.Configuration()
      config.fromEnvironment()
      expect(config.get("cloud_name")).toEqual("cloudname")
      expect(config.get("api_key")).toEqual("key")
      expect(config.get("api_secret")).toEqual("secret")
      expect(config.get("foo")).toEqual("bar")
      expect(config.get("one")).toEqual("two")
      expect(config.get("private_cdn")).toBeTruthy()
      expect(config.get("secure_distribution")).toEqual("private_cdn")
      process?.env.CLOUDINARY_URL = 'cloudinary://key@cloudname/private_cdn?foo=bar&one=two'
      cloudinary.Configuration = refresh('../build/cloudinary-core').Configuration
      config = new cloudinary.Configuration()
      config.fromEnvironment()
      expect(config.get("cloud_name")).toEqual("cloudname")
      expect(config.get("api_key")).toEqual("key")
      expect(config.get("api_secret")).toEqual(undefined)
      expect(config.get("foo")).toEqual("bar")
      expect(config.get("one")).toEqual("two")
      expect(config.get("private_cdn")).toBeTruthy()
      expect(config.get("secure_distribution")).toEqual("private_cdn")

