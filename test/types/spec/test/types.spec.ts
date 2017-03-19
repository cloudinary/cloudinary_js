/**
 * Test cloudinary-core.d.ts
 * 
 * Depends on cloudinary.core.js, so this test is meant to run after "grunt build" which copies this script under 
 * the "build/" folder.
 * "../../../cloudinary-core" below is relative to this file's location under "build/" folder
 *
 * Run this test after "grunt build" with "npm run test-types" which compiles TypeScript before running the test.
 */
import { Cloudinary, ConfigurationOptions, Transformation, ImageTag, VideoTag } from '../../../../build/cloudinary-core';
import 'jasmine';
import { jsdom } from 'jsdom';

describe('Cloudinary', () => {

    let config: ConfigurationOptions;
    let cld: Cloudinary;

    beforeEach(() => {
        config = { cloud_name: 'demo' };
        cld = new Cloudinary(config);
    });

    describe('url', () => {

        it('produces HTTP URLs', () => {
            expect(cld.url('sample')).toEqual('http://res.cloudinary.com/demo/image/upload/sample');
        });
        it('produces secure URLs', () => {
            expect(cld.url('sample', {
                secure: true
            })).toEqual('https://res.cloudinary.com/demo/image/upload/sample');
        });
        it('produces transformations', () => {
            expect(cld.url('sample', {
                angle: 35
            })).toEqual('http://res.cloudinary.com/demo/image/upload/a_35/sample');
        });
        it('mixes configuration and transformation options', () => {
            expect(cld.url('sample', {
                secure: true,
                cloud_name: 'other_cloud',
                fetchFormat: 'auto',
                quality: 'auto'
            })).toEqual('https://res.cloudinary.com/other_cloud/image/upload/f_auto,q_auto/sample');
        });
        it('chains transformations', () => {
            expect(cld.url('sample', {
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
            })).toEqual('http://res.cloudinary.com/demo/image/upload/if_w_lt_200,c_fill,h_120,w_80/if_w_gt_400,c_fit,h_150,w_150/e_sepia/sample');
        });
    });

    describe('image', () => {
        const publicId = 'imagePublicId';
        beforeEach(() => {
            const doc = jsdom('<!doctype html><html><body></body></html>');
            (<any>global).document = doc;
            (<any>global).window = doc.defaultView;
        });

        it('creates an image element', () => {
            spyOn(document, 'createElement').and.callThrough();
            const image: HTMLImageElement = cld.image(publicId);
            expect(image.src).toEqual(`http://res.cloudinary.com/demo/image/upload/${publicId}`);
            expect(document.createElement).toHaveBeenCalled();
        });
    });

    describe('video', () => {
        const publicId = 'videoPublicId';
        beforeEach(() => {
            const doc = jsdom('<!doctype html><html><body></body></html>');
            (<any>global).document = doc;
            (<any>global).window = doc.defaultView;
        });

        it('creates a video element', () => {
            spyOn(document, 'createElement').and.callThrough();
            const video: string = cld.video(publicId);
            expect(video).toEqual(`<video poster="http://res.cloudinary.com/demo/video/upload/${publicId}.jpg"><source src="http://res.cloudinary.com/demo/video/upload/${publicId}.webm" type="video/webm"><source src="http://res.cloudinary.com/demo/video/upload/${publicId}.mp4" type="video/mp4"><source src="http://res.cloudinary.com/demo/video/upload/${publicId}.ogv" type="video/ogg"></video>`);
        });
        it('creates a video tag', () => {
            spyOn(document, 'createElement').and.callThrough();
            const video: VideoTag = cld.videoTag(publicId);
            expect(video.getOption('source_types')).toEqual(['webm', 'mp4', 'ogv']);
        });
    });

    describe('transformations', () => {
        it('converts transformatikon options to a string', () => {
            expect(cld.transformation_string({
                border: '4px_solid_black',
                fetchFormat: 'auto',
                opacity: 30
            })).toEqual('bo_4px_solid_black,f_auto,o_30');
        });

        it('creates transforamtions thru methods', () => {
            const transformation: Transformation = cld.transformation();
            transformation.angle(20).crop('scale').width('auto');
            expect(cld.url('sample', transformation)).toEqual('http://res.cloudinary.com/demo/image/upload/a_20,c_scale,w_auto/sample');
        });

        it('creates transforamtions thru methods objects', () => {
            const transformation: Transformation = cld.transformation({
                angle: 20,
                crop: 'scale',
                width: 'auto'
            });
            expect(cld.url('sample', transformation)).toEqual('http://res.cloudinary.com/demo/image/upload/a_20,c_scale,w_auto/sample');
        });

        it('uses transformation objects to create images', () => {
            const transformation: Transformation = cld.transformation();
            const imageTag: ImageTag = cld.imageTag('sample');
            imageTag.transformation().angle(20).crop('scale').width('auto');
            expect(imageTag.toHtml()).toEqual('<img src="http://res.cloudinary.com/demo/image/upload/a_20,c_scale,w_auto/sample">');
        });

        it('chains transformation', () => {
            const transformation: Transformation = cld.transformation();
            transformation.angle(20).crop('scale').width('auto').chain().effect('sepia');
            expect(cld.url('sample', transformation)).toEqual('http://res.cloudinary.com/demo/image/upload/a_20,c_scale,w_auto/e_sepia/sample');
        });

        it('should serialize to "if_end"', () => {
            const url = cld.url('sample', cld.transformation().if().width('gt', 100).and().width('lt', 200).then().width(50).crop('scale').endIf());
            expect(url).toEqual('http://res.cloudinary.com/demo/image/upload/if_w_gt_100_and_w_lt_200/c_scale,w_50/if_end/sample');

        });
        it('forces the if clause to be chained', () => {
            const url = cld.url('sample', cld.transformation().if().width("gt", 100).and().width("lt", 200).then().width(50).crop("scale").endIf());
            expect(url).toEqual("http://res.cloudinary.com/demo/image/upload/if_w_gt_100_and_w_lt_200/c_scale,w_50/if_end/sample");
        });
        it('forces the if_else clause to be chained', () => {
            const url = cld.url('sample', cld.transformation().if().width("gt", 100).and().width("lt", 200).then().width(50).crop("scale").else().width(100).crop("crop").endIf());
            expect(url).toEqual('http://res.cloudinary.com/demo/image/upload/if_w_gt_100_and_w_lt_200/c_scale,w_50/if_else/c_crop,w_100/if_end/sample');
        });
        it('accepts if conditions as a string', () => {
            const transformation = cld.transformation().if("w > 1000 and aspectRatio < 3:4")
                .width(1000)
                .crop("scale")
                .else()
                .width(500)
                .crop("scale");
            const url = cld.url('sample', transformation);
            expect(url).toEqual('http://res.cloudinary.com/demo/image/upload/if_w_gt_1000_and_ar_lt_3:4,c_scale,w_1000/if_else,c_scale,w_500/sample');
        });
    });

    describe('Social', () => {
        it('fetches Facebook profile images', () => {
            const image: HTMLImageElement = cld.facebook_profile_image('officialchucknorrispage',
                {
                    secure: true,
                    responsive: true,
                    effect: 'art:hokusai'
                });
            const expectedImageUrl = 'https://res.cloudinary.com/demo/image/facebook/e_art:hokusai/officialchucknorrispage';
            expect(image.src).toEqual(expectedImageUrl);
            expect(image.getAttribute('data-src-cache')).toEqual(expectedImageUrl);
        });
    });
});

