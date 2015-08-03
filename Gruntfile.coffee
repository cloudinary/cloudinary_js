module.exports = (grunt)->
  grunt.initConfig
    coffee:
      compile:
        options:
          join: true
          bare: true
        files:
          'js/cloudinary.js': [
            'src/header.coffee'
            'src/utils.coffee'
            'src/cloudinary-main.coffee'
            'src/crc32.coffee'
            'src/utf8_encode.coffee'
            'src/config.coffee'
            'src/parameters.coffee'
            'src/transformation.coffee'
            'src/htmltag.coffee'
            'src/footer.coffee'
          ]
          'js/jquery.noupload.cloudinary.js': [ # TODO name
            'src/header-jquery.coffee'
            'src/utils.coffee'
            'src/cloudinary-main.coffee'
            'src/crc32.coffee'
            'src/utf8_encode.coffee'
            'src/config.coffee'
            'src/parameters.coffee'
            'src/transformation.coffee'
            'src/htmltag.coffee'
            'src/jquery-extension.coffee'
            'src/footer.coffee'
          ]
          'js/jquery.cloudinary.js': [
            'src/header-jquery-upload.coffee'
            'src/utils.coffee'
            'src/cloudinary-main.coffee'
            'src/crc32.coffee'
            'src/utf8_encode.coffee'
            'src/config.coffee'
            'src/parameters.coffee'
            'src/transformation.coffee'
            'src/htmltag.coffee'
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



    concat:
      "js/cloudinary.coffee": [
        'src/header.coffee'
        'src/cloudinary-main.coffee'
        'src/crc32.coffee'
        'src/utf8_encode.coffee'
        'src/config.coffee'
        'src/parameters.coffee'
        'src/transformation.coffee'
        'src/htmltag.coffee'
        'src/footer.coffee'
      ]
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.registerTask('default', ['concat', 'coffee'])