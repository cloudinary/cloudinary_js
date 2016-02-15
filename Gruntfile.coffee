module.exports = (grunt)->
  repos = [
    'cloudinary-core',
    'cloudinary-core-shrinkwrap',
    'cloudinary-jquery',
    'cloudinary-jquery-file-upload'
  ]
  ###*
   * Create a task configuration that includes the given options item + a sibling for each target
   * @param {object} options - options common for all targets
   * @param {object|function} repoOptions - options specific for each repository
   * @returns {object} the task configuration
  ###
  repoTargets = (options={}, repoOptions={})->
    options = {options: options} unless options.options?
    for repo in repos
      # noinspection JSUnresolvedFunction
      options[repo] = repoOptions?(repo) || repoOptions
    options

#  grunt.initConfig
  gruntOptions =
    pkg: grunt.file.readJSON('package.json')

    coffee:
      sources:
        expand: true
        bare: false
        sourceMap: true
        cwd: 'src'
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

    karma: repoTargets
        reporters: ['dots']
        configFile: 'karma.coffee'
        browserDisconnectTolerance: 3
        ,
        (repo)->
          repoFiles = switch
            when repo.match /shrink/
              ["build/#{repo}.js"]
            when repo.match /upload/
              [
                "bower_components/jquery/dist/jquery.js"
                'bower_components/jquery.ui/ui/widget.js'
                'bower_components/blueimp-file-upload/js/jquery.fileupload.js'
                'bower_components/blueimp-file-upload/js/jquery.fileupload-process.js'
                'bower_components/blueimp-file-upload/js/jquery.iframe-transport.js'
                'bower_components/blueimp-file-upload/js/jquery.fileupload-image.js'
                "build/#{repo}.js"
                'test/spec/cloudinary-jquery-spec.js'
                'test/spec/cloudinary-jquery-upload-spec.js'
              ]
            when repo.match /jquery/
              [
                "bower_components/jquery/dist/jquery.js"
                "build/#{repo}.js"
                'test/spec/cloudinary-jquery-spec.js'
              ]
            else
              [
                "bower_components/lodash/lodash.js"
                "build/#{repo}.js"
              ]
          files: [
            src: repoFiles.concat [
              'test/spec/cloudinary-spec.js'
              'test/spec/tagspec.js'
              'test/spec/videourlspec.js'
              'test/spec/chaining-spec.js'
            ]
          ]
        ,
          repos.concat( "#{t}.min" for t in repos) # test minified version too

    jsdoc: repoTargets
        options: {}
        amd:
          src: ['src/**/*.js', './README.md']
          options:
            destination: 'doc/amd'
            template: 'template'
            configure: "jsdoc-conf.json"
      ,
        (repo)->
          src: ["build/#{repo}.js", './README.md']
          options:
            destination: "doc/pkg-#{repo}"
            template: 'template'
            configure: "jsdoc-conf.json"

    clean:
      build: ["build"]
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
            src: 'build/cloudinary-jquery-file-upload.js'
            dest: 'js/jquery.cloudinary.js'
          }
        ]
      dist:
        files: for repo in repos
          {'src': "build/#{repo}.js", 'dest': "../pkg/pkg-#{repo}/#{repo}.js"}
      doc:
        files: for repo in repos
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
        files: for repo in repos
          src: ["../pkg/pkg-#{repo}/bower.json", "../pkg/pkg-#{repo}/package.json"]
          dest: "../pkg/pkg-#{repo}/"
    concat:
      repoTargets
          process: (src, path)->
            "  " + src.replace( /\n/g, "\n  ")
        ,
          (repo)->
            [dependency, dependencyVar, utilFile] = switch
              when /shrinkwrap/.test(repo)
                ["","", ["build/lodash-shrinkwrap.coffee", "src/util/lodash.coffee"]]
              when /core/.test(repo)
                ["lodash", '_', "src/util/lodash.coffee"]
              when /jquery/.test(repo)
                ["jquery", "jQuery", "src/util/jquery.coffee"]
              else
                ["","", ""]
            srcList = [
              'src/utf8_encode.coffee',
              'src/crc32.coffee',
              utilFile,
              'src/parameters.coffee',
              'src/transformation.coffee',
              'src/configuration.coffee',
              'src/tags/htmltag.coffee',
              'src/tags/imagetag.coffee',
              'src/tags/videotag.coffee',
              'src/cloudinary.coffee'
            ]
            srcList.push('src/cloudinaryjquery.coffee')  if /jquery/.test(repo)
            srcList.push('src/jquery-file-upload.coffee') if /upload/.test(repo)

            defineArray = requireVar = ""
            if dependency?.length > 0
              defineArray = "['#{ dependency }'],"
              requireVar = "require('#{dependency}')"

            options:
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
                    define  #{defineArray} factory
                  else if typeof exports == 'object'
                    module.exports = factory(#{requireVar})
                  else
                    root.cloudinary ||= {}
                    root.cloudinary = factory(#{dependencyVar})
                )(this,  (#{dependencyVar})->

                """

              footer:
                """

                  cloudinary =
                    utf8_encode: utf8_encode
                    crc32: crc32
                    Util: Util
                    Transformation: Transformation
                    Configuration: Configuration
                    HtmlTag: HtmlTag
                    ImageTag: ImageTag
                    VideoTag: VideoTag
                    Cloudinary: Cloudinary
                    #{ if /jquery/.test(repo) then "CloudinaryJQuery: CloudinaryJQuery" else ""}

                  cloudinary
                )
                """
            src: srcList
            dest: "build/#{repo}.coffee"

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
  grunt.registerTask('build', ['clean', 'lodash','concat', 'coffee', 'jsdoc', 'copy:backward-compatible'])
  grunt.registerTask('lodash', (name, target)->
    lodashCalls = grunt.file.read('src/util/lodash.coffee').match(/_\.\w+/g)
    include = []
    # gather unique function names
    include.push(func[2..]) for func in lodashCalls when include.indexOf(func[2..]) < 0
    require('lodash-cli')([
      "include=#{include.join(',')}",
      "exports=none",
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
