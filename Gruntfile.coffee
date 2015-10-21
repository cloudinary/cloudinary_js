module.exports = (grunt)->
  grunt.initConfig
    coffee:
      compile:
#        options:
#          join: true
#          joinExt: '.coffee'
        expand: true
        bare: false
        sourceMap: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'src'
        ext: '.js'
      compile_test:
        expand: true
        cwd: 'test/spec'
        src: ['*.coffee']
        dest: 'test/spec'
        ext: '.js'

    uglify:
      dist:
        options:
          sourceMap: true
        files: [
          expand: true
          cwd: 'js'
          src: '*.js'
          dest: 'js'
          ext: '.min.js'
          extDot: 'last'
        ]
    karma:
      options:
        configFile: 'karma.conf.coffee'
        reporters: ['dots']
      cloudinary:
        options:
          configFile: 'karma.conf.coffee'
      jqueryCloudinaryNoupload:
        options:
          configFile: 'karma.jquery.conf.coffee'
      jqueryCloudinary:
        options:
          configFile: 'karma.jquery.upload.conf.coffee'
    jsdoc:
      dist:
        src: ['js/jquery.cloudinary.js']
        options:
          destination: 'doc'
          configure: "jsdoc-conf.json"
    requirejs:
      options:
        baseUrl: "src"
        paths: # when optimizing scripts, don't include vendor files
          lodash: 'empty:'
          jquery: 'empty:'
#          'jquery.ui.widget': '../bower_components/blueimp-file-upload/js/vendor/jquery.ui.widget'
#          'jquery.iframe-transport': '../bower_components/blueimp-file-upload/js/jquery.iframe-transport'
#          'jquery.fileupload': '../bower_components/blueimp-file-upload/js/jquery.fileupload'
          'jquery.ui.widget': 'empty:'
          'jquery.iframe-transport': 'empty:'
          'jquery.fileupload': 'empty:'
#          util: 'util/lodash'
#        map:
#          "*": {util: 'util/lodash'}
        skipDirOptimize: true
        optimize: "none"
        removeCombined: true
      'cloudinary':
        options:
          name: 'all'
          bundles:
            'util/lodash': ['util']
          out: "js/cloudinary.js"
      'cloudinary-jquery':
        options:
          name: "alljquery"
          bundles:
            'util/jquery': ['util']
          out: "js/jquery.noupload.cloudinary.js"
      'cloudinary-jquery-file-upload':
        options:
          bundles:
            'util/jquery': ['util']
          name: "alljquery-file-upload"
          out: "js/jquery.cloudinary.js"


  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-requirejs')
  grunt.loadNpmTasks('grunt-jsdoc')
  grunt.loadNpmTasks('grunt-karma')
  grunt.registerTask('default', ['coffee', 'jsdoc'])
  grunt.registerTask('build', ['coffee', 'jsdoc', 'uglify'])
