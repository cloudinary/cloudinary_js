/**
 * techVersion is the techVersion of the framework
 * sdkSemver is the version of the Cloudinary SDK
 * feature is responsive || a11y || lazy || placeholder
 * sdkCode is letter associated with Cloudinary SDK
 */
describe('Tests for sdk versionID util', function () {
  it('should not append analytics if false', function () {
    cl = cloudinary.Cloudinary.new({cloud_name: 'sdk-test', analytics: false});

    let img = cl.url("sample", {techVersion: '12.0.0', sdkSemver: '1.24.0', sdkCode: 'M'});

    expect(img).toEqual('http://res.cloudinary.com/sdk-test/image/upload/sample');
  });
  it('creates the correct sdk versionID x.y.z', function () {
    cl = cloudinary.Cloudinary.new({cloud_name: 'sdk-test', analytics: true});

    let img = cl.url("sample", {techVersion: '12.0.0', sdkSemver: '1.24.0', sdkCode: 'M'});
    expect(img).toEqual('http://res.cloudinary.com/sdk-test/image/upload/sample?_s=MAlhAM0');
  });
  it('creates the correct sdk versionID', function () {
    cl = cloudinary.Cloudinary.new({cloud_name: 'sdk-test', analytics: true});
    // Sanity check taken from node
    let img = cl.url("sample", {techVersion: '12.0', sdkSemver: '1.24.0', sdkCode: 'M'});
    expect(img).toEqual('http://res.cloudinary.com/sdk-test/image/upload/sample?_s=MAlhAM0');

    img = cl.url("sample", {techVersion: '43.21.26', sdkSemver: '43.21.26', sdkCode: 'M'});
    expect(img).toEqual('http://res.cloudinary.com/sdk-test/image/upload/sample?_s=M///hf0');

    img = cl.url("sample", {techVersion: '0.0.0', sdkSemver: '0.0.0', sdkCode: 'M'});
    expect(img).toEqual('http://res.cloudinary.com/sdk-test/image/upload/sample?_s=MAAAAA0');

    img = cl.url("sample", {techVersion: '1.2.0', sdkSemver: '6.1.0', loading: 'lazy', sdkCode: 'K'});
    console.log('imgggg', img);
    expect(img).toEqual('http://res.cloudinary.com/sdk-test/image/upload/sample?_s=KABqDJC');
  });
  it('Handles invalid arguments gracefully', function () {
    cl = cloudinary.Cloudinary.new({cloud_name: 'sdk-test', analytics: true});

    let img = cl.url("sample", {techVersion: 'abcdefg', sdkSemver: 'abcdefg', sdkCode: 'M'});

    expect(img).toEqual('http://res.cloudinary.com/sdk-test/image/upload/sample?_s=E');
  });
});
