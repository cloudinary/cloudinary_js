module.exports = (grunt)->
  grunt.initConfig
    coffee:
      compile:
        options:
          join: true
          joinExt: '.coffee'
          bare: false
          sourceMap: false
        files:
          'js/cloudinary.js': [
            'src/header.coffee'
            'src/utils.coffee'
            'src/cloudinary-main.coffee'
            'src/crc32.coffee'
            'src/utf8_encode.coffee'
            'src/configuration.coffee'
            'src/parameters.coffee'
            'src/transformation.coffee'
            'src/tags/htmltag.coffee'
            'src/tags/imagetag.coffee'
            'src/tags/videotag.coffee'
            'src/footer.coffee'
          ]
          'js/jquery.noupload.cloudinary.js': [
            'src/header-jquery.coffee'
            'src/utils-jquery.coffee'
            'src/cloudinary-main.coffee'
            'src/crc32.coffee'
            'src/utf8_encode.coffee'
            'src/configuration.coffee'
            'src/parameters.coffee'
            'src/transformation.coffee'
            'src/tags/htmltag.coffee'
            'src/tags/imagetag.coffee'
            'src/tags/videotag.coffee'
            'src/jquery-extension.coffee'
            'src/footer.coffee'
          ]
          'js/jquery.cloudinary.js': [
            'src/header-jquery-upload.coffee'
            'src/utils-jquery.coffee'
            'src/cloudinary-main.coffee'
            'src/crc32.coffee'
            'src/utf8_encode.coffee'
            'src/configuration.coffee'
            'src/parameters.coffee'
            'src/transformation.coffee'
            'src/tags/htmltag.coffee'
            'src/tags/imagetag.coffee'
            'src/tags/videotag.coffee'
            'src/jquery-extension.coffee'
            'src/cloudinary-fileupload.coffee'
            'src/footer.coffee'
          ]
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
      cloudinary:
        files:
          src: [
            'bower_components/lodash/lodash.js',
            'js/cloudinary.js',
            'test/spec/cloudinary-spec.js'
            'test/spec/tagspec.js'
            'test/spec/videourlspec.js'
            'test/spec/chaining-spec.js'
          ]
      jqueryCloudinaryNoupload:
        files:
          src: [
            'bower_components/lodash/lodash.js',
            'bower_components/jquery/dist/jquery.js',
            'js/jquery.noupload.cloudinary.js',
            'test/spec/cloudinary-jquery-spec.js'
            'test/spec/tagspec.js'
            'test/spec/videourlspec.js'
            'test/spec/chaining-spec.js'
          ]
      jqueryCloudinary:
        files:
          src: [
            'bower_components/jquery/dist/jquery.js'
            'bower_components/jquery.ui/ui/widget.js'
            'bower_components/lodash/lodash.js'
            'bower_components/blueimp-file-upload/js/jquery.fileupload.js'
            'bower_components/blueimp-file-upload/js/jquery.fileupload-process.js'
            'bower_components/blueimp-file-upload/js/jquery.iframe-transport.js'
            'bower_components/blueimp-file-upload/js/jquery.fileupload-image.js'
            'js/jquery.cloudinary.js'
            'test/spec/cloudinary-jquery-spec.js'
            'test/spec/cloudinary-jquery-upload-spec.js'
            'test/spec/tagspec.js'
            'test/spec/videourlspec.js'
            'test/spec/chaining-spec.js'
          ]





  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-karma')
  grunt.registerTask('default', ['coffee'])
  grunt.registerTask('build', ['coffee', 'uglify'])
