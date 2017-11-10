# Karma configuration
# Generated on Tue Jul 28 2015 09:31:57 GMT+0300 (IDT)

module.exports = (config) ->
  config.set

# base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: ''


# frameworks to use
# available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine']



# preprocess matching files before serving them to the browser
# available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
#    preprocessors: {
#      'js/*.js': ['coverage']
#    }


# test results reporter to use
# possible values: 'dots', 'progress'
# available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['story']


# web server port
    port: 9876


# enable / disable colors in the output (reporters and logs)
    colors: true


# level of logging
# possible values:
# - config.LOG_DISABLE
# - config.LOG_ERROR
# - config.LOG_WARN
# - config.LOG_INFO
# - config.LOG_DEBUG
    logLevel: config.LOG_INFO


# enable / disable watching file and executing tests whenever any file changes
    autoWatch: false


# start these browsers
# available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Chrome' , 'Firefox', 'Safari', 'PhantomJS']


# Continuous Integration mode
# if true, Karma captures browsers, runs the tests and exits
    singleRun: true
    plugins:[
      'karma-jasmine'
      'karma-story-reporter'
      'karma-chrome-launcher'
      'karma-phantomjs-launcher'
      'karma-firefox-launcher'
      'karma-safari-launcher'
    ]

    browserNoActivityTimeout: 20000