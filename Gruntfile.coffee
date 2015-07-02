module.exports = (grunt)->
  grunt.initConfig
    coffee:
      compile:
        options:
          join: true
          bare: false
        files:
          'js/cloudinary.js': [
            'src/header.coffee'
            'src/crc32.coffee'
            'src/utf8_encode.coffee'
            'src/config.coffee'
            'src/parameters.coffee'
            'src/transformation.coffee'
            'src/cloudinary.coffee'
            'src/tag-helpers.coffee'
            'src/footer.coffee'
          ],
          'js/jquery.cloudinary.js': [
            'src/header.coffee'
            'src/jquery-extension'
            'src/crc32.coffee'
            'src/utf8_encode.coffee'
            'src/config.coffee'
            'src/parameters.coffee'
            'src/transformation.coffee'
            'src/cloudinary.coffee'
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
        'src/crc32.coffee'
        'src/utf8_encode.coffee'
        'src/config.coffee'
        'src/parameters.coffee'
        'src/transformation.coffee'
        'src/cloudinary.coffee'
        'src/tag-helpers.coffee'
        'src/footer.coffee'
      ]
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.registerTask('default', ['concat', 'coffee'])