wd = './demo/img'
output = './demo/js/data.js'
ColorThief = require('color-thief')
#ColorThief = require('./src/color-bandit.js')
#Canvas = require('canvas')
#Image = Canvas.Image

fs = require 'fs'

getPalette = (sourceImage, colorCount, quality) ->
  colorCount = 10  if typeof colorCount is "undefined"
  quality = 10  if typeof quality is "undefined"

  # Create custom CanvasImage object
  image = new CanvasImage(sourceImage)
  imageData = image.getImageData()
  pixels = imageData.data
  pixelCount = image.getPixelCount()
  palette = @getPaletteFromPixels(pixels, pixelCount, colorCount, quality)

  # Clean up
  image.removeCanvas()
  palette


module.exports = ->

  grunt = @

  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    componentbuild:
      'gss-springs':
        options:
          name: 'gss-springs'
        src: '.'
        dest: 'browser'
        scripts: true
        styles: false

    # JavaScript minification for the browser
    uglify:
      options:
        report: 'min'
      chromatose:
        files:
          './browser/springs.min.js': ['./browser/springs.js']

    # Automated recompilation and testing when developing
    watch:
      files: ['**/*.coffee']
      tasks: ['build']

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['spec/**/*.coffee']
      options:
        reporter: 'spec'

    # CoffeeScript compilation
    coffee:
      spec:
        options:
          bare: true
        expand: true
        cwd: 'spec'
        src: ['**/*.coffee']
        dest: 'spec'
        ext: '.js'
      src:
        options:
          bare: true
        expand: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'lib'
        ext: '.js'
      demo:
        options:
          bare: true
        expand: true
        cwd: 'demo/js'
        src: ['**/*.coffee']
        dest: 'demo/js'
        ext: '.js'

    # BDD tests on browser
    mocha_phantomjs:
      all: ['spec/runner.html']


  @registerTask 'colors', 'Extract Colors', () ->
    #imgs = fs.readdirSync wd
    #for img in imgs
    #
    #  colorThief = new ColorThief()
    #  console.log colorThief.getColor "./demo/img/" + img

    images = []

    grunt.file.recurse wd, (abspath, rootdir, subdir, filename) ->
      colorThief = new ColorThief()
      #console.log abspath
      colorThief.getPalette "./" + abspath, 5, 10, (colors)->
        abs = abspath.split('/')
        img =
          url:'./img/' + abs[abs.length - 1]
          colors:[]
        for color in colors
          img.colors.push "rgb(#{color[0]},#{color[1]},#{color[2]})"
        images.push img

    grunt.file.write output, "window.DEMO_DATA = {images:" + JSON.stringify( images, 1, 1) + "};"

    #grunt.file.write output+"/manifest.json", JSON.stringify( manifest, 1, 1)
    #grunt.file.write output+"/manifest.yml", yaml.safeDump manifest

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-component-build'
  @loadNpmTasks 'grunt-contrib-uglify'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-mocha-phantomjs'
  @loadNpmTasks 'grunt-contrib-watch'

  @registerTask 'build', ['coffee',  'componentbuild', 'colors',  'uglify']
  @registerTask 'test', ['build', 'cafemocha', 'mocha_phantomjs']
  @registerTask 'default', ['build']
