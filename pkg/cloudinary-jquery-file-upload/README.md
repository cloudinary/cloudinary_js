[![Build Status](https://travis-ci.org/cloudinary/cloudinary_js.svg?branch=master)](https://travis-ci.org/cloudinary/cloudinary_js) [![npm](https://img.shields.io/npm/v/cloudinary-jquery-file-upload.svg?maxAge=2592000)]() [![Bower](https://img.shields.io/bower/v/cloudinary-jquery-file-upload.svg?maxAge=2592000)]() [![license](https://img.shields.io/github/license/cloudinary/pkg-cloudinary-jquery-file-upload.svg?maxAge=2592000)]()

This is a distribution repository for `bower` and `npm`. The sources for this repository are maintained at the [cloudinary_js repository](https://github.com/cloudinary/cloudinary_js). Please submit issues and pull requests to that repository.

# Cloudinary jQuery Plugin with file upload - bower and npm repository

Cloudinary is a cloud service that offers a solution to a web application's entire image management pipeline.

Easily upload images to the cloud. Automatically perform smart image resizing, cropping and conversion without installing any complex software. Integrate Facebook or Twitter profile image extraction in a snap, in any dimension and style to match your website’s graphics requirements. Images are seamlessly delivered through a fast CDN, and much much more.

Cloudinary offers comprehensive APIs and administration capabilities and is easy to integrate with any web application, existing or new.

Cloudinary provides URL and HTTP based APIs that can be easily integrated with any Web development framework.

For Javascript, Cloudinary provides a jQuery plugin for simplifying the integration even further.

The direct image upload feature of the plugin is based on https://github.com/blueimp/jQuery-File-Upload

## Getting started guide

![](http://res.cloudinary.com/cloudinary/image/upload/see_more_bullet.png)  **Take a look at our [Getting started guide for jQuery](http://cloudinary.com/documentation/jquery_integration#getting_started_guide)**.

## Installation

### bower

1. Install the files using the following command. Use the optional `--save` parameter if you wish to save the dependency in your bower.json file.

   ```shell
   bower install cloudinary-jquery-file-upload
   ```

1. Include the javascript file in your HTML. For Example:

   ```html
   <script src="bower_components/jquery/dist/jquery.js"                                          type="text/javascript"></script>
   <script src="bower_components/blueimp-file-upload/js/vendor/jquery.ui.widget.js"              type="text/javascript"></script>
   <script src="bower_components/blueimp-file-upload/js/jquery.iframe-transport.js"              type="text/javascript"></script>
   <script src="bower_components/blueimp-file-upload/js/jquery.fileupload.js"                    type="text/javascript"></script>

   <script src="bower_components/cloudinary-jquery-file-upload/cloudinary-jquery-file-upload.js" type="text/javascript"></script>
   ```

### NPM

1. Install the files using the following commands. Use the optional `--save` parameter if you wish to save the dependency in your `package.json` file.

   ```shell
   npm install jquery
   npm install blueimp-file-upload
   npm install cloudinary-jquery-file-upload
   ```
1. Include the javascript file in your HTML. For Example:

   ```html
   <script src="node_modules/jquery/dist/jquery.js"                                          type="text/javascript"></script>
   <script src="node_modules/blueimp-file-upload/js/vendor/jquery.ui.widget.js"              type="text/javascript"></script>
   <script src="node_modules/blueimp-file-upload/js/jquery.iframe-transport.js"              type="text/javascript"></script>
   <script src="node_modules/blueimp-file-upload/js/jquery.fileupload.js"                    type="text/javascript"></script>

   <script src="node_modules/cloudinary-jquery-file-upload/cloudinary-jquery-file-upload.js"></script>
   ```

For the server side NPM library, refer to https://github.com/cloudinary/cloudinary_npm.

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

### Cloudinary JavaScript library

The Cloudinary JavaScript library API reference can be found at: [https://cloudinary.github.io/pkg-cloudinary-jquery-file-upload](https://cloudinary.github.io/pkg-cloudinary-jquery-file-upload)

The Cloudinary JavaScript library provides several classes, defined under the "`cloudinary`" domain.

#### Configuration

Start by instantiating a new Cloudinary class:

##### As jQuery plugin

An instance of the Cloudinary jQuery main class, `CloudinaryJQuery`, is instantiated as `$.cloudinary`.

```javascript
$.cloudinary.config({ cloud_name: "demo"});
```

##### Explicitly

```javascript
var cl = cloudinary.CloudinaryJQuery.new( { cloud_name: "demo"});
```

##### Using the config function

```javascript

// Using the config function
var cl = cloudinary.CloudinaryJQuery.new();
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
<img src=​"http:​/​/​res.cloudinary.com/​demo/​image/​upload/​sample">​
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

This Cloudinary jQuery plugin is fully backward compatible with the previous [cloudinary_js](https://github.com/cloudinary/cloudinary_js) version.
When loaded, the new JavaScript library instantiates a CloudinaryJQuery object and attaches it to jQuery.

The following list includes a sample of the API provided by this library:

* `$.cloudinary.config(parameter_name, parameter_value)` - Sets parameter\_name's value to parameter\_value.
* `$.cloudinary.url(public_id, options)` - Returns a cloudinary URL based on your configuration and the given options.
* `$.cloudinary.image(public_id, options)` - Returns an HTML image tag for the photo specified by public\_id
* `$.cloudinary.facebook_profile_image`, `$.cloudinary.twitter_profile_image`, `$.cloudinary.twitter_name_profile_image`, `$.cloudinary.gravatar_image` , `$.cloudinary.fetch_image` - Same as `image` but returns a specific type of image.

* `$(jquery_selector).cloudinary(options)` - Goes over the elements specified by the jQuery selector and changes all the images to be fetched using Cloudinary's CDN. Using options, you can also specify transformations to the images.
The `options` parameters are similar across all cloudinary frameworks. Please refer to [jQuery image manipulation](http://cloudinary.com/documentation/jquery_image_manipulation) for a more complete reference regarding the options.

![](http://res.cloudinary.com/cloudinary/image/upload/see_more_bullet.png) **See [our documentation](http://cloudinary.com/documentation/jquery_image_manipulation) for more information about displaying and transforming images using jQuery**.

### Other Cloudinary JavaScript libraries

#### Core Javascript library
The Core Cloudinary JavaScript library does not depend on jQuery: https://github.com/cloudinary/pkg-cloudinary-core.

#### jQuery plugin
If you are using jQuery, but are not using the *Blueimp File Upload library* you can take advantage of the Cloudinary jQuery plugin at https://github.com/cloudinary/pkg-cloudinary-jquery.

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
