2.13.0 / 2022-07-17
==================

New functionality and features
------------------------------
* Allow to disable b-frames for video codec (#284)
* Add support for generating url with auth_token (#290)

Fixes
-------------
* Fix support for start offset and end offset parameters (#289)

Other Changes
-------------
* Remove links to nonexistent mapfiles in js folder (#283)
* Update README

2.12.3 / 2022-01-06
==================

* Fix transparent video on safari 14.1 by using fetch instead of XHR (#282)


2.12.2 / 2022-01-03
==================

* Fix missing userAgent on Node.js (#281)

2.12.1 / 2022-01-02
==================

* Fix pictureTag arguments & add missing definitions (#278)
* Fix image srcset passed as attribute (#277) 
* Fix transparent video on Safari (#280)


2.12.0 / 2021-10-10
=============
New functionality and features
------------------------------
  * Add support for variables in text style (#271)

Other Changes
-------------
  * Fix README.md npm package links (#272)
  * Refactor normalization of e_preview:duration (#270)
  
2.11.4 / 2021-04-25
==================

* Fix transformations with variable names containing predefined names (#265)
* Fix responsive URL generation for zero width images (#206)
* Fix incorrect readme text and broken links (#264)
* Add test for context metadata as user variables (#266)

2.11.3 / 2020-09-30
==================

* Fix js/jquery.cloudinary.js es5 compatibility by removing arrow functions

2.11.2 / 2020-08-11
==================

* Fix typescript declarations (#257)


2.11.1 / 2020-07-26
==================

* Revert Fix lazy loading of responsive images (#253)

2.11.0 / 2020-07-26
==================

New functionality and features
------------------------------
* Add support for transparent video (#211)

Other Changes
-------------
* Fix lazy loading of responsive images (#253)
* Fix signature param support in ie11 (#252)
* Add test and pre commit hook to prevent js folder changes (#249) (#251)

2.10.3 / 2020-07-11
==================

* Fix bug where image width was set to 'null' for responsive images
* Refactor tests configuration and folder structure

2.10.2 / 2020-07-08
==================

* Fix ie11 support by removing usage of string.repeat() (#247)


2.10.1 / 2020-07-06
==================

* Update analytics param to be urlAnalytics (#245)
* Fix IE11 support by removing unsupported padStart function (#244)
* Fix normalize() in jquery library used by server-side sdks
* Fix title added to npm packages
* Update travis configuration to test on node 8,10,12,14 (#241)

2.10.0 / 2020-07-01
==================

New functionality and features
------------------------------
* Add support for intersection detection.
* Add support for placeholder and accessibility to url() function (#236)
* Update responsive() to return a callback that removes the listener it adds

Other Changes
-------------
* Add SDK analytics signature to the URL (off by default)
* Update tsconfig to only test types folder (#237)

2.9.0 / 2020-06-21
==================

New functionality and features
------------------------------
* Add support for OCR in transformation (#224)
* Add support for POW operator

Bug Fixes
---------
* Fix fontAntialiasing type definition (#233)
* Fix Transformation normalization for predefined variables
* Fix Transformation normalization in browsers that do not support
  lookbehind in regular expressions (#228)
* Fix bug where preview:duration was shortened to preview:du

Other Changes
-------------
* Update test descriptions (#223)
* Update devDependencies packages
* Remove CoffeeScript and Grunt mentions from readme (#222)
* Remove unneeded  file (#221)
* Update issue templates (#218)

2.8.2 / 2020-03-25
==================

* Fix - Add signature to list of url keys so that extractUrlParams() won't filter it
* Add test for package size using bundlewatch

2.8.1 / 2020-02-18
==================

* Fix spaces encoding of named transformations
* Align responsive function with cloudinary_angular's lazy load  
* Add tests for special chars encoding in urls
* Fix tests for video offset
* Fix secure_distribution type definition
* Add watch mode to tests
* Refactor normalizeArray function
* Update puppeteer to version 2.1.1

2.8.0 / 2019-11-24
==================

New functionality and features
------------------------------
  * Add support for  option to  function (#198)

Other Changes
-------------
  * Add npm package test (#187)
  * Fix lodash imports
  * Fix responsive and minified tests
  * Fix files list for npm package in 

2.7.4 / 2019-08-18
==================

New functionality and features
------------------------------
  * Add support for remote\local "pre" function invocation
  
Other Changes
-------------
  * Fix responsive images in ie11
  * Add pre release test for packages (#185)
  
2.7.3 / 2019-08-05
==================

  * Fix cloudinary-core-shrinkwrap.js missing in release
  
2.7.2 / 2019-08-05
==================

  * Fix cloudinary-react needed file not included in release
      * Update copy_deployment script
    

2.7.1 / 2019-08-04
==================

  * Update copybuilds script
  
2.7.0 / 2019-08-04
==================

New functionality and features
------------------------------
  * Feature/add video duration condition (#183)
  * Support force_version parameter to include default version when generating delivery urls (#173)
  * add support for antialiasing and hinting
  * Add support for custom functions
  * Add support of custom codecs in video tag (#161)

  
Other Changes
-------------
  * Feature/configuration (#172)
    * Update webpack and karma configuration
    * Update npm scripts
  * Add deployment files under a single repository
    * Add pkg folder
    * Add copybuilds script
  * Add test for support of art:incognito effect (#168)
  * Update jsdoc version (#182)
  * Add duration to conditions in video (#178)
  * Fix layer cloning (#163)
  * Update inline documentation (#174)
  * Add `fontAntiAliasing` and `fontHinting` to TypeScript definition
  * Add `FetchLayer` to types
  * Fix TypeScript cloudinary import
  * Add default export definition to TypeScript
  * Bump lodash from 4.17.11 to 4.17.13 (#180)
  * Bump js-yaml from 3.12.1 to 3.13.1 (#177)
  * Fix/sample code (#170)
      * Bump package versions in samples


2.6.3 / 2019-04-02
==================


New functionality and features
------------------------------

  * Add support for composite radius params
 
Other Changes
-------------

  * Replace `object.assign` with `util.assign` (#169)
  * Escape quotes in html attributes (#166)
  * Remove Safari from automated tests
  * Fix test:all script
  * Implement isEmpty, isString and fix default function values
  * Update `.jshintrc to support ES6
  * Add "join the Community"

2.6.2 / 2019-02-01
==================

  * Use hardcoded list of method names. Fixes #153
  * Use babel for development mode too
  * Add test:all script

2.6.1 / 2019-01-29
==================

  * Fix ES6 modules

2.6.0 / 2019-01-28
==================

Note
----

Sources are now divided into JavaScript modules. However we can't change the public 
API of the package or its structure, including the "main" property of the package.json file, 
without a major release.

You can import cloudinary from the sources:

```
npm install cloudinary_js
```

```js
import cloudinary from 'cloudinary_js/src';
const cl = cloudinary.Cloudinary.new({cloud_name: 'demo'});
```


The npm packages: 
* `cloudinary-core` 
* `cloudinary-jquery` 
* `cloudinary-jquery-file-upload`

Are still used to distribute the bundled library.

New functionality and features
------------------------------

  * Add picture tag and source tag
  * Add support to `fps` transformation parameter (#139)
  * Replaced CoffeeScript with JavaScript
  * Refactor code as modules 

Other Changes
-------------

  * Fix Fetch layer
  * Remove grunt
  * Update TypeScript configuration
  * Remove PhantomJS and bower references
  * Fix HTML tag test
  * Fix fps test

2.5.0 / 2018-02-13
==================

New functionality and features
------------------------------

  * Support SEO urls
  * Merge pull request #136 from ignatiusreza/lodash/diet
    * selectively import lodash to avoid bundling the whole lodash

Other Changes
-------------

  * Update `package-lock.json`

2.4.0 / 2017-12-09
==================

New functionality and features
------------------------------

  * Support fetch URL in layers
  * Support SEO suffix for private images

Other Changes
-------------

  * Add documentation
  * Refactor `btoa`; Add POJO `isFunction`
  * Update Node version list to test; Remove env vars
  * Update dependencies and configuration
  * Fix CLOUDINARY_URL regex
  * Update npm installation instructions
  * Update dependencies

2.3.0 / 2017-03-27
==================

New functionality and features
------------------------------

  * Add TypeScript typings for cloudinary-core (merging #120 and #122)

Other Changes
-------------

  * Remove redundant script tags.
  * Add tests for gravity modes.
  * Restore cloud_name when chaining transformations (#116)
  * Add backward compatibility file
  * Fix broken conditional transformations based on order to transformation keys
  * Return node within loop so images is populated correctly (#119)

2.2.1 / 2017-03-15
==================

  * Filter out `$attr` as a variable name - it is reserved in Angular

2.2.0 / 2017-03-14
==================

  * Add **User defined variables**.
  * Add `callback` and `upload_preset` to configuration parameters

2.1.9 / 2017-01-02
==================

  * Support ‘iw’ and ‘ih’ transformation parameters for indicating initial width or height (respectively) in `ImageTag`
  * Support responsive image tag in `ImageTag`

2.1.8 / 2016-12-12
==================

  * Replace `$` with jQuery
  * Replace require

2.1.7 / 2016-12-04
==================

  * Add Client Hints meta tag helper
  * Support public ID with special characters
  * Don't convert parameters to CamelCase
  * Remove using `@const` to avoid lint error on constant assignment
  * Edit instructions in README
  * Encode `|` and `=` in context values.
  * Merge pull request #110 from gvillenave/master
    * Fix the "delay" transformation URL code

2.1.6 / 2016-10-26
==================

  * Change client hints behavior. Fixes #107.
  * Remove dependency on 'jquery.ui' Fixes #104.

2.1.5 / 2016-10-10
==================

  * Refactor `grunt version`
  * Test width value 'ow' and height value 'oh'
  * Update documentation
  * Merge branch 'dpr_auto'
  * preview URL shows dpr_1.0 when setting DPR to auto 
  * Re-introduce the copy:docs task
  * Guard for null or empty param in `cloudinary_update` and  `processImageTags` as mentioned in #99
  * Fix documentation for `processImageTags` as mentioned in #99

2.1.4 / 2016-10-06
==================

  * Move `configuration` before `transformation` in build and test scripts.
  * Refactor Util.
  * Modify karma configuration to support coverage reporting.
  * Fix typo.
  * Make Layer classes support camelCase and snake_case parameters. Add Layer text.
  * Add `baseutil.js` as a common source for lodash and jQuery utils.
  * Fix Layer tests
  * Fix bug in `maxWidth`

2.1.3 / 2016-09-05
==================

  * Add TravisCI label for npm, bower and license.
  * Add license file
  * Add missing `rmargin` variable. Fixes #76
  * Fix README reference to `fileupload()`
  * Merge pull request #95 from crazile/patch-1
    * Remove shorthand jQuery reference ($)
  * Update packages.

2.1.2 / 2016-07-16
==================

  * Rename `short` to `shortName`. Fixes #73.

2.1.1 / 2016-06-30
==================

  * Add TravisCI configuration
  * Allow browsers to be defined in commandline for karma runs.
  * Remove map reference created by the coffee compiler from distribution files.
    * Fixes cloudinary/pkg-cloudinary-core#6.
    * Fixes mileszim/ember-cli-cloudinary#3.

2.1.0 / 2016-06-22
==================

New functionality and features
------------------------------

  * New configuration parameter `:client_hints`
  * Enhanced auto `width` values
  * Enhanced `quality` values

Other Changes
-------------

  * Use duck-typing to set/get attributes.
  * Updated dependencies
  * Add `client_hints`, `width`, `quality` tests
  * Create spec-helper.coffee. Add `sharedExamples`.
  * Fix assets compilation issue with Cloudinary GEM cloudinary/cloudinary_gem#203
  * Remove map reference in `js` folder. Fixes cloudinary/cloudinary_gem#199

2.0.9 / 2016-06-05
==================

New functionality and features
------------------------------

  * Add structured overlay and underlay
  * Add `keyframe_interval` and `streaming_profile` transformation parameters

Other Changes
-------------

  * Fix missing `cloudinary-jquery-file-upload.coffee.js.map` error. Fixes cloudinary/cloudinary_gem#199.
  * Don't overwrite `root.cloudinary` when initializing. Allows the cloudinary upload widget to be loaded before the JS library. Fixes #88

2.0.8 / 2016-03-22
==================

  * Create local variables for `lodash` and `_` for the shrinkwrap version.
  * Add `face_count` and `page_count` to Condition. Use replace with callback to process condition.
  * Add `transformation-spec.js` to karma configuration
  * Add translation of parameter names in conditional transformation
  * Fix responsive tests
  * Update tests
  * Set default `responsive_use_breakpoints` instead of `responsive_use_stoppoints`.

2.0.7 / 2016-03-08
==================

New functionality and features
------------------------------

  * Conditional Transformations
  * Set breakpoint steps to 100. Default `responsive_use_stoppoints` to `true` instead of `"resize"`.
  * Round up DPR by default. Add `round_dpr` configuration parameter.

Other Changes
-------------

  * Add `Condition` class. Add `Transformation.if`, `Transformation.endif`, `Transformation.else`.
  * Use String.slice() instead of String.substring()
  * Update Grunt `build` task to not delete the lodash artifacts. Update `compile` task to not clean `jsdoc`.
  * Add `bootstrap` argument to `responsive()`. Support responsive_class in options (defaults to `cld-responsive`).
  * Add `Util.removeAttribute`
  * Add `item == null` to jQuery utils `isEmpty`

2.0.6 / 2016-02-15
==================

New functionality and features
------------------------------

  * Support webpack, browserify
  * webpack example
  * Minified version of source
  * Shrinkwrapped core lib which includes a subset of the lodash functions

Other Changes
-------------

  * Remove UMD constrcut from the individual source files.
  * Fix module references for NodeJS
  * Clone headers instead of modifying them. Fixes handling of multiple chunked uploads in parallel.
  * Rename `lodash-shrinkwrapped` to `lodash-shrinkwrap`. Fix documentation comments.
  * Update dependencies

2.0.5 / 2016-01-21
==================

  * Update version number in backward compatibility library (no code changes)
  * Merge branch 'master' of https://github.com/cloudinary/cloudinary_js
  * Update README.md
  * Add IDEA files to gitignore
  * Merge pull request #71 from bradvogel/patch-2
    * I think you mean this link?

2.0.4 / 2015-12-28
==================

  * Create `namespace` folder. Move "`-full`" files to the new folder and rename them.
  * Make root module nameless.
  * Update dependencies and documentation of script tags.
  * Check if jQuery.fn.fileupload exists before executing related methods. Used for backward compatibility. Fixes #67
  * Add test runner for source ("un-packed") AMD.
  * Don't use `file:` for Cloudinary URL. Modify resources URLs in the test files.
  * Remove `testWindow.removeEventListener handler` - it was causing the test to fail.
  * Fix reference to Configuration.

2.0.3 / 2015-11-30
==================

  * Update backward compatibility files

2.0.2 / 2015-11-30
==================

  * Bootstrap fileupload when loading the code directly. Required for backward compatibility.
  * Verify that cloudinary domain exists when defining the Tranfsormation class

2.0.1 / 2015-11-22
==================

  * Version 2.0.1
  * Fix Links in `README.md`
  * Fix responsive and dpr.
  * Create a web project for testing at `test/docRoot`. Add a bootstrap responsive html for tests.
  * Create a separate spec file for responsive tests.
  * Remove "old" from the JS link in `bootstrap.html`
  * Fix algorithm used to calculate container width

2.0.0 / 2015-11-10
==================

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
The cloudinary-jquery-file-upload library is fully backward compatible with cloudinary_js library 1.0.25.
The relevant Blueimp files will still be found in the `js` folder for backward compatibility. However if you rely on Blueimp files located in the repository's `js` folder, make sure to update your links to `load-image.all.min.js` which replaced the `load-image.min.js` from previous versions.
We however encourage developers to utilize a dependency manager such as bower or NPM to install 3 party libraries and not rely on the files in the `js` folder. 
 
## Details

  * Add lodash
  * Add Blueimp distribution files.
  * Replace `bower-*` repositories with `pkg-*`.
  * Update `devDependencies` in `package.json`
  * Fix files references in karma configuration files.
  * Add `load-image.all.min.js` , remove `load-image.min.js`. Fix `uglify` task. Add `copy:doc` task. Modify `build` task.
  * Add manually compiled Gruntfile.
  * Optimize bundles to build dir. Dynamically build grunt tasks. Rename files to match repositories.
  * Update documentation.
  * Replace "stoppoints" with "breakpoints". Prefix HtmlTag attributes with "html_".
  * Add format to documentation task. Fix documentation. Remove headers and footer.
  * Add template files to be used by jsdoc
  * Add grunt task to copy artifact to bower repositories
  * Define modules for namespaces. Modify grunt script.
  * Add requirejs tasks to grunt build file.
  * Add UMD to all sources.
  * Filter empty transformation values for the transformation parameter
  * Add aspect_ratio transformation
  * Update README
  * Update gitignore file; Add new API information to README; update npm dependencies
  * Split karma configuration
  * Remove lodash and jQuery references where they shouldn't be.
  * Don't fail on falsy public_id
  * Redefine `cloudinary` scope and secure it internally; Add documentation
  * Remove automatic configuration from Cloudinary class. Will be enabled in jquery flavor for backward compatibility.
  * Add utils.jquery
  * Define `Util` domain for utility functions
  * Return DOM from `Cloudinary.image()` 
  * Convert specs to coffee
  * Add Karma runner to grunt.
  * Add Transformation chains
  * Change file paths in jasmine html files.
  * Replace '$' with jQuery
  * Move tags to separate folder. Add TODO.md.
  * Add uglify to grunt.
  * Add correct width algorithm.
  * Add node modules to the ignore file

1.0.25 / 2015-09-01
===================

  * Add node_nodules to gitignore
  * Set innerText and textContent without using hasOwnProperty, in order to support IE and FF. Fixes #56
  * Update README.md

1.0.24 / 2015-04-16
===================

  * Re-fix issues lost in merge
  * Fix poster options. Edit Documentation.
  * Fix documentation
  * Use jQuery width for responsive for correct handling of padding
  * Support responsive_preserve_height configuration option
  * Support video tag generation
  * Add test for zoom.
  * Refactored range code.  Updated dependencies.
  * Support resource_type and type parameters for cloudinary_fileupload

1.0.23 / 2015-03-22
===================

  * Merge branch 'feat/video-support'
  * Add support for video
  * Add X-Unique-Upload-Id header to upload requests. Particularly useful for the upload_chunked endpoint
  * Increment version to v1.0.22: Support root path for shared CDN
  * Support root path for shared CDN

1.0.21 / 2014-12-11
===================

  * support url_suffix and use_root_path for private_cdn URL building
  * Fix potential XSS vulnerability on cloudinary_cors.html
  * Upgrade to jquery.fileupload.js version 5.42.1
  * Traverse ancestors in DOM to find clientWidth for responsive images
  * Reading use_root_path also from global config
  * Merge pull request #40 from zaption/xss-fix
  * Support domain sharding for https in res.cloudinary.com
  * Refactor tests
  * Merge pull request #39 from sl4m/responsive-image-width
  * Fix dpr cache to store by queue indexed by

1.0.20 / 2014-09-22
===================

  * Fix issue #125 - find closest supported DPR value since zoom changes DPR

1.0.19 / 2014-07-14
===================

  * Support for delete_by_token API call from the browser

1.0.18 / 2014-06-30
===================

  * Responsive images support. Support passing cloud_name to unsigned_cloudinary_upload as part of upload_params hash.
  * Automatically update dpr according to real devicePixelRatio when building or updating image
  * Refactor generate_transformation_string. Add support for dpr parameter
  * Support supplying cloud_name as option to upload methods. Support supplying multiple in unsigned upload methods

1.0.17 / 2014-05-26
===================

  * Add unsigned_cloudinary_upload

1.0.16 / 2014-05-12
===================

  * fix url generation if secure is false in a secure page

1.0.15 / 2014-05-04
===================

  * fix object encoding in unsigned upload
  * Merge pull request #29 from zvictor/master
  * fix non-fileupload code

1.0.14 / 2014-04-15
===================

  * Rename unsigned_upload to unsigned_upload_tag
  * Support dynamically creating an unsigned_upload widget. Better absolutize for fetch urls
  * Merge pull request #27 from eroh92/patch-1
  * fix invalid JSON

1.0.13 / 2014-03-25
===================

  * fix trailing ',', add .jshintrc, fix named transformations
  * Bower manifest
  * Added bower.json, for registration.
  * Merge pull request #23 from aceunreal/master
  * Upating the webp image to ensure the webpify function handles Android 4.1.2 version
  * Better handling of fieldupload fields with multiple true
  * trust_public_id - allow keeping file extension that looks like an image extension
  * AMD support

1.0.12 / 2014-01-21
===================

  * Updating links in jquery plugin definition
  * Merge pull request #20 from luxedigital/allow_to_override_protocol
  * Allow to set protocol using cloudinary config
  * Allow to specify a protocol
  * Fix tests follow change to secure urls under file:// change
  * Secure option overrides window.location.protocol

1.0.11 / 2013-11-04
===================

  * Add color parameter support

1.0.11 / 2013-11-04
===================

  * Binding jQuery file upload events
  * Bind other important events and expose to application
  * Update client size resize and validation instructions
  * Referring to cloudinary_angular in readme

1.0.11 / 2013-11-04
===================

  * Escape public_ids even if not fetch

1.0.8 / 2013-07-30
==================

  * Change secure urls to use *res.cloudinary.com
