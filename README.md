Cloudinary
==========

Cloudinary allows web applications to manage web resources in the cloud leveraging cloud-solutions. 
Cloudinary offers a solution to the entire asset management workflow, from upload to transformations, optimizations, storage and delivery. 

## Setup ######################################################################

In order to properly use this library you have to provide it a few configuration parameters:

Required:

* `cloud_name` - The cloudinary cloud name you'd like to use

Optional:

* `private_cdn`, `secure_distribution`, `cname`, `cdn_subdomain` - Please refer to [Cloudinary Documentation](http://cloudinary.com/documentation)

To set these configuration parameters use the `$.cloudinary.config` function (see below)

## Usage ######################################################################

* `$.cloudinary.config(parameter_name, parameter_value)` - Sets parameter\_name's value to parameter\_value.
* `$.cloudinary.url(public_id, options)` - Returns a cloudinary URL based on your on your configuration and the given options.
* `$.cloudinary.image(public_id, options)` - Returns a HTML image tag for the photo specified by public\_id
* `$.cloudinary.facebook_profile_image`, `$.cloudinary.twitter_profile_image`, `$.cloudinary.twitter_name_profile_image`, `$.cloudinary.gravatar_image` , `$.cloudinary.fetch_image` - Same like `image` but returns a specific type of image.

* `$(jquery_selector).cloudinary(options)` - Goes over the elements specified by jQuery selector and changes all images to be fetched using Cloudinary's CDN. Using options, you can also specify transformations to the images.

All `options` parameters are similar across all cloudinary frameworks. Please refer to [Rail's integration and using `cl_image_tag`](http://cloudinary.com/documentation/rails_integration#display_and_transform) for more complete reference regarding the options.

For more information, refer to [Cloudinary Documentation](http://cloudinary.com/documentation)

## License #######################################################################

Released under the MIT license. 
