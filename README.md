Cloudinary
==========

Cloudinary allows web applications to manage web resources in the cloud leveraging cloud-solutions. 
Cloudinary offers a solution to the entire asset management workflow, from upload to transformations, optimizations, storage and delivery.

The direct image upload feature of the plugin is based on https://github.com/blueimp/jQuery-File-Upload 

## Setup ######################################################################

In order to properly use this library you have to provide it a few configuration parameters:

Required:

* `cloud_name` - The cloudinary cloud name you'd like to use

Optional:

* `private_cdn`, `secure_distribution`, `cname`, `cdn_subdomain` - Please refer to [Cloudinary Documentation](http://cloudinary.com/documentation)

To set these configuration parameters use the `$.cloudinary.config` function (see below)

## Usage ######################################################################

The following blog post details the process of setting up jQuery based file upload.
http://cloudinary.com/blog/direct_image_uploads_from_the_browser_to_the_cloud_with_jquery

The Cloudinary Documentation can be found at:
http://cloudinary.com/documentation

* `$.cloudinary.config(parameter_name, parameter_value)` - Sets parameter\_name's value to parameter\_value.
* `$.cloudinary.url(public_id, options)` - Returns a cloudinary URL based on your on your configuration and the given options.
* `$.cloudinary.image(public_id, options)` - Returns a HTML image tag for the photo specified by public\_id
* `$.cloudinary.facebook_profile_image`, `$.cloudinary.twitter_profile_image`, `$.cloudinary.twitter_name_profile_image`, `$.cloudinary.gravatar_image` , `$.cloudinary.fetch_image` - Same like `image` but returns a specific type of image.

* `$(jquery_selector).cloudinary(options)` - Goes over the elements specified by jQuery selector and changes all images to be fetched using Cloudinary's CDN. Using options, you can also specify transformations to the images.

All `options` parameters are similar across all cloudinary frameworks. Please refer to [Rail's integration and using cl_image_tag](http://cloudinary.com/documentation/rails_integration#display_and_transform) for more complete reference regarding the options.

For more information, refer to [Cloudinary Documentation](http://cloudinary.com/documentation)

### Direct file upload with backend support ###################################

The javascript library implements helpers to be used in conjunction with the backend cloudinary frameworks (Rails, PHP, django). These framework can be used to embed a file upload field in the HTML (`cl_image_upload_tag`). When used, the script finds those fields and extend them:

Upon a successful image upload, the script will trigger a jQuery event (`cloudinarydone`) on the input field and provide fileupload data object (along with the `result` key containing received data from cloudinary upload API) as the only argument.

If a `cloudinary-field-name` has been provided with the upload field, the script will find an input field in the form with the given name and updates it post-upload with the image metadata: `<image-path>#<public-id>`. 
If no such field exists a new hidden field will be creates.

## Client side image resizing before upload ###################################
See File Processing Options in https://github.com/blueimp/jQuery-File-Upload/wiki/Options
Add the following javascript includes after the standard fileupload includes:
  
    js/load-image.min.js
    js/canvas-to-blob.min.js
    js/jquery.fileupload-fp.js

Also, add the following javascript:

    $('.cloudinary-fileupload').fileupload('option', 'process', [
      {
          action: 'load',
          fileTypes: /(\.|\/)(gif|jpe?g|png|bmp|ico)$/i,
          maxFileSize: 20000000 // 20MB
      },
      {
          action: 'resize',
          maxWidth: 1920,
          maxHeight: 1200,
          minWidth: 800,
          minHeight: 600
      },
      {
          action: 'save'
      }
    ]);

## License #######################################################################

Released under the MIT license. 
