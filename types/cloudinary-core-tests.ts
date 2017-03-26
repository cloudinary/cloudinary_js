/**
 * This file is used to validate the type spec. The code is not actually run.
 */


import {
    Cloudinary, Util, Configuration, Transformation, ImageTag, VideoTag, Condition, Layer, TextLayer, HtmlTag,
    ClientHintsMetaTag, Param
} from './cloudinary-core';

let config: Configuration.Options = { cloud_name: 'demo' };

// verify that Configuration.Options is forward-compatible
config = { cloud_name: 'demo', some_new_key: "value", some_other_key: { other: 'value' } };

let cld: Cloudinary = new Cloudinary(config);


cld.url('sample'); // http://res.cloudinary.com/demo/image/upload/sample


cld.url('sample', {
    secure: true
}); // https://res.cloudinary.com/demo/image/upload/sample


cld.url('sample', {
    angle: ["vflip", 35]
}); // http://res.cloudinary.com/demo/image/upload/a_vflip.35/sample


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
imageTag.transformation().angle("auto_left").crop('scale').width('auto');
imageTag.toHtml(); // <img src="http://res.cloudinary.com/demo/image/upload/a_auto_left,c_scale,w_auto/sample">


transformation = cld.transformation();
transformation.angle(20).crop('scale').width('auto').chain().effect('sepia');
cld.url('sample', transformation); // http://res.cloudinary.com/demo/image/upload/a_20,c_scale,w_auto/e_sepia/sample

transformation = new Transformation().overlay("text:hello");
transformation.serialize();
transformation.toHtmlAttributes();


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
        effect: ['art', 'hokusai']
    }); // image.src == https://res.cloudinary.com/demo/image/facebook/e_art:hokusai/officialchucknorrispage && image.getAttribute('data-src-cache') == expectedImageUrl


let tag = ImageTag.new("publicId");


let videoHtml = cld.videoTag("movie").setSourceTypes('mp4')
    .transformation()
    .htmlHeight("100")
    .htmlWidth("200")
    .videoCodec({ codec: 'h264', profile: 'basic', level: '3.1' })
    .audioCodec("aac")
    .startOffset(3)
    .toHtml();


let layerOptions: TextLayer.Options = {
    text: "Cloudinary for the win!",
    fontFamily: "Arial",
    fontSize: 18
};
let layer = new TextLayer(layerOptions);
layer.textStyleIdentifier(); // "Arial_18"
layer.toString(); // "text:Arial_18:Cloudinary%20for%20the%20win%21")


new HtmlTag('div', "publicId", {});
new HtmlTag('div', {});

new ImageTag('image_id', config).toHtml(); //  <img src=\"#{DEFAULT_UPLOAD_PATH}image_id\">
new ImageTag('image_id', Util.assign({ responsive: true }, config)).toHtml()

new VideoTag("movie", {
    cloud_name: "test123",
    secure_distribution: null,
    private_cdn: false,
    secure: false,
    cname: null,
    cdn_subdomain: false,
    api_key: "1234",
    api_secret: "b"
}).toHtml();

// Video with HTML5 attributes
new VideoTag("movie", {
    cloud_name: "test123",
    secure_distribution: null,
    autoplay: 1,
    controls: true,
    loop: true,
    muted: "true",
    preload: true,
    style: "border: 1px"
}).toHtml();

new VideoTag("movie", {
    source_types: "mp4",
    html_height: "100",
    html_width: "200",
    video_codec: { codec: "h264" },
    audio_codec: "acc",
    start_offset: 3
}).toDOM();

cld.video("movie", { poster: { gravity: 'north' }, source_types: "mp4" }); // <video poster=\"#{expected_poster_url}\" src=\"#{expected_url}.mp4\"></video>
cld.video("movie", { poster: { 'gravity': 'north', 'public_id': 'my_poster', 'format': 'jpg' }, source_types: "mp4"}); // <video poster=\"#{expected_poster_url}\" src=\"#{expected_url}.mp4\"></video>
new ClientHintsMetaTag().toHtml(); // <meta content="DPR, Viewport-Width, Width" http-equiv="Accept-CH">

new Param("param name", "p_n");

Transformation.new().keyframeInterval(10).toString(); // "ki_10"
Transformation.new().gravity("bad movie");
Transformation.new().flags('abc').toString(); // fl_abc
Transformation.new().flags(['abc','def']).toString(); // fl_abc.def
Transformation.new().flags('ignore_aspect_ratio').toString(); // fl_ignore_aspect_ratio

cld.image("image", { zoom: 1.2 }); // http://res.cloudinary.com/<cloud>/image/upload/z_1.2/image
cld.image("image", { variables: [['x', 1],['y', '$x']] }); // http://res.cloudinary.com/<cloud>/image/upload/$x_1,$y_$x/image

new Layer().resourceType("video").publicId("cat"); // "video:cat"
new TextLayer().text("Hello World, Nice to meet you?").fontFamily("Arial").fontSize(18); // "text:Arial_18:Hello%20World%252C%20Nice%20to%20meet%20you%3F"]


cld.video("movie", { fallback_content: "<span id=\"spanid\">Cannot display video</span>" });