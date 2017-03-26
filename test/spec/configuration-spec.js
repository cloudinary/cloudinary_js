var refresh;

refresh = function(name) {
  delete require.cache[require.resolve(name)];
  return require(name);
};

describe('Configuration', function() {
  return describe("CLOUDINARY_URL environment variable", function() {
    beforeAll(function() {});
    it("should support api_key, api_secret, cloud_name", function() {
      var config;
      if (typeof process !== "undefined" && process !== null) {
        process.env['CLOUDINARY_URL'] = 'cloudinary://key:secret@cloudname';
      }
      cloudinary.Configuration = refresh('../build/cloudinary-core').Configuration;
      config = new cloudinary.Configuration();
      config.fromEnvironment();
      expect(config.get("cloud_name")).toEqual("cloudname");
      expect(config.get("api_key")).toEqual("key");
      expect(config.get("api_secret")).toEqual("secret");
      if (typeof process !== "undefined" && process !== null) {
        process.env.CLOUDINARY_URL = 'cloudinary://key@cloudname';
      }
      cloudinary.Configuration = refresh('../build/cloudinary-core').Configuration;
      config = new cloudinary.Configuration();
      config.fromEnvironment();
      expect(config.get("cloud_name")).toEqual("cloudname");
      expect(config.get("api_key")).toEqual("key");
      return expect(config.get("api_secret")).toEqual(void 0);
    });
    it("should support additional parameters", function() {
      var config;
      if (typeof process !== "undefined" && process !== null) {
        process.env.CLOUDINARY_URL = 'cloudinary://key:secret@cloudname?foo=bar&one=two';
      }
      cloudinary.Configuration = refresh('../build/cloudinary-core').Configuration;
      config = new cloudinary.Configuration();
      config.fromEnvironment();
      expect(config.get("cloud_name")).toEqual("cloudname");
      expect(config.get("api_key")).toEqual("key");
      expect(config.get("api_secret")).toEqual("secret");
      expect(config.get("foo")).toEqual("bar");
      return expect(config.get("one")).toEqual("two");
    });
    return it("should support secure_distribution", function() {
      var config;
      if (typeof process !== "undefined" && process !== null) {
        process.env.CLOUDINARY_URL = 'cloudinary://key:secret@cloudname/private_cdn?foo=bar&one=two';
      }
      cloudinary.Configuration = refresh('../build/cloudinary-core').Configuration;
      config = new cloudinary.Configuration();
      config.fromEnvironment();
      expect(config.get("cloud_name")).toEqual("cloudname");
      expect(config.get("api_key")).toEqual("key");
      expect(config.get("api_secret")).toEqual("secret");
      expect(config.get("foo")).toEqual("bar");
      expect(config.get("one")).toEqual("two");
      expect(config.get("private_cdn")).toBeTruthy();
      expect(config.get("secure_distribution")).toEqual("private_cdn");
      if (typeof process !== "undefined" && process !== null) {
        process.env.CLOUDINARY_URL = 'cloudinary://key@cloudname/private_cdn?foo=bar&one=two';
      }
      cloudinary.Configuration = refresh('../build/cloudinary-core').Configuration;
      config = new cloudinary.Configuration();
      config.fromEnvironment();
      expect(config.get("cloud_name")).toEqual("cloudname");
      expect(config.get("api_key")).toEqual("key");
      expect(config.get("api_secret")).toEqual(void 0);
      expect(config.get("foo")).toEqual("bar");
      expect(config.get("one")).toEqual("two");
      expect(config.get("private_cdn")).toBeTruthy();
      return expect(config.get("secure_distribution")).toEqual("private_cdn");
    });
  });
});

//# sourceMappingURL=configuration-spec.js.map
