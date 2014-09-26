module.exports = ->

  @initConfig

    # Build the browser Component
    componentbuild:
      errorReporter:
        options:
          name: 'error-reporter'
        src: '.'
        dest: 'browser'
        scripts: true
        styles: false

    # JavaScript minification for the browser
    uglify:
      options:
        report: 'min'
      errorReporter:
        files:
          'browser/error-reporter.min.js': ['browser/error-reporter.js']

    # BDD tests on Node.js
    cafemocha:
      ccssCompiler:
        src: ['spec/**/*.coffee']
        options:
          # For some reason the default reporter is 'list'
          # See https://github.com/jdavis/grunt-cafe-mocha/issues/11
          reporter: 'spec'

    # CoffeeScript compilation
    coffee:
      src:
        options:
          bare: true
        expand: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'lib'
        ext: '.js'
      spec:
        options:
          bare: true
        expand: true
        cwd: 'spec'
        src: ['**/*.coffee']
        dest: 'spec'
        ext: '.js'

    # BDD tests on browser
    mocha_phantomjs:
      ccssCompiler: ['spec/runner.html']

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-component-build'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-contrib-uglify'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-mocha-phantomjs'

  @registerTask 'build', ['coffee:src', 'componentbuild', 'uglify']

  @registerTask 'test', [
    'build'
    'cafemocha'
    'coffee:spec'
    'mocha_phantomjs'
  ]
