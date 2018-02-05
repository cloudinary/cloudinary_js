module.exports = (grunt)->
  repos = [
    'cloudinary-core',
    'cloudinary-core-shrinkwrap',
    'cloudinary-jquery',
    'cloudinary-jquery-file-upload'
  ]

  lodashCalls = grunt.file.read('src/util/lodash.coffee').match(/_\.\w+/g)
  lodashInclude = []
  # gather unique function names
  lodashInclude.push(func[2..]) for func in lodashCalls when lodashInclude.indexOf(func[2..]) < 0
  lodashInclude.sort()

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
      'test/spec/spec-helper.js'
      'test/spec/cloudinary-spec.js'
      'test/spec/transformation-spec.js'
      'test/spec/tagspec.js'
      'test/spec/videourlspec.js'
      'test/spec/chaining-spec.js'
      'test/spec/conditional-transformation-spec.js'
      'test/spec/layer-spec.js'
    ]
    karma:
      options:
        reporters: ['dots']
        configFile: 'karma.coffee'
        browsers: grunt.option("browsers")?.toString().split(",") || ['Chrome' , 'Firefox', 'PhantomJS'] # 'Safari' disabled until window.open is resolved
        browserDisconnectTolerance: 3
        singleRun: !grunt.option("watch")
        files: [
          { pattern: 'test/docRoot/*', watched: false, included: false, served: true, nocache: false}
          { pattern: 'test/docRoot/css/*', watched: false, included: false, served: true, nocache: false}
          { pattern: 'bower_components/bootstrap/dist/css/*', watched: false, included: false, served: true, nocache: false}
          { pattern: 'bower_components/bootstrap/dist/js/*', watched: false, included: false, served: true, nocache: false}
        ]

      'cloudinary-core':
        files:
          src:
            [
              "bower_components/lodash/lodash.js"
              "<%= karmaCommon %>"
              "test/spec/responsive-core-spec.js"
            ]


      'cloudinary-core-shrinkwrap':
        files:
          src: [
              "<%= karmaCommon %>"
              "test/spec/responsive-shrinkwrap-spec.js"
            ]

      'cloudinary-jquery':
        files:
          src: [
              "bower_components/jquery/dist/jquery.js"
              "<%= karmaCommon %>"
              "test/spec/responsive-jquery-spec.js"
            ]

      'cloudinary-jquery-file-upload':
        files:
          src: [
              "bower_components/jquery/dist/jquery.js"
              "bower_components/blueimp-file-upload/js/vendor/jquery.ui.widget.js"
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
        options:
          process: (content, srcpath) ->
            if /build.cloudinary-jquery-file-upload\.js/.test(srcpath)
              content.replace( /\/\/# sourceMappingURL=cloudinary-jquery-file-upload.js.map/g, "")
            else
              content
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
            src: 'build/cloudinary-jquery-file-upload.js'
            dest: 'js/jquery.cloudinary.js'
          }
        ]
      dist:
        files: for repo in repos
          dest = if /shrinkwrap/.test(repo) then "cloudinary-core" else repo
          {'cwd': 'build','src': ["#{repo}.js", "#{repo}.min.js", "#{repo}.min.js.map", "#{repo}.d.ts"], 'dest': "../pkg/pkg-#{dest}/", 'expand': true}
        options:
          process: (content, srcpath) ->
            if /min.js/.test(srcpath)
              content
            else
              content.replace( /\/\/# sourceMappingURL=.+js\.map/g, "")
      docs:
        files: for repo in repos when !/shrinkwrap/.test(repo)
          expand: true
          cwd: "doc/pkg-#{repo}/"
          src: ["**"]
          dest: "../pkg/pkg-#{repo}/docs"
      types:
        files: [
          {
            src: "types/cloudinary-core.d.ts",
            expand: true,
            flatten: true,
            dest: "build/"
          }
        ]

    ts:
      default:
        tsconfig: true

    version:
     options:
       release: 'patch'
       flags: 'ig'
     package:
       files: [
         {src: ['bower.json', 'package.json', 'src/cloudinary.coffee']},
         {expand: true, src: ['../pkg/pkg-*/bower.json', '../pkg/pkg-*/package.json']}
         ]
    srcList: [
      'src/utf8_encode.coffee',
      'src/crc32.coffee',
      'src/layer/layer.coffee',
      'src/layer/fetchlayer.coffee',
      'src/layer/textlayer.coffee',
      'src/layer/subtitleslayer.coffee',
      'src/parameters.coffee',
      'src/expression.coffee',
      'src/condition.coffee',
      'src/configuration.coffee',
      'src/transformation.coffee',
      'src/tags/htmltag.coffee',
      'src/tags/imagetag.coffee',
      'src/tags/videotag.coffee',
      'src/tags/clienthintsmetatag.coffee',
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
            <%= /jquery|shrink/.test(grunt.task.current.target) ?
                  "" :
                  "factoryWrapper = (#{lodashInclude.join(', ')}) -> #{
                    "factory {#{lodashInclude.map((include) -> [include, include].join(': ')).join(', ')}}"
                  }" %>
            if (typeof define == 'function') && define.amd
              define  <%= /jquery/.test(grunt.task.current.target) ? "['jquery'], factory" : (/shrink/.test(grunt.task.current.target) ? "factory" : "[#{lodashInclude.map((include) -> "'lodash/#{include}'").join(', ')}], factoryWrapper" )%>
            else if typeof exports == 'object'
              module.exports = <%= /jquery/.test(grunt.task.current.target) ? "factory(require('jquery'))" : (/shrink/.test(grunt.task.current.target) ? "factory()" : "factoryWrapper(#{lodashInclude.map((include) -> "require('lodash/#{include}')").join(', ')})")%>
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
              ClientHintsMetaTag: ClientHintsMetaTag
              Layer: Layer
              FetchLayer: FetchLayer
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
          "src/util/baseutil.coffee"
          "src/util/lodash.coffee"
          "<%= srcList%>"
        ]
        dest: "build/cloudinary-core.coffee"
      'cloudinary-core-shrinkwrap':
        src: [
          "build/lodash-shrinkwrap.coffee"
          "src/util/baseutil.coffee"
          "src/util/lodash.coffee"
          "<%= srcList%>"
        ]
        dest: "build/cloudinary-core-shrinkwrap.coffee"
      'cloudinary-jquery':
        src: [
          "src/util/baseutil.coffee"
          "src/util/jquery.coffee"
          "<%= srcList%>"
          "src/cloudinaryjquery.coffee"
        ]
        dest: "build/cloudinary-jquery.coffee"
      'cloudinary-jquery-file-upload':
        src: [
          "src/util/baseutil.coffee"
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
  grunt.loadNpmTasks('grunt-ts')

  grunt.registerTask('default', ['concat', 'coffee'])
  grunt.registerTask('compile', ['clean:build', 'clean:js', 'concat', 'coffee', 'copy:backward-compatible'])
  grunt.registerTask('build', ['clean', 'concat', 'coffee', 'uglify', 'copy:backward-compatible', 'copy:types', 'jsdoc'])
  grunt.registerTask('lodash', (name, target)->
    require('lodash-cli')([
      "include=#{lodashInclude.join(',')}",
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
