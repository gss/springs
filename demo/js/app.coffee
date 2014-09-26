
#window.chromatose = require 'chromatose'

Springs = require 'gss-springs'

springs = new Springs()

document.addEventListener 'DOMContentLoaded', ->
  render()
  setupSprings()

render = () ->

  renderer = ECT({ root : './views' , open:"{{", close:"}}"})
  data = window.DEMO_DATA
  html = renderer.render('template.ect', data)
  document.getElementById('mount').innerHTML = html

setupSprings = ->

  springs.attach document.getElementsByClassName('spring'), {
    event:'click'
    spring: {
      t:40
      f:4
    },
    transforms: {
      s:[1,.7]
      rz:[0,10]
    }
  }

  springs.attach document.querySelectorAll('section:nth-child(odd) .box'), {
    event:'inview'
    delay: 700
    dispatcher: (el) ->
      return el.parentElement
    spring: {
      t:3
      f:8
    }
    transforms: {
      x:[700,0]
    }
  }

  springs.attach document.querySelectorAll('section:nth-child(even) .box'), {
    event:'inview'
    delay: 700
    dispatcher: (el) ->
      return el.parentElement
    spring: {
      t:3
      f:8
    }
    transforms: {
      x:[-700,0]
    }
  }


  springs.attach document.querySelectorAll('section:nth-child(odd) button'), {
    event:'inview'
    dispatcher: (el) ->
      return el.parentElement.parentElement
    delay: 1500
    spring: {
      t:18
      f:8
    }
    transforms: {
      s: [0,1]
      rz:[90,0]
      y: [200,0]
      x: [800,0]
    }
  }
  springs.attach document.querySelectorAll('section:nth-child(even) button'), {
    event:'inview'
    dispatcher: (el) ->
      return el.parentElement.parentElement
    delay: 1500
    spring: {
      t:17
      f:8
    }
    transforms: {
      s:[0,1]
      rz:[-90,0]
      y: [-200,0]
      x: [-800,0]
    }
  }

  springs.attach document.querySelectorAll('section:nth-child(odd) .media'), {
    event:'inview'
    dispatcher: (el) ->
      return el.parentElement
    spring: {
      t:20
      f:6
    }
    transforms: {
      s: [.8,1]
      #x: [100,0]
      #y: [-40,0]
    }
  }
  springs.attach document.querySelectorAll('section:nth-child(even) .media'), {
    event:'inview'
    dispatcher: (el) ->
      return el.parentElement
    spring: {
      t:20
      f:6
    }
    transforms: {
      s: [.8,1]
      #x: [-100,0]
      #y: [-40,0]
    }
  }

