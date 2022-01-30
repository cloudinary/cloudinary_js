Cloudinary jQuery File Upload Plugin
=======================================

## About
The Cloudinary jQuery File Upload plugin allows you to effortlessly upload assets to your cloud.

#### Note
This Readme provides basic installation and usage information.
For the complete documentation, see the [JQuery SDK Guide](https://cloudinary.com/documentation/jquery_integration).


## Table of Contents
- [Key Features](#key-features)
- [Browser Support](#Browser-Support)
- [Installation](#installation)
- [Usage](#usage)
    - [Setup](#Setup)
    - [File upload](#File-upload)
- [Contributions](#Contributions)
- [About Cloudinary](#About-Cloudinary)
- [Additional Resources](#Additional-Resources)
- [Licence](#Licence)

## Key Features
- [Upload](https://cloudinary.com/documentation/jquery_image_and_video_upload) assets.

## Browser Support
Chrome, Safari, Firefox, IE 11

## Installation
#### Install the package using:
```bash
npm install cloudinary-jquery cloudinary-jquery-file-upload blueimp-file-upload
```
Or
```bash
yarn add cloudinary-jquery cloudinary-jquery-file-upload blueimp-file-upload
```

## Usage
### Setup
1. Include the javascript files in your HTML. For Example:

```html
<script src="node_modules/jquery/dist/jquery.min.js" type="text/javascript"></script>
<script src="node_modules/blueimp-file-upload/js/vendor/jquery.ui.widget.js" type="text/javascript"></script>
<script src="node_modules/blueimp-file-upload/js/jquery.iframe-transport.js" type="text/javascript"></script>
<script src="node_modules/blueimp-file-upload/js/jquery.fileupload.js" type="text/javascript"></script>
<script src="node_modules/cloudinary-jquery-file-upload/cloudinary-jquery-file-upload.min.js" type="text/javascript"></script>
```

#### Configuration
1. Configure cloudinary-jquery
```javascript
$.cloudinary.config({ cloud_name: "demo"});
```
[See more ways to configure cloudinary-jquery](https://github.com/cloudinary/cloudinary_js/tree/master/pkg/cloudinary-jquery#there-are-several-ways-to-configure-cloudinary-jquery)

2. Add a file input tag
```html
<input
  name="file"
  type="file"
  class="cloudinary-fileupload"
  data-cloudinary-field="image_id"
  data-form-data="{ &quot;upload_preset&quot;:  &quot;user_upload1&quot;, 
  &quot;callback&quot;: &quot;https://www.example.com/cloudinary_cors.html&quot;}" 
/>
```

### File upload
[See full documentation](https://cloudinary.com/documentation/jquery_image_and_video_upload#direct_uploading_from_the_browser) including [upload events](https://cloudinary.com/documentation/jquery_image_and_video_upload#upload_events) and [image validation before upload](https://cloudinary.com/documentation/jquery_image_and_video_upload#client_side_image_validation_before_upload)

#### Initiate the file input field

```javascript
$(document).ready(function() {
  if($.fn.cloudinary_fileupload !== undefined) {
    $("input.cloudinary-fileupload[type=file]").cloudinary_fileupload();
  }
});
```

## Contributions
- Ensure tests run locally (```npm run test```)
- Open a PR and ensure Travis tests pass

## Get Help
If you run into an issue or have a question, you can either:
- [Open a Github issue](https://github.com/Cloudinary/cloudinary_js/issues)  (for issues related to the SDK)
- [Open a support ticket](https://cloudinary.com/contact) (for issues related to your account)

## About Cloudinary
Cloudinary is a powerful media API for websites and mobile apps alike, Cloudinary enables developers to efficiently manage, transform, optimize, and deliver images and videos through multiple CDNs. Ultimately, viewers enjoy responsive and personalized visual-media experiences—irrespective of the viewing device.

## Additional Resources
- [Cloudinary Transformation and REST API References](https://cloudinary.com/documentation/cloudinary_references): Comprehensive references, including syntax and examples for all SDKs.
- [MediaJams.dev](https://mediajams.dev/): Bite-size use-case tutorials written by and for Cloudinary Developers
- [DevJams](https://www.youtube.com/playlist?list=PL8dVGjLA2oMr09amgERARsZyrOz_sPvqw): Cloudinary developer podcasts on YouTube.
- [Cloudinary Academy](https://training.cloudinary.com/): Free self-paced courses, instructor-led virtual courses, and on-site courses.
- [Code Explorers and Feature Demos](https://cloudinary.com/documentation/code_explorers_demos_index): A one-stop shop for all code explorers, Postman collections, and feature demos found in the docs.
- [Cloudinary Roadmap](https://cloudinary.com/roadmap): Your chance to follow, vote, or suggest what Cloudinary should develop next.
- [Cloudinary Facebook Community](https://www.facebook.com/groups/CloudinaryCommunity): Learn from and offer help to other Cloudinary developers.
- [Cloudinary Account Registration](https://cloudinary.com/users/register/free): Free Cloudinary account registration.
- [Cloudinary Website](https://cloudinary.com): Learn about Cloudinary's products, partners, customers, pricing, and more.


## Licence
Released under the MIT license.
