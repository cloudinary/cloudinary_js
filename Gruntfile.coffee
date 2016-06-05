module.exports = (grunt)->
  repos = [
    'cloudinary-core',
    'cloudinary-core-shrinkwrap',
    'cloudinary-jquery',
    'cloudinary-jquery-file-upload'
  ]

#  grunt.initConfig
  gruntOptions =
    pkg: grunt.file.readJSON('package.json')

    coffee:
      options:
        bare: true
        sourceMap: true
      sources:
        cwd: 'src'
        expand: true
        src: ['**/*.coffee']
        dest: 'src'
        ext: '.js'
      test:
        expand: true
        cwd: 'test/spec'
        src: ['*.coffee']
        dest: 'test/spec'
        ext: '.js'
      build:
        expand: true
        bare: false
        sourceMap: true
        cwd: 'build'
        src: ['*.coffee']
        dest: 'build'
        ext: '.js'
      legacy:
        expand: false
        bare: false
        sourceMap: true
        cwd: '.'
        src: 'js/jquery.cloudinary.coffee'
        dest: 'js/jquery.cloudinary.js'
        ext: '.js'


    uglify:
      build:
        options:
          sourceMap: true
          mangle: false
        files: for repo in repos
          src: ["build/#{repo}.js"]
          dest: "build/#{repo}.min.js"
          ext: '.min.js'

    karmaCommon: [
      "build/<%= grunt.task.current.target %>.js"
      'test/spec/cloudinary-spec.js'
      'test/spec/transformation-spec.js'
      'test/spec/tagspec.js'
      'test/spec/videourlspec.js'
      'test/spec/chaining-spec.js'
      'test/spec/conditional-transformation-spec.js'
    ]
    karma:
      options:
        reporters: ['dots']
        configFile: 'karma.coffee'
        browserDisconnectTolerance: 3
      'cloudinary-core':
        files:
          src:
            [
              "bower_components/lodash/lodash.js"
              "<%= karmaCommon %>"
            ]


      'cloudinary-core-shrinkwrap':
        files:
          src: [
              "<%= karmaCommon %>"
            ]

      'cloudinary-jquery':
        files:
          src: [
              "bower_components/jquery/dist/jquery.js"
              "<%= karmaCommon %>"
            ]

      'cloudinary-jquery-file-upload':
        files:
          src: [
              "bower_components/jquery/dist/jquery.js"
              "bower_components/jquery.ui/ui/widget.js"
              "bower_components/blueimp-file-upload/js/jquery.fileupload.js"
              "bower_components/blueimp-file-upload/js/jquery.fileupload-process.js"
              "bower_components/blueimp-file-upload/js/jquery.iframe-transport.js"
              "bower_components/blueimp-file-upload/js/jquery.fileupload-image.js"
              "<%= karmaCommon %>"
              "test/spec/cloudinary-jquery-upload-spec.js"
            ]


    jsdoc:
      options:
        template: 'template'
        configure: "jsdoc-conf.json"
      'cloudinary-core':
        options:
          destination: "doc/pkg-<%=grunt.task.current.target%>"
        src: ["build/<%=grunt.task.current.target%>.js", './README.md']
      'cloudinary-jquery':
        options:
          destination: "doc/pkg-<%=grunt.task.current.target%>"
        src: ["build/<%=grunt.task.current.target%>.js", './README.md']
      'cloudinary-jquery-file-upload':
        options:
          destination: "doc/pkg-<%=grunt.task.current.target%>"
        src: ["build/<%=grunt.task.current.target%>.js", './README.md']

    clean:
      build: ["build/*", "!build/lodash*"]
      doc: ["doc"]
      js: ["js"]
    copy:
      'backward-compatible':
        # For backward compatibility, copy jquery.cloudianry.js and vendor files to the js folder
        files: [
          {
            expand: true
            flatten: true
            src: [
              "bower_components/blueimp-canvas-to-blob/js/canvas-to-blob.min.js"
              "bower_components/blueimp-load-image/js/load-image.all.min.js" # formerly load-image.min.js
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
            src: 'build/cloudinary-jquery-file-upload.coffee'
            dest: 'js/jquery.cloudinary.coffee'
          }
        ]
      dist:
        files: for repo in repos
          dest = if /shrinkwrap/.test(repo) then "cloudinary-core" else repo
          {'cwd': 'build','src': ["#{repo}.js", "#{repo}.min.js", "#{repo}.min.js.map"], 'dest': "../pkg/pkg-#{dest}/", 'expand': true}
      doc:
        files: for repo in repos when !/shrinkwrap/.test(repo)
          expand: true
          cwd: "doc/pkg-#{repo}/"
          src: ["**"]
          dest: "../pkg/pkg-#{repo}/"

    version:
      options:
        release: 'patch'
      package:
        src: ['bower.json', 'package.json']
      source:
        options:
          prefix: 'VERSION\\s+=\\s+[\'"]'
        src: ['src/cloudinary.coffee']
      dist:
        files: for repo in repos when !/shrinkwrap/.test(repo)
          src: ["../pkg/pkg-#{repo}/bower.json", "../pkg/pkg-#{repo}/package.json"]
          dest: "../pkg/pkg-#{repo}/"
    srcList: [
      'src/utf8_encode.coffee',
      'src/crc32.coffee',
      'src/parameters.coffee',
      'src/condition.coffee',
      'src/transformation.coffee',
      'src/configuration.coffee',
      'src/tags/htmltag.coffee',
      'src/tags/imagetag.coffee',
      'src/tags/videotag.coffee',
      'src/layer/layer.coffee',
      'src/layer/Textlayer.coffee',
      'src/layer/Subtitleslayer.coffee',
      'src/cloudinary.coffee'
    ],
    concat:
      options:
        dest: "build/<%= grunt.task.current.target %>.coffee"
        banner:
          """
          ###*
           * Cloudinary's JavaScript library - Version <%= pkg.version %>
           * Copyright Cloudinary
           * see https://github.com/cloudinary/cloudinary_js
           *
          ###

          ((root, factory) ->
            if (typeof define == 'function') && define.amd
              define  <%= /jquery/.test(grunt.task.current.target) ? "['jquery']," : (/shrink/.test(grunt.task.current.target) ? "" : "['lodash']," )%> factory
            else if typeof exports == 'object'
              module.exports = factory(<%= /jquery/.test(grunt.task.current.target) ? "require('jquery')" : (/shrink/.test(grunt.task.current.target) ? "" : "require('lodash')")%>)
            else
              root.cloudinary ||= {}
              for name, value of factory(<%=/jquery/.test(grunt.task.current.target) ? "jQuery" : (/shrink/.test(grunt.task.current.target) ? "" : "_")%>)
                root.cloudinary[name] = value
          )(this,  (<%=/jquery/.test(grunt.task.current.target) ? "jQuery" : (/shrink/.test(grunt.task.current.target) ? "" : "_")%>)->

          """

        footer:
          """

            cloudinary =
              utf8_encode: utf8_encode
              crc32: crc32
              Util: Util
              Condition: Condition
              Transformation: Transformation
              Configuration: Configuration
              HtmlTag: HtmlTag
              ImageTag: ImageTag
              VideoTag: VideoTag
              Layer: Layer
              TextLayer: TextLayer
              SubtitlesLayer: SubtitlesLayer
              Cloudinary: Cloudinary
              VERSION: "<%= pkg.version %>"
              <%=  /jquery/.test(grunt.task.current.target) ? "CloudinaryJQuery: CloudinaryJQuery" : ""%>

            cloudinary
          )
          """
        process: (src, path)->
          # add indentation to each source file
          "  " + src.replace( /\n/g, "\n  ")
      'cloudinary-core':
        src: [
          "src/util/lodash.coffee"
          "<%= srcList%>"
        ]
        dest: "build/cloudinary-core.coffee"
      'cloudinary-core-shrinkwrap':
        src: [
          "build/lodash-shrinkwrap.coffee"
          "src/util/lodash.coffee"
          "<%= srcList%>"
        ]
        dest: "build/cloudinary-core-shrinkwrap.coffee"
      'cloudinary-jquery':
        src: [
          "src/util/jquery.coffee"
          "<%= srcList%>"
          "src/cloudinaryjquery.coffee"
        ]
        dest: "build/cloudinary-jquery.coffee"
      'cloudinary-jquery-file-upload':
        src: [
          "src/util/jquery.coffee"
          "<%= srcList%>"
          "src/cloudinaryjquery.coffee"
          "src/jquery-file-upload.coffee"
        ]
        dest: "build/cloudinary-jquery-file-upload.coffee"


  grunt.initConfig(gruntOptions)

  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-requirejs')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-clean')

  grunt.loadNpmTasks('grunt-jsdoc')
  grunt.loadNpmTasks('grunt-karma')
  grunt.loadNpmTasks('grunt-version')

  grunt.registerTask('default', ['concat', 'coffee'])
  grunt.registerTask('compile', ['clean:build', 'clean:js', 'concat', 'copy:backward-compatible', 'coffee', 'copy:dist'])
  grunt.registerTask('build', ['clean', 'concat', 'copy:backward-compatible', 'coffee', 'jsdoc'])
  grunt.registerTask('lodash', (name, target)->
    lodashCalls = grunt.file.read('src/util/lodash.coffee').match(/_\.\w+/g)
    include = []
    # gather unique function names
    include.push(func[2..]) for func in lodashCalls when include.indexOf(func[2..]) < 0
    require('lodash-cli')([
      "include=#{include.join(',')}",
      "exports=none",
      "iife=var lodash = _ = (function() {%output%; \nreturn lodash;\n}.call(this));",
      "--output", "build/lodash-shrinkwrap.js",
      "--development"]
    , (data)->
      outputPath = data.outputPath
      sourceMap = data.sourceMap
      if outputPath
        grunt.file.write outputPath, data.source
        grunt.file.write "#{outputPath[0..-4]}.coffee", "\n`#{data.source.replace(/`/g, "'")}`"
        # .replace(/\n/g, "\n  ")
        if sourceMap
          grunt.file.write path.join(path.dirname(outputPath), path.basename(outputPath, '.js') + '.map'), sourceMap

    )
  )
