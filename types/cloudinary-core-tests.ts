/**
 * This file is used to validate the type spec. The code is not actually run.
 */


import { Cloudinary, ConfigurationOptions, Transformation, ImageTag, VideoTag } from './cloudinary-core';

let config: ConfigurationOptions = { cloud_name: 'demo' };
let cld: Cloudinary = new Cloudinary(config);

cld.url('sample'); // http://res.cloudinary.com/demo/image/upload/sample


cld.url('sample', {
    secure: true
}); // https://res.cloudinary.com/demo/image/upload/sample


cld.url('sample', {
    angle: 35
}); // http://res.cloudinary.com/demo/image/upload/a_35/sample


cld.url('sample', {
    secure: true,
    cloud_name: 'other_cloud',
    fetchFormat: 'auto',
    quality: 'auto'
}); // https://res.cloudinary.com/other_cloud/image/upload/f_auto,q_auto/sample


cld.url('sample', {
    transformation: [
        {
            'if': 'w_lt_200',
            crop: 'fill',
            height: 120,
            width: 80
        }, {
            'if': 'w_gt_400',
            crop: 'fit',
            width: 150,
            height: 150
        }, {
            effect: 'sepia'
        }
    ]
}) // http://res.cloudinary.com/demo/image/upload/if_w_lt_200,c_fill,h_120,w_80/if_w_gt_400,c_fit,h_150,w_150/e_sepia/sample

const publicId = 'imagePublicId';
let image: HTMLImageElement = cld.image(publicId); // image.src == http://res.cloudinary.com/demo/image/upload/${publicId}


let video: string = cld.video(publicId); // video == <video poster="http://res.cloudinary.com/demo/video/upload/${publicId}.jpg"><source src="http://res.cloudinary.com/demo/video/upload/${publicId}.webm" type="video/webm"><source src="http://res.cloudinary.com/demo/video/upload/${publicId}.mp4" type="video/mp4"><source src="http://res.cloudinary.com/demo/video/upload/${publicId}.ogv" type="video/ogg"></video>


const videoTag: VideoTag = cld.videoTag(publicId); // videoTag.getOption('source_types')) == ['webm', 'mp4', 'ogv']


cld.transformation_string({
    border: '4px_solid_black',
    fetchFormat: 'auto',
    opacity: 30
}); // bo_4px_solid_black,f_auto,o_30


let transformation: Transformation = cld.transformation();
transformation.angle(20).crop('scale').width('auto');
cld.url('sample', transformation); // http://res.cloudinary.com/demo/image/upload/a_20,c_scale,w_auto/sample


transformation = cld.transformation({
    angle: 20,
    crop: 'scale',
    width: 'auto'
});
cld.url('sample', transformation); // http://res.cloudinary.com/demo/image/upload/a_20,c_scale,w_auto/sample


transformation = cld.transformation();
const imageTag: ImageTag = cld.imageTag('sample');
imageTag.transformation().angle(20).crop('scale').width('auto');
imageTag.toHtml(); // <img src="http://res.cloudinary.com/demo/image/upload/a_20,c_scale,w_auto/sample">


transformation = cld.transformation();
transformation.angle(20).crop('scale').width('auto').chain().effect('sepia');
cld.url('sample', transformation); // http://res.cloudinary.com/demo/image/upload/a_20,c_scale,w_auto/e_sepia/sample


let url: string = cld.url('sample', cld.transformation().if().width('gt', 100).and().width('lt', 200).then().width(50).crop('scale').endIf()); // http://res.cloudinary.com/demo/image/upload/if_w_gt_100_and_w_lt_200/c_scale,w_50/if_end/sample


url = cld.url('sample', cld.transformation().if().width("gt", 100).and().width("lt", 200).then().width(50).crop("scale").endIf()); // http://res.cloudinary.com/demo/image/upload/if_w_gt_100_and_w_lt_200/c_scale,w_50/if_end/sample

url = cld.url('sample', cld.transformation().if().width("gt", 100).and().width("lt", 200).then().width(50).crop("scale").else().width(100).crop("crop").endIf()); // http://res.cloudinary.com/demo/image/upload/if_w_gt_100_and_w_lt_200/c_scale,w_50/if_else/c_crop,w_100/if_end/sample


transformation = cld.transformation().if("w > 1000 and aspectRatio < 3:4")
    .width(1000)
    .crop("scale")
    .else()
    .width(500)
    .crop("scale");
url = cld.url('sample', transformation); // http://res.cloudinary.com/demo/image/upload/if_w_gt_1000_and_ar_lt_3:4,c_scale,w_1000/if_else,c_scale,w_500/sample


image = cld.facebook_profile_image('officialchucknorrispage',
    {
        secure: true,
        responsive: true,
        effect: 'art:hokusai'
    }); // image.src == https://res.cloudinary.com/demo/image/facebook/e_art:hokusai/officialchucknorrispage && image.getAttribute('data-src-cache') == expectedImageUrl

