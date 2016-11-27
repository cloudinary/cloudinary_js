describe('cloudinary', function() {
  var fixtureContainer;
  fixtureContainer = void 0;
  beforeEach(function() {
    $.cloudinary = new cloudinary.CloudinaryJQuery({
      cloud_name: 'test123'
    });
    fixtureContainer = $('<div id="fixture">');
    return fixtureContainer.appendTo('body');
  });
  afterEach(function() {
    return fixtureContainer.remove();
  });
  return it('should create an unsigned upload tag', function() {
    var options, result;
    $.cloudinary.config('cloud_name', 'test');
    result = $.cloudinary.unsigned_upload_tag('test', {
      context: {
        alt: 'alternative|alt',
        caption: 'cap=caps'
      },
      tags: ['a', 'b']
    }, {
      width: 100,
      cloud_name: 'test1',
      multiple: true
    });
    options = result.fileupload('option');
    expect(options.formData.context).toEqual('alt=alternative\\|alt|caption=cap\\=caps');
    expect(options.formData.tags).toEqual('a,b');
    expect(options.formData.upload_preset).toEqual('test');
    expect(options.width).toEqual(100);
    expect(options.url).toEqual('https://api.cloudinary.com/v1_1/test1/auto/upload');
    expect(result.prop('multiple')).toEqual(true);
    result = $.cloudinary.unsigned_upload_tag('test', {
      context: {
        alt: 'alternative',
        caption: 'cap'
      },
      tags: ['a', 'b'],
      cloud_name: 'test2'
    }, {
      width: 100,
      multiple: true
    });
    options = result.fileupload('option');
    expect(options.url).toEqual('https://api.cloudinary.com/v1_1/test2/auto/upload');
    result = $.cloudinary.unsigned_upload_tag('test', {
      cloud_name: 'test2',
      resource_type: 'video',
      type: 'private'
    }, {
      width: 100,
      multiple: true
    });
    options = result.fileupload('option');
    return expect(options.url).toEqual('https://api.cloudinary.com/v1_1/test2/video/private');
  });
});

//# sourceMappingURL=cloudinary-jquery-upload-spec.js.map
