# Cloudinary

Cloudinary is a cloud service that offers a solution to a web application's entire image management pipeline.

Easily upload images to the cloud. Automatically perform smart image resizing, cropping and conversion without installing any complex software. Integrate Facebook or Twitter profile image extraction in a snap, in any dimension and style to match your website’s graphics requirements. Images are seamlessly delivered through a fast CDN, and much much more.

Cloudinary offers comprehensive APIs and administration capabilities and is easy to integrate with any web application, existing or new.

Cloudinary provides URL and HTTP based APIs that can be easily integrated with any Web development framework.

For Javascript, Cloudinary provides a jQuery plugin for simplifying the integration even further.

The direct image upload feature of the plugin is based on https://github.com/blueimp/jQuery-File-Upload

## Getting started guide

![](http://res.cloudinary.com/cloudinary/image/upload/see_more_bullet.png)  **Take a look at our [Getting started guide for jQuery](http://cloudinary.com/documentation/jquery_integration#getting_started_guide)**.

## New API!

The version 2.0.0 release refactors the Cloudinary JavaScript library, and the biggest news is that the newly introduced Core Library is jQuery-independent. The source code has been converted into CoffeeScript and rearranged into classes, and a new build script based on Grunt has been added. The build process produces 3 artifacts:

  * A Core Library that is not dependent on jQuery
  * A jQuery plugin that includes the Core Library
  * A Blueimp plugin that includes the jQuery plugin and the Core Library
  
In order to publish these libraries in bower and NPM, 3 new Github repositories have been created:

    +------------------------------------+-------------------------------+
    | Repository                         | Package name                  |
    +------------------------------------+-------------------------------+
    |  pkg-cloudinary-core               | cloudinary-core               |
    |  pkg-cloudinary-jquery             | cloudinary-jquery             |
    |  pkg-cloudinary-jquery-file-upload | cloudinary-jquery-file-upload | 
    +------------------------------------+-------------------------------+

The same package names are used in both bower and NPM.

## Backward compatibility
The cloudinary-jquery-file-upload library is fully backwards compatible with the cloudinary_js library v1.0.25. 
The relevant Blueimp files can still be found in the `js` folder for backward compatibility. If you rely on the Blueimp 
files located in the repository’s `js` folder, make sure to update your links to `load-image.all.min.js` which replaces `load-image.min.js` from previous versions. 
However, we encourage developers to use a dependency manager such as bower or NPM to install the 3rd party libraries, and not to rely on the files in the `js` folder.
 
#### Core Javascript library
The core Cloudinary JavaScript library which does not depend on jQuery: [https://github.com/cloudinary/pkg-cloudinary-core](https://github.com/cloudinary/pkg-cloudinary-core).

#### jQuery plugin
If you are using jQuery, you can take advantage of the Cloudinary jQuery plugin at [https://github.com/cloudinary/pkg-cloudinary-jquery](https://github.com/cloudinary/pkg-cloudinary-jquery).
This library include all the functionality of the Core JavaScript Library.

#### jQuery File upload
The Cloudinary jQuery File Upload library extends the Cloudinary jQuery plugin that utilizes the [Blueimp jQuery File Upload library](https://blueimp.github.io/jQuery-File-Upload/) is located at https://github.com/cloudinary/pkg-cloudinary-jquery-file-upload.
This library include all the functionality of the Core JavaScript Library and the jQuery plugin.

## Installation

### bower

1. Install the files using the following command. Add the optional `--save` parameter if you wish to save the dependency in your bower.json file.

    ```shell
    # one of the following:
    bower install cloudinary-core                    # for the core javascript library  
    bower install cloudinary-jquery                  # for the jQuery plugin
    bower install cloudinary-jquery-file-upload      # for the jQuery file upload
    ```
1. Include the javascript file in your HTML. For Example:

    ```html
    <script src="../bower_components/cloudinary-core/cloudinary-core.js"></script>
    <script src="../bower_components/cloudinary-jquery/cloudinary-jquery.js"></script>
    <script src="../bower_components/cloudinary-jquery-file-upload/cloudinary-jquery-file-upload.js"></script>
    
    ```

### NPM*

1. Install the files using the following command

    ```shell
    # one of the following:
    npm install cloudinary-core                    # for the core javascript library 
    npm install cloudinary-jquery                  # for the jQuery plugin
    npm install cloudinary-jquery-file-upload      # for the jQuery File Upload plugin
    ```
1. Include the javascript file in your HTML. For Example:

    ```html
    <script src="../node_modules/cloudinary-core/cloudinary-core.js"></script>
    <script src="../node_modules/cloudinary-jquery/cloudinary-jquery.js"></script>
    <script src="../node_modules/cloudinary-jquery-file-upload/cloudinary-jquery-file-upload.js"></script>
    ```

\* For the server side NodeJS library, see https://github.com/cloudinary/cloudinary_npm

## Setup

In order to properly use this library you have to provide it with a few configuration parameters:

Required:

* `cloud_name` - The cloudinary cloud name associated with your Cloudinary account.

Optional:

* `private_cdn`, `secure_distribution`, `cname`, `cdn_subdomain` - Please refer to [Cloudinary Documentation](http://cloudinary.com/documentation/rails_additional_topics#configuration_options) for information on these parameters.

To set these configuration parameters use the `Cloudinary::config` function (see below).

Note:

When loading the jQuery Cloudinary library directly (using a `script` tag), the library automatically converts the relevant fileupload tags to utilize the upload functionality. If jquery.cloudinary is loaded as an [AMD](https://github.com/amdjs/amdjs-api/blob/master/AMD.md) however, you need to initialize the Cloudinary fileupload fields e.g., by calling `$("input.cloudinary-fileupload[type=file]").cloudinary_fileupload();`

## Usage

The following blog post details the process of setting up a jQuery based file upload.
http://cloudinary.com/blog/direct_image_uploads_from_the_browser_to_the_cloud_with_jquery

The Cloudinary Documentation can be found at:
http://cloudinary.com/documentation

### Core JavaScript library

The Core Cloudinary JavaScript library provides several classes, defined under the "`cloudinary`" domain.

#### Configuration

Start by instantiating a new Cloudinary class:

##### Explicitly

```javascript
var cl = cloudinary.Cloudinary.new( { cloud_name: "demo"});
```

##### Using the config function

```javascript
// Using the config function
var cl = cloudinary.Cloudinary.new();
cl.config( "cloud_name", "demo");
```

##### From meta tags in the current HTML document

When using the library in a browser environment, you can use meta tags to define the configuration options.

The `init()` function is a convenience function that invokes both `fromDocument()` and `fromEnvironment()`.


For example, add the following to the header tag:
```html
<meta name="cloudinary_cloud_name" content="demo">
```

In your JavaScript source, invoke `fromDocument()`:
```javascript
var cl = cloudinary.Cloudinary.new();
cl.fromDocument();
// or
cl.init();
```

##### From environment variables

When using the library in a backend environment such as NodeJS, you can use an environment variable to define the configuration options.

Set the environment variable, for example:
```shell
export CLOUDINARY_URL=cloudinary://demo
```

In your JavaScript source, invoke `fromEnvironment()`:
```javascript
var cl = cloudinary.Cloudinary.new();
cl.fromEnvironment();
// or
cl.init();
```

#### URL generation


```javascript
cl.url("sample")
// "http://res.cloudinary.com/demo/image/upload/sample"

cl.url( "sample", { width: 100, crop: "fit"})
// "http://res.cloudinary.com/demo/image/upload/c_fit,w_100/sample"
```

#### HTML tag generation

You can generate HTML tags in several ways:

`Cloudinary::image()` generates a DOM tag, and prepares it for responsive functionality. This is the same functionality as `$.cloudinary.image()`. (When using the jQuery plugin, the `src-cache` data attribute is stored using jQuery's `data()` method and so is not visible.)

```javascript
cl.image("sample")
```
produces:
```html
<img src=​"http:​/​/​res.cloudinary.com/​demo/​image/​upload/​sample" data-src-cache=​"http:​/​/​res.cloudinary.com/​demo/​image/​upload/​sample">​
```

You can generate an image Tag using the `imageTag` function:

```javascript
var tag = cl.imageTag("sample");
tag.toHtml();
```
which produces:
```html
<img src="http://res.cloudinary.com/demo/image/upload/sample">
```
and:
```javascript
tag.transformation().crop("fit").width(100).toHtml();
```
which produces:
```html
<img src="http://res.cloudinary.com/demo/image/upload/c_fit,w_100/sample">
```

You can also use `ImageTag` independently:

```javascript
var tag = cloudinary.ImageTag.new( "sample", { cloud_name: "some_other_cloud" });
tag.toHtml();
```
which produces:
```html
<img src="http://res.cloudinary.com/some_other_cloud/image/upload/sample">
```


#### Transformation

In addition to using a plain object to define transformations or using the builder methods (both described above), you can define transformations by using the Transformation class:

```javascript
var tr = cloudinary.Transformation.new();
tr.crop("fit").width(100);
tr.serialize()
// "c_fit,w_100"
```

You can also chain transformations together:

```javascript
var tr = cloudinary.Transformation.new();
tr.width(10).crop('fit').chain().angle(15).serialize()
// "c_fit,w_10/a_15"
```

### jQuery plugin

The Cloudinary jQuery plugin is fully backward compatible with the previous cloudinary_js version.
Under the hood, the new JavaScript library instantiates a CloudinaryJQuery object and attaches it to jQuery.

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
Add the following javascript includes after the standard fileupload includes:

```    
"bower_components/blueimp-load-image/js/load-image.all.min.js"
"bower_components/blueimp-canvas-to-blob/js/canvas-to-blob.min.js"
"bower_components/blueimp-file-upload/js/jquery.fileupload-process.js"
"bower_components/blueimp-file-upload/js/jquery.fileupload-image.js"
"bower_components/blueimp-file-upload/js/jquery.fileupload-validate.js"
```

Also, add the following javascript:

```javascript
$(document).ready(function() {
  $('.cloudinary-fileupload').fileupload({
    disableImageResize: false,
    imageMaxWidth: 800,                            // 800 is an example value
    imageMaxHeight: 600,                           // 600 is an example value
    acceptFileTypes: /(\.|\/)(gif|jpe?g|png|bmp|ico)$/i,
    maxFileSize: 20000000,                        // 20MB is an example value
    loadImageMaxFileSize: 20000000        // default is 10MB
  });
});
```
## Angular Directives

Joshua Chaitin-Pollak contributed AngularJS directives for Cloudinary:
Display and manipulate images and perform uploads from your Angular application.

The Angular module is currently maintained as a separate GitHub project:

https://github.com/cloudinary/cloudinary_angular

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

Contact us at [http://cloudinary.com/contact](http://cloudinary.com/contact).

Stay tuned for updates, tips and tutorials: [Blog](http://cloudinary.com/blog), [Twitter](https://twitter.com/cloudinary), [Facebook](http://www.facebook.com/Cloudinary).


## License

Released under the MIT license.

