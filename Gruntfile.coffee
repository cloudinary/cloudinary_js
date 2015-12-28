module.exports = (grunt)->
  repos = [
    'cloudinary-core',
    'cloudinary-jquery',
    'cloudinary-jquery-file-upload'
  ]
  ###*
   * Create a task configuration that includes the given options item + a sibling for each target
   * @param {object} options - options common for all targets
   * @param {object|function} repoOptions - options specific for each repository
   * @returns {object} the task configuration
  ###
  repoTargets = (options, repoOptions)->
    options ||= {}
    options = {options: options} unless options.options?
    repoOptions ||= {}
    for repo in repos
      # noinspection JSUnresolvedFunction
      options[repo] = repoOptions?(repo) || repoOptions
    options

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

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
        files: for repo in repos
          src: ["build/#{repo}.js"]
          dest: "build/#{repo}.min.js"
          ext: '.min.js'

    karma: repoTargets
      reporters: ['dots']
      configFile: 'karma.<%= grunt.task.current.target %>.coffee'

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

    requirejs: repoTargets
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
        out: 'build/<%= grunt.task.current.target %>.js'
        name: 'namespace/<%= grunt.task.current.target %>'
        wrap:
          start:  """
            /*
             * Cloudinary's JavaScript library - Version <%= pkg.version %>
             * Copyright Cloudinary
             * see https://github.com/cloudinary/cloudinary_js
             */

            """
      ,
        (repo)->
          options:
            bundles:
              # build with the correct util library
              "#{if repo.match('jquery') then 'util/jquery' else 'util/lodash'}": ['util']
            onBuildWrite: (moduleName, path, contents)->
              # make the module anonymous
              contents.replace("'#{@name}',", "")

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

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-requirejs')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-clean')

  grunt.loadNpmTasks('grunt-jsdoc')
  grunt.loadNpmTasks('grunt-karma')
  grunt.loadNpmTasks('grunt-version')

  grunt.registerTask('default', ['coffee', 'requirejs'])
  grunt.registerTask('build', ['clean', 'coffee', 'requirejs', 'jsdoc', 'copy:backward-compatible'])
