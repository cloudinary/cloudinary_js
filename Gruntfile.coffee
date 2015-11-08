module.exports = (grunt)->
  repos = [
    'cloudinary',
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
      options[repo] = repoOptions?(repo) || repoOptions
    options

  grunt.initConfig
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
        files: [
          expand: true
          cwd: 'js'
          src: ['*cloudinary*.js', '!*min*', '../bower_components/blueimp-load-image/js/load-image.js']
          dest: 'js'
          ext: '.min.js'
          extDot: 'last'
        ]
    karma: repoTargets
      reporters: ['dots']
      configFile: 'karma.<%= grunt.task.current.target %>.coffee'
    jsdoc:
      amd:
        src: ['src/**/*.js', './README.md']
        options:
          destination: 'doc/amd'
          template: 'template'
          configure: "jsdoc-conf.json"
      dist: for repo in repos
        src: ["build/#{repo}.js", './README.md']
        options:
          destination: "doc/bower-#{repo}"
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
        name: '<%= grunt.task.current.target %>-full'
      ,
        (repo)-> { options: {bundles: { "#{if repo.match('jquery') then 'util/jquery' else 'util/lodash'}": ['util'] }}}
    copy:
      'backward-compatible':
        # For backward compatibility, copy jquery.cloudianry.js and vendor files to the js folder
        files: [
          {
            expand: true
            flatten: true
            src: [
              "bower_components/blueimp-canvas-to-blob/js/canvas-to-blob.min.js"
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
            src: "bower_components/blueimp-load-image/js/load-image.all.min.js"
            dest: "js/load-image.min.js"
          }
          {
            src: 'build/cloudinary-jquery-file-upload.js'
            dest: 'js/jquery.cloudinary.js'
          }
        ]
      'dist':
        files: for repo in repos
          {'src': "build/#{repo}.js", 'dest': "../bower/bower-#{repo}/#{repo}.js"}
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
          src: ["../bower/bower-#{repo}/bower.json", "../bower/bower-#{repo}/package.json"]
          dest: "../bower/bower-#{repo}/"

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-requirejs')
  grunt.loadNpmTasks('grunt-contrib-copy')

  grunt.loadNpmTasks('grunt-jsdoc')
  grunt.loadNpmTasks('grunt-karma')
  grunt.loadNpmTasks('grunt-version')

  grunt.registerTask('default', ['coffee', 'requirejs'])
  grunt.registerTask('build', ['coffee', 'requirejs', 'jsdoc:amd', 'copy:file-upload', 'uglify'])

