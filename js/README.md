# Cloudinary Client Side Jquery Library
This folder contains a backup of cloudinary-jquery version 2.5.0, with minor fixes.
It also contains several jquery plugins that can be used for client-side upload.
### Please Do not make any changes.  
The files in this folder are used by several server-side sdks such as Ruby and Python SDKS.

### Backward compatibility
The cloudinary-jquery-file-upload library is fully backwards compatible with the cloudinary_js library `v1.0.25`.
The relevant Blueimp files can still be found in the `js` folder for backward compatibility. If you rely on the Blueimp 
files located in the repository’s `js` folder, make sure to update your links to `load-image.all.min.js` which replaces `load-image.min.js` from previous versions. 
However, we encourage developers to use a dependency manager such as NPM to install the 3rd party libraries, and not to rely on the files in the `js` folder.

### jQuery plugin

The Cloudinary jQuery plugin is fully backward compatible with the previous cloudinary_js version.
Under the hood, the new JavaScript library instantiates a `CloudinaryJQuery` object and attaches it to jQuery.

* `$.cloudinary.config(parameter_name, parameter_value)` - Sets parameter\_name's value to parameter\_value.
* `$.cloudinary.url(public_id, options)` - Returns a cloudinary URL based on your configuration and the given options.
* `$.cloudinary.image(public_id, options)` - Returns an HTML image tag for the photo specified by public\_id
* `$.cloudinary.facebook_profile_image`, `$.cloudinary.twitter_profile_image`, `$.cloudinary.twitter_name_profile_image`, `$.cloudinary.gravatar_image` , `$.cloudinary.fetch_image` - Same as `image` but returns a specific type of image.

* `$(jquery_selector).cloudinary(options)` - Goes over the elements specified by the jQuery selector and changes all the images to be fetched using Cloudinary's CDN. Using the `options` parameter, you can also specify transformations to the images which use  similar syntax across all cloudinary frameworks. Please refer to [jQuery image manipulation](http://cloudinary.com/documentation/jquery_image_manipulation) for a more complete reference regarding the options.

![](http://res.cloudinary.com/cloudinary/image/upload/see_more_bullet.png) **See [our documentation](http://cloudinary.com/documentation/jquery_image_manipulation) for more information about displaying and transforming images using jQuery**.                                         

### Direct file upload with backend support

The javascript library implements helpers to be used in conjunction with the backend cloudinary frameworks (Rails, PHP, django). These frameworks can be used to embed a file upload field in the HTML (`cl_image_upload_tag`). When used, the script finds these fields and extends them as follows:

* Upon a successful image upload, the script will trigger a jQuery event (`cloudinarydone`) on the input field and provide a fileupload data object (along with the `result` key containing received data from the cloudinary upload API) as the only argument.
* If a `cloudinary-field-name` has been provided with the upload field, the script will find an input field in the form with the given name and update it post-upload with the image metadata: `<image-path>#<public-id>`.
* If no such field exists a new hidden field will be created.

![](http://res.cloudinary.com/cloudinary/image/upload/see_more_bullet.png) **See [our documentation](http://cloudinary.com/documentation/jquery_image_upload) with plenty more options for uploading to the cloud directly from the browser**.

## Client side image resizing before upload

See the File Processing Options in https://github.com/blueimp/jQuery-File-Upload/wiki/Options.
Modify your script tags based on the the following example (order is important!):

```    
<script src="node_modules/jquery/dist/jquery.js" type="text/javascript"></script>
<script src="node_modules/jquery.ui/ui/widget.js" type="text/javascript"></script>
<script src="node_modules/blueimp-load-image/js/load-image.all.min.js"></script>
<script src="node_modules/blueimp-canvas-to-blob/js/canvas-to-blob.min.js"></script>
<script src="node_modules/blueimp-file-upload/js/jquery.iframe-transport.js" type="text/javascript"></script>
<script src="node_modules/blueimp-file-upload/js/jquery.fileupload.js" type="text/javascript"></script>
<script src="node_modules/blueimp-file-upload/js/jquery.fileupload-process.js"></script>
<script src="node_modules/blueimp-file-upload/js/jquery.fileupload-image.js" type="text/javascript"></script>
<script src="node_modules/blueimp-file-upload/js/jquery.fileupload-validate.js"></script>
<script src="node_modules/cloudinary-jquery-file-upload/cloudinary-jquery-file-upload.js" type="text/javascript"></script>
```

Also, add the following javascript:

```javascript
$(document).ready(function() {
  $('.cloudinary-fileupload').cloudinary_fileupload({
    disableImageResize: false,
    imageMaxWidth: 800,                           // 800 is an example value
    imageMaxHeight: 600,                          // 600 is an example value
    maxFileSize: 20000000,                        // 20MB is an example value
    loadImageMaxFileSize: 20000000,               // default is 10MB
    acceptFileTypes: /(\.|\/)(gif|jpe?g|png|bmp|ico)$/i
  });
});
```

Additional resources are available at:

* [Website](http://cloudinary.com)
* [Documentation](http://cloudinary.com/documentation)
* [Knowledge Base](http://support.cloudinary.com/forums)
* [Documentation for jQuery integration](http://cloudinary.com/documentation/jquery_integration)
* [jQuery image upload documentation](http://cloudinary.com/documentation/jquery_image_upload)
* [jQuery image manipulation documentation](http://cloudinary.com/documentation/jquery_image_manipulation)
* [Image transformations documentation](http://cloudinary.com/documentation/image_transformations)

## Support

You can [open an issue through GitHub](https://github.com/cloudinary/cloudinary_js/issues).

Contact us at [http://cloudinary.com/contact](http://cloudinary.com/contact).

Stay tuned for updates, tips and tutorials: [Blog](http://cloudinary.com/blog), [Twitter](https://twitter.com/cloudinary), [Facebook](http://www.facebook.com/Cloudinary).

## Join the Community ##########################################################

Impact the product, hear updates, test drive new features and more! Join [here](https://www.facebook.com/groups/CloudinaryCommunity).


## License

Released under the MIT license.

The direct image upload feature of the plugin is based on https://github.com/blueimp/jQuery-File-Upload
