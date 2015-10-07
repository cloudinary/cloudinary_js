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
            'src/utils-lodash.coffee'
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




  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-jsdoc')
  grunt.loadNpmTasks('grunt-karma')
  grunt.registerTask('default', ['coffee', 'jsdoc'])
  grunt.registerTask('build', ['coffee', 'jsdoc', 'uglify'])
