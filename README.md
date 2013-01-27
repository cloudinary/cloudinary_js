Cloudinary
==========

Cloudinary allows web applications to manage web resources in the cloud leveraging cloud-solutions. 
Cloudinary offers a solution to the entire asset management workflow, from upload to transformations, optimizations, storage and delivery.

The direct image upload feature of the plugin is based on https://github.com/blueimp/jQuery-File-Upload 

## Usage ######################################################################

The following blog post details the process of setting up jQuery based file upload.
http://cloudinary.com/blog/direct_image_uploads_from_the_browser_to_the_cloud_with_jquery

The Cloudinary Documentation can be found at:
http://cloudinary.com/documentation

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
