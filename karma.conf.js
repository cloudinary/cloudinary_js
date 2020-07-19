process.env.CHROME_BIN = require('puppeteer').executablePath();

let fs = require('fs');
let glob = require('glob');

function returnFilePathOrThrow(filePath) {
  if (!fs.existsSync(filePath)) {
    throw `Cannot find ${filePath}`;
  } else {
    return filePath;
  }
}

function testFiles(pkg) {
  // all files under test/specspec/tests/
  const files = glob.sync('test/spec/automatic/**/*.js'  , { cwd:process.cwd() });

  if (files.length === 0) {
    throw 'Error in glob pattern, no tests found';
  }

  // Ensure the responsive file exists add it
  files.push(returnFilePathOrThrow(`test/spec/manual/responsive-${pkg}-spec.js`));

  if (pkg === 'jquery-file-upload') {
    files.push(returnFilePathOrThrow('test/spec/manual/cloudinary-jquery-upload-spec.js'));
  } else{
    files.push(returnFilePathOrThrow(`test/spec/manual/lazy-load-${pkg}-spec.js`));
  }

  return files;
}

function dependency(pkg) {
  let dependencyFiles = {
    core: [
      'node_modules/lodash/lodash.js',
    ],
    jquery: [
      'node_modules/jquery/dist/jquery.js',
    ],
    'core-shrinkwrap': [],
    'jquery-file-upload': [
      'node_modules/jquery/dist/jquery.js',
      'node_modules/blueimp-file-upload/js/vendor/jquery.ui.widget.js',
      'node_modules/blueimp-file-upload/js/jquery.fileupload.js',
      'node_modules/blueimp-file-upload/js/jquery.fileupload-process.js',
      'node_modules/blueimp-file-upload/js/jquery.iframe-transport.js',
      'node_modules/blueimp-file-upload/js/jquery.fileupload-image.js',
    ]
  };
  return dependencyFiles[pkg];
}

/**
 * Define the karma configuration for a single deliverable.
 * @param {object} config
 * @param {object} config.cloudinary - Cloudinary specific configuration
 * @param {string} [config.cloudinary.pkg='core'] - The package to test. One of core|jquery|jquery-file-upload
 * @param {boolean} [config.cloudinary.minified=false] - Test the minified version of the package.
 * @returns {object} The karma configuration object
 * @example
 *     node_modules/.bin/karma start --single-run --cloudinary.pkg=core-shrinkwrap
 */
module.exports = function(config) {
  let {minified, pkg='core'} = config.cloudinary || {};

  console.log(`Testing ${minified ? 'minified' : 'un-minified'}`);
  const subject = returnFilePathOrThrow(`dist/cloudinary-${pkg}${minified ? '.min' : ''}.js`);
  const lazyLoadBase = returnFilePathOrThrow(`test/spec/manual/lazyLoadTestBase.js`);

  const responsiveHtmlFile = returnFilePathOrThrow(`test/docRoot/responsive-${pkg}-test.html`);

  let lazyLoadHtmlFile;
  if (pkg !== 'jquery-file-upload') {
    lazyLoadHtmlFile = returnFilePathOrThrow(`test/docRoot/lazy-load-${pkg}-test.html`);
  }

  let pattern = [
    '{', // keep this first
    `dist/*.map`
  ];

  if (responsiveHtmlFile) {
    pattern.push(responsiveHtmlFile);
  }

  pattern = pattern.concat([
    lazyLoadHtmlFile,
    `node_modules/bootstrap/dist/+(css|js)/*`,
    `test/docRoot/css/logo-nav.css`,
    '}' // keep this last
  ]).join(',');

  return config.set({
    // base path that will be used to resolve all patterns (eg. files, exclude)
    //    basePath: '.'

    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine'],
    // list of files / patterns to load in the browser
    files: [
      ...dependency(pkg),
      subject,
      lazyLoadBase,
      ...testFiles(pkg),
      {
        pattern,
        watched: false,
        included: false,
        served: true,
        nocache: false
      }
    ],
    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      'dist/*.js': ['coverage'],
      'src/**/*.js': ['coverage']
    },
    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['story', 'coverage'],
    coverageReporter: {
      type : 'html',
      dir : 'coverage/',
      subdir: browser => browser.toLowerCase().split(/[ /-]/)[0]
    },
    // web server port
    port: 9876,
    // enable / disable colors in the output (reporters and logs)
    colors: true,
    // level of logging
    // possible values:
    // - config.LOG_DISABLE
    // - config.LOG_ERROR
    // - config.LOG_WARN
    // - config.LOG_INFO
    // - config.LOG_DEBUG
    logLevel: config.LOG_INFO,
    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: process.env.TEST_HEADLESS ? ['ChromeHeadless'] : ['Chrome', 'Firefox'],
    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    plugins: ['karma-jasmine', 'karma-coverage', 'karma-story-reporter', 'karma-chrome-launcher', 'karma-firefox-launcher'],
    captureTimeout: 210000,
    browserDisconnectTolerance: 3,
    browserDisconnectTimeout : 210000,
    browserNoActivityTimeout : 210000,
  });
};
