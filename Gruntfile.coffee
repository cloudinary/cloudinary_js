module.exports = (grunt)->
  grunt.initConfig
    coffee:
      compile:
        options:
          join: true
          bare: false
        files:
          'js/cloudinary.js': [
            'src/crc32.coffee'
            'src/utf8_encode.coffee'
            'src/config.coffee'
            'src/parameters.coffee'
            'src/transformation.coffee'
          ],
          'js/jquery.cloudinary.js': [
            'src/jquery-extenion'
            'src/crc32.coffee'
            'src/utf8_encode.coffee'
            'src/config.coffee'
            'src/parameters.coffee'
            'src/transformation.coffee'
          ]
  grunt.loadNpmTasks('grunt-contrib-coffee')