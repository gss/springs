rebound = require 'rebound'

###
changeFriction = (val) ->
  springConfig.friction = rebound.OrigamiValueConverter.frictionFromOrigamiValue(val)

changeTension = (val) ->
  springConfig.friction = rebound.OrigamiValueConverter.tensionFromOrigamiValue(val)
###

createSpring = createSpring = (springSystem, friction, tension, rawValues) ->
  spring = springSystem.createSpring()
  springConfig = undefined
  if rawValues
    springConfig = new rebound.SpringConfig(friction, tension)
  else
    springConfig = rebound.SpringConfig.fromOrigamiTensionAndFriction(friction, tension)
  spring.setSpringConfig springConfig
  spring.setCurrentValue 0
  spring


mapValueFromRangeToRange = (value, fromLow, fromHigh, toLow, toHigh) ->
  fromRangeSize = fromHigh - fromLow
  toRangeSize = toHigh - toLow
  valueScale = (value - fromLow) / fromRangeSize
  toLow + (valueScale * toRangeSize)

downEvt = (if window.ontouchstart isnt `undefined` then "touchstart" else "mousedown")
upEvt = (if window.ontouchend isnt `undefined` then "touchend" else "mouseup")

# Create a couple of utilities.
slice = Array::slice
concat = Array::concat
bind = (func, context) ->
  args = slice.call(arguments, 2)
  ->
    func.apply context, concat.call(args, slice.call(arguments))
    return

extend = (target, source) ->
  for key of source
    target[key] = source[key]  if source.hasOwnProperty(key)
  return


CustomEvent = (event, parans) ->
  parans = parans or
    bubbles: false
    cancelable: false
    detail: `undefined`

  evt = document.createEvent "CustomEvent"
  evt.initCustomEvent event, parans.bubbles, parans.cancelable, parans.detail
  evt
CustomEvent:: = window.Event::
window.CustomEvent = CustomEvent



class Springs

  constructor: ->
    @springs = []
    @springsByEvent = {click:[],inview:[]}
    @springSystem = new rebound.SpringSystem()

    document.addEventListener 'DOMContentLoaded', =>
      document.body.addEventListener upEvt, () =>
        for spring in @springsByEvent.click
          spring.setEndValue 0

    if window.addEventListener
        addEventListener('DOMContentLoaded', @checkInViews, false)
        addEventListener('load', @checkInViews, false)
        addEventListener('scroll', @checkInViews, false)
        addEventListener('resize', @checkInViews, false)

    else if window.attachEvent
        attachEvent('onDOMContentLoaded', @checkInViews); # IE9+ :(
        attachEvent('onload', @checkInViews)
        attachEvent('onscroll', @checkInViews)
        attachEvent('onresize', @checkInViews)


  isInView: (el) ->
    rect = el.getBoundingClientRect()

    return rect.top >= 0 and
      rect.left >= 0 and
      rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) and
      rect.right <= (window.innerWidth || document.documentElement.clientWidth)

  checkInViews: () =>

    len = @springsByEvent?.inview?.length
    return unless len
    i = 0

    e = new CustomEvent 'inview', { detail: {}, bubbles: false, cancelable: true}

    while i < len
      el = @springsByEvent.inview[i].dispatchEl

      if @isInView(el)
        if !el.classList.contains 'inview'
          el.classList.add 'inview'
          el.dispatchEvent e
      i++

  attach: (els, o) ->

    # apply defaults
    {event,dispatcher,spring,transforms,delay} = o
    event or event = 'click'
    spring.t or spring.t = 40
    spring.f or spring.f = 4
    transforms or transforms = {}
    o = {event,dispatcher,spring,transforms,delay}


    for el in els
      @_attach el, o


  _attach: (el, o) ->

    {event,dispatcher,spring,transforms,delay} = o

    spring = createSpring @springSystem, spring.t, spring.f

    #spring.el = el

    if !@springsByEvent[event] then @springsByEvent[event] = []

    @springsByEvent[event].push(spring) if @springsByEvent[event].indexOf(spring) is -1
    @springs.push(spring) if @springs.indexOf(spring) is -1

    springConfig = spring.getSpringConfig()

    dispatchEl = el
    if dispatcher
      if typeof dispatcher is 'function'
        dispatchEl = dispatcher el

    spring.dispatchEl  = dispatchEl

    if event is 'click'
      dispatchEl.addEventListener downEvt, () ->
        spring.setEndValue(1)

    else if event is 'inview'
      dispatchEl.addEventListener 'inview', () ->
        if delay
          setTimeout ->
            spring.setEndValue(1)
          , delay
        else
          spring.setEndValue(1)

    @applyInitialValue el, transforms

    that = this

    spring.addListener
      el: null,
      onSpringUpdate: (spring) ->
        @el = @el or el
        val = spring.getCurrentValue()
        that.applySpringValue @el,transforms, val

  applyInitialValue: (el,t) ->
    @setTransforms el, {
      x:t.x?[0],
      y:t.y?[0],
      z:t.z?[0],
      s:t.s?[0],
      rx:t.rx?[0],
      ry:t.ry?[0],
      rz:t.rz?[0]
    }

  applySpringValue: (el,transforms,val) =>

    if val is 0
      return @applyInitialValue el, transforms

    {x,y,z,s,r,rx,ry,rz} = transforms

    if x
      x = mapValueFromRangeToRange(val, 0, 1, x[0], x[1])
    if y
      y = mapValueFromRangeToRange(val, 0, 1, y[0], y[1])
    if z
      z = mapValueFromRangeToRange(val, 0, 1, z[0], z[1])

    if s?
      s = mapValueFromRangeToRange(val, 0, 1, s[0], s[1])

    if rx
      rx = mapValueFromRangeToRange(val, 0, 1, rx[0], rx[1])
    if ry
      ry = mapValueFromRangeToRange(val, 0, 1, ry[0], ry[1])
    if rz
      rz = mapValueFromRangeToRange(val, 0, 1, rz[0], rz[1])

    @setTransforms(el, {x,y,z,s,r,rx,ry,rz})

  setTransforms: (el, {x, y, z, s, rx, ry, rz}) ->

    x or x = 0
    y or y = 0
    z or z = 0
    transform = "translate3d(#{x}px, #{y}px, #{z}px)"

    if s?
      transform += " scale3d(" + s + ", " + s + ", 1)"

    if rx
      transform += " rotateX(#{rx}deg)"
    if ry
      transform += " rotateY(#{ry}deg)"
    if rz
      transform += " rotateZ(#{rz}deg)"

    el.style.mozTransform = el.style.msTransform = el.style.webkitTransform = el.style.transform = transform

    return

module.exports = Springs