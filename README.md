[![Build Status](https://travis-ci.org/cloudinary/cloudinary_js.svg)](https://travis-ci.org/cloudinary/cloudinary_js) [![npm](https://img.shields.io/npm/v/cloudinary_js.svg?maxAge=2592000)]() [![license](https://img.shields.io/github/license/cloudinary/cloudinary_js.svg?maxAge=2592000)]()

# Cloudinary Client Side JavaScript Library

Cloudinary is a cloud service that offers a solution to a web application's entire image management pipeline.</br></br>
Easily upload images to the cloud. Automatically perform smart image resizing, cropping and conversion without installing any complex software. Integrate Facebook or Twitter profile image extraction in a snap, in any dimension and style to match your website’s graphics requirements. Images are seamlessly delivered through a fast CDN, and much much more.</br></br>
Cloudinary offers comprehensive APIs and administration capabilities and is easy to integrate with any web application, existing or new.</br></br>
Cloudinary provides URL and HTTP based APIs that can be easily integrated with any Web development framework.



# About this repository
This repository is the home for three distinct packages
- [cloudinary-core](https://www.npmjs.com/package/cloudinary-core)
- [cloudinary-jquery](https://www.npmjs.com/package/cloudinary-jquery)
- [cloudinary-jquery-file-upload](https://www.npmjs.com/package/cloudinary-jquery-file-upload)

# Cloudinary Core
Cloudinary-Core is a cross-platform library for Cloudinary.</br>
The library provides URL generation capabilities as well as other utlity functions useful when working with Media.

This SDK does not contain API methods, for that please refer to our [Node SDK](https://github.com/cloudinary/cloudinary_npm)

* [cloudinary-core readme](https://github.com/cloudinary/cloudinary_js/tree/master/pkg/cloudinary-core/README.md)
### Quick start

```javascript
var cl = cloudinary.Cloudinary.new( { cloud_name: "demo"});
```

```javascript
// Using the config function
var cl = cloudinary.Cloudinary.new();
cl.config( "cloud_name", "demo");
```

------------------------------

# Cloudinary jQuery
* [cloudinary-jquery readme](https://github.com/cloudinary/cloudinary_js/tree/master/pkg/cloudinary-jquery/README.md)
* [Getting started guide for jQuery](http://cloudinary.com/documentation/jquery_integration#getting_started_guide)

------------------------------
# Cloudinary jQuery File Upload
* [cloudinary-jquery-file-upload readme](https://github.com/cloudinary/cloudinary_js/tree/master/pkg/cloudinary-jquery-file-upload/README.md)


# Additional Resources
* [Website](http://cloudinary.com)
* [Documentation](http://cloudinary.com/documentation)
* [Knowledge Base](http://support.cloudinary.com/forums)
* [Documentation for jQuery integration](http://cloudinary.com/documentation/jquery_integration)
* [jQuery image upload documentation](http://cloudinary.com/documentation/jquery_image_upload)
* [jQuery image manipulation documentation](http://cloudinary.com/documentation/jquery_image_manipulation)
* [Image transformations documentation](http://cloudinary.com/documentation/image_transformations)
* [Setting up a jQuery based file upload](http://cloudinary.com/blog/direct_image_uploads_from_the_browser_to_the_cloud_with_jquery).


# Other SDKs
- [Official Angular SDK](https://github.com/cloudinary/cloudinary_angular)
- [Official React SDK](https://github.com/cloudinary/cloudinary-react)
- [Official Vue SDK](https://github.com/cloudinary/cloudinary-vue)
- [Official Node SDK](https://github.com/cloudinary/cloudinary_npm)


## Support
You can [open an issue through GitHub](https://github.com/cloudinary/cloudinary_js/issues). </br></br>
Contact us at [http://cloudinary.com/contact](http://cloudinary.com/contact). </br></br>
Stay tuned for updates, tips and tutorials: [Blog](http://cloudinary.com/blog), [Twitter](https://twitter.com/cloudinary), [Facebook](http://www.facebook.com/Cloudinary). </br></br>

## Join the Community 
Impact the product, hear updates, test drive new features and more! Join [here](https://www.facebook.com/groups/CloudinaryCommunity).


## License
Released under the MIT license. </br></br>
The direct image upload feature of the plugin is based on https://github.com/blueimp/jQuery-File-Upload
