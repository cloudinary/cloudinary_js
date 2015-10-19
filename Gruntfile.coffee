module.exports = (grunt)->
  grunt.initConfig
    coffee:
      compile:
        options:
          join: true
          joinExt: '.coffee'
          bare: false
          sourceMap: true
        files:
          'js/cloudinary.js': [
#            'src/header.coffee'
            'src/util-lodash.coffee'
            'src/utf8_encode.coffee'
            'src/crc32.coffee'
            'src/configuration.coffee'
            'src/parameters.coffee'
            'src/transformation.coffee'
            'src/tags/htmltag.coffee'
            'src/tags/imagetag.coffee'
            'src/tags/videotag.coffee'
            'src/cloudinary-main.coffee'
#            'src/footer.coffee'
          ]
          'js/jquery.noupload.cloudinary.js': [
#            'src/header-jquery.coffee'
            'src/utf8_encode.coffee'
            'src/crc32.coffee'
            'src/util-jquery.coffee'
            'src/configuration.coffee'
            'src/parameters.coffee'
            'src/transformation.coffee'
            'src/tags/htmltag.coffee'
            'src/tags/imagetag.coffee'
            'src/tags/videotag.coffee'
            'src/cloudinary-main.coffee'
            'src/jquery-extension.coffee'
#            'src/footer.coffee'
          ]
          'js/jquery.cloudinary.js': [
#            'src/header-jquery-upload.coffee'
            'src/utf8_encode.coffee'
            'src/crc32.coffee'
            'src/util-jquery.coffee'
            'src/configuration.coffee'
            'src/parameters.coffee'
            'src/transformation.coffee'
            'src/tags/htmltag.coffee'
            'src/tags/imagetag.coffee'
            'src/tags/videotag.coffee'
            'src/cloudinary-main.coffee'
            'src/jquery-extension.coffee'
            'src/cloudinary-fileupload.coffee'
#            'src/footer.coffee'
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
    requirejs:
      options:
        baseUrl: "src"
        paths:
          lodash: 'empty:'
          jquery: 'empty:'
        map:
          "*": {util: 'util-lodash'}
        skipDirOptimize: true
        optimize: "none"
      cloudinary:
        options:
          map:
            "*": {util: 'util-lodash'}
          name: "cloudinary-main"
          out: "dist/cloudinary.js"
      'cloudinary-jquery':
        options:
          map:
            "*": {util: 'util-jquery'}
          name: "jquery-extension"
          out: "dist/jquery.noupload.cloudinary.js"
      'cloudinary-jquery-file-upload':
        options:
          map:
            "*": {util: 'util-jquery'}
          name: "cloudinary-fileupload"
          out: "dist/jquery.noupload.cloudinary.js"



  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-requirejs')
  grunt.loadNpmTasks('grunt-jsdoc')
  grunt.loadNpmTasks('grunt-karma')
  grunt.registerTask('default', ['coffee', 'jsdoc'])
  grunt.registerTask('build', ['coffee', 'jsdoc', 'uglify'])
