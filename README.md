Cloudinary
==========

Cloudinary is a cloud service that offers a solution to a web application's entire image management pipeline. 

Easily upload images to the cloud. Automatically perform smart image resizing, cropping and conversion without installing any complex software. Integrate Facebook or Twitter profile image extraction in a snap, in any dimension and style to match your website’s graphics requirements. Images are seamlessly delivered through a fast CDN, and much much more. 

Cloudinary offers comprehensive APIs and administration capabilities and is easy to integrate with any web application, existing or new.

Cloudinary provides URL and HTTP based APIs that can be easily integrated with any Web development framework. 

For Javascript, Cloudinary provides a jQuery plugin for simplifying the integration even further.

The direct image upload feature of the plugin is based on https://github.com/blueimp/jQuery-File-Upload 

## Getting started guide
![](http://res.cloudinary.com/cloudinary/image/upload/see_more_bullet.png)  **Take a look at our [Getting started guide for jQuery](http://cloudinary.com/documentation/jquery_integration#getting_started_guide)**.


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

![](http://res.cloudinary.com/cloudinary/image/upload/see_more_bullet.png) **See [our documentation](http://cloudinary.com/documentation/jquery_image_manipulation) for more information about displaying and transforming images using jQuery**.                                         

### Direct file upload with backend support ###################################

The javascript library implements helpers to be used in conjunction with the backend cloudinary frameworks (Rails, PHP, django). These framework can be used to embed a file upload field in the HTML (`cl_image_upload_tag`). When used, the script finds those fields and extend them:

Upon a successful image upload, the script will trigger a jQuery event (`cloudinarydone`) on the input field and provide fileupload data object (along with the `result` key containing received data from cloudinary upload API) as the only argument.

If a `cloudinary-field-name` has been provided with the upload field, the script will find an input field in the form with the given name and updates it post-upload with the image metadata: `<image-path>#<public-id>`. 
If no such field exists a new hidden field will be creates.

![](http://res.cloudinary.com/cloudinary/image/upload/see_more_bullet.png) **See [our documentation](http://cloudinary.com/documentation/jquery_image_upload) for plenty more options of uploading to the cloud directly from the browser**.

## Client side image resizing before upload ###################################
See File Processing Options in https://github.com/blueimp/jQuery-File-Upload/wiki/Options
Add the following javascript includes after the standard fileupload includes:
  
    js/load-image.min.js
    js/canvas-to-blob.min.js
    js/jquery.fileupload-process.js
    js/jquery.fileupload-image.js
    js/jquery.fileupload-validate.js
    
Also, add the following javascript:

    $(document).ready(function() {
      $('.cloudinary-fileupload').fileupload({
        disableImageResize: false,
        imageMaxWidth: 800,
        imageMaxHeight: 600,
        acceptFileTypes: /(\.|\/)(gif|jpe?g|png|bmp|ico)$/i,
        maxFileSize: 20000000 // 20MB
      });
    });

## Angular Directives

Joshua Chaitin-Pollak contributed AngularJS directives for Cloudinary: 
displaying & manipulating images and performing uploads from your Angular application.

The Angular module is currently maintained as a separate GitHub project:

https://github.com/jbcpollak/cloudinary_angular

## Additional resources

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

Contact us [http://cloudinary.com/contact](http://cloudinary.com/contact)

Stay tuned for updates, tips and tutorials: [Blog](http://cloudinary.com/blog), [Twitter](https://twitter.com/cloudinary), [Facebook](http://www.facebook.com/Cloudinary).


## License #######################################################################

Released under the MIT license. 
