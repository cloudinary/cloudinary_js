module.exports = (grunt)->
  grunt.initConfig
    coffee:
      compile:
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
          src: ['*cloudinary*.js', '!*min*']
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
      amd:
        src: ['src/**/*.js', './README.md']
        options:
          destination: 'doc/amd'
          template: 'template'
          configure: "jsdoc-conf.json"
      cloudinary:
        src: ['js/cloudinary.js', './README.md']
        options:
          destination: 'doc/bower-cloudinary'
          template: 'template'
          configure: "jsdoc-conf.json"
    requirejs:
      options:
        baseUrl: "src"
        paths: # when optimizing scripts, don't include vendor files
          'lodash':                   'empty:'
          'jquery':                   'empty:'
          'jquery.ui.widget':         'empty:'
          'jquery.iframe-transport':  'empty:'
          'jquery.fileupload':        'empty:'
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
    copy:
      'file-upload':
        # For backward compatibility, copy vendor files to the js folder
        files: [
          {
            expand: true
            flatten: true
            src: [
              "bower_components/blueimp-canvas-to-blob/js/canvas-to-blob.min.js"
              "bower_components/blueimp-file-upload/js/jquery.fileupload-image.js"
              "bower_components/blueimp-file-upload/js/jquery.fileupload-process.js"
              "bower_components/blueimp-file-upload/js/jquery.fileupload-validate.js"
              "bower_components/blueimp-file-upload/js/jquery.fileupload.js"
              "bower_components/blueimp-file-upload/js/jquery.iframe-transport.js"
              "bower_components/blueimp-file-upload/js/vendor/jquery.ui.widget.js"
            ]
            dest: "js/"
          }
          {
            src: "bower_components/blueimp-load-image/js/load-image.all.min.js"
            dest: "js/load-image.min.js"
          }
        ]
      'dist':
        files: [
          { src: 'js/cloudinary.js', dest: '../bower/bower-cloudinary/cloudinary.js'}
          { src: 'js/jquery.cloudinary.js', dest: '../bower/bower-cloudinary-jquery-file-upload/jquery.cloudinary.js'}
          { src: 'js/jquery.noupload.cloudinary.js', dest: '../bower/bower-cloudinary-jquery/jquery.noupload.cloudinary.js'}
        ]

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-requirejs')
  grunt.loadNpmTasks('grunt-contrib-copy');

  grunt.loadNpmTasks('grunt-jsdoc')
  grunt.loadNpmTasks('grunt-karma')
  grunt.registerTask('default', ['coffee', 'requirejs'])
  grunt.registerTask('build', ['coffee', 'requirejs', 'jsdoc', 'uglify'])
