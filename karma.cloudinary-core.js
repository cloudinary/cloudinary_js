// Karma configuration
// Generated on Tue Jul 28 2015 09:31:57 GMT+0300 (IDT)
let isProd = process.env.mode === 'production';
let mode = isProd ? 'production' : 'development';
console.log(`Mode is ${mode}`);
module.exports = function(config) {
  return config.set({
    // base path that will be used to resolve all patterns (eg. files, exclude)
    //    basePath: '.'

    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine'],
    // list of files / patterns to load in the browser
    files: [
      'node_modules/lodash/lodash.js',
      'dist/cloudinary-core' + (isProd ? '.min': '') + '.js',
      'test/spec/spec-helper.js',
      'test/spec/cloudinary-spec.js',
      'test/spec/transformation-spec.js',
      'test/spec/tagspec.js',
      'test/spec/videourlspec.js',
      'test/spec/chaining-spec.js',
      'test/spec/layer-spec.js',
      'test/spec/responsive-core-spec.js',
      {
        pattern: 'dist/*',
        watched: false,
        included: false,
        served: true,
        nocache: false
      },
      {
        pattern: 'test/docRoot/responsive-core-test.html',
        watched: false,
        included: false,
        served: true,
        nocache: false
      },
      {
        pattern: 'node_modules/bootstrap/dist/css/*',
        watched: false,
        included: false,
        served: true,
        nocache: false
      },
      {
        pattern: 'node_modules/bootstrap/dist/js/*',
        watched: false,
        included: false,
        served: true,
        nocache: false
      },
      {
        pattern: 'test/docRoot/css/logo-nav.css',
        watched: false,
        included: false,
        served: true,
        nocache: false
      }
    ],
    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      'dist/*.js': ['coverage']
    },
    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['story', 'coverage'],
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
    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: false,
    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Chrome', 'Firefox', 'Safari', "ChromeHeadless"],
    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: true,
    plugins: ['karma-jasmine', 'karma-coverage', 'karma-story-reporter', 'karma-chrome-launcher', 'karma-firefox-launcher', 'karma-safari-launcher']
  });
};
