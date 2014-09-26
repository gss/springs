var CustomEvent, Springs, bind, concat, createSpring, downEvt, extend, mapValueFromRangeToRange, rebound, slice, upEvt,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

rebound = require('rebound');

/*
changeFriction = (val) ->
  springConfig.friction = rebound.OrigamiValueConverter.frictionFromOrigamiValue(val)

changeTension = (val) ->
  springConfig.friction = rebound.OrigamiValueConverter.tensionFromOrigamiValue(val)
*/


createSpring = createSpring = function(springSystem, friction, tension, rawValues) {
  var spring, springConfig;
  spring = springSystem.createSpring();
  springConfig = void 0;
  if (rawValues) {
    springConfig = new rebound.SpringConfig(friction, tension);
  } else {
    springConfig = rebound.SpringConfig.fromOrigamiTensionAndFriction(friction, tension);
  }
  spring.setSpringConfig(springConfig);
  spring.setCurrentValue(0);
  return spring;
};

mapValueFromRangeToRange = function(value, fromLow, fromHigh, toLow, toHigh) {
  var fromRangeSize, toRangeSize, valueScale;
  fromRangeSize = fromHigh - fromLow;
  toRangeSize = toHigh - toLow;
  valueScale = (value - fromLow) / fromRangeSize;
  return toLow + (valueScale * toRangeSize);
};

downEvt = (window.ontouchstart !== undefined ? "touchstart" : "mousedown");

upEvt = (window.ontouchend !== undefined ? "touchend" : "mouseup");

slice = Array.prototype.slice;

concat = Array.prototype.concat;

bind = function(func, context) {
  var args;
  args = slice.call(arguments, 2);
  return function() {
    func.apply(context, concat.call(args, slice.call(arguments)));
  };
};

extend = function(target, source) {
  var key;
  for (key in source) {
    if (source.hasOwnProperty(key)) {
      target[key] = source[key];
    }
  }
};

CustomEvent = function(event, parans) {
  var evt;
  parans = parans || {
    bubbles: false,
    cancelable: false,
    detail: undefined
  };
  evt = document.createEvent("CustomEvent");
  evt.initCustomEvent(event, parans.bubbles, parans.cancelable, parans.detail);
  return evt;
};

CustomEvent.prototype = window.Event.prototype;

window.CustomEvent = CustomEvent;

Springs = (function() {
  function Springs() {
    this.applySpringValue = __bind(this.applySpringValue, this);
    this.checkInViews = __bind(this.checkInViews, this);
    this.springs = [];
    this.springsByEvent = {};
    this.springSystem = new rebound.SpringSystem();
    document.body.addEventListener(upEvt, function() {
      var spring, _i, _len, _ref, _results;
      _ref = this.springsByEvent.click;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        spring = _ref[_i];
        _results.push(spring.setEndValue(0));
      }
      return _results;
    });
    if (window.addEventListener) {
      addEventListener('DOMContentLoaded', this.checkInViews, false);
      addEventListener('load', this.checkInViews, false);
      addEventListener('scroll', this.checkInViews, false);
      addEventListener('resize', this.checkInViews, false);
    } else if (window.attachEvent) {
      attachEvent('onDOMContentLoaded', this.checkInViews);
      attachEvent('onload', this.checkInViews);
      attachEvent('onscroll', this.checkInViews);
      attachEvent('onresize', this.checkInViews);
    }
  }

  Springs.prototype.isInView = function(el) {
    var rect;
    rect = el.getBoundingClientRect();
    return rect.top >= 0 && rect.left >= 0 && rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) && rect.right <= (window.innerWidth || document.documentElement.clientWidth);
  };

  Springs.prototype.checkInViews = function() {
    var e, el, i, len, _results;
    len = this.springsByEvent.inview.length;
    i = 0;
    e = new CustomEvent('inview', {
      detail: {},
      bubbles: false,
      cancelable: true
    });
    _results = [];
    while (i < len) {
      el = this.springsByEvent.inview[i].dispatchEl;
      if (this.isInView(el)) {
        if (!el.classList.contains('inview')) {
          el.classList.add('inview');
          el.dispatchEvent(e);
        }
      }
      _results.push(i++);
    }
    return _results;
  };

  Springs.prototype.attach = function(els, o) {
    var delay, dispatcher, el, event, spring, transforms, _i, _len, _results;
    event = o.event, dispatcher = o.dispatcher, spring = o.spring, transforms = o.transforms, delay = o.delay;
    event || (event = 'click');
    spring.t || (spring.t = 40);
    spring.f || (spring.f = 4);
    transforms || (transforms = {});
    o = {
      event: event,
      dispatcher: dispatcher,
      spring: spring,
      transforms: transforms,
      delay: delay
    };
    _results = [];
    for (_i = 0, _len = els.length; _i < _len; _i++) {
      el = els[_i];
      _results.push(this._attach(el, o));
    }
    return _results;
  };

  Springs.prototype._attach = function(el, o) {
    var delay, dispatchEl, dispatcher, event, spring, springConfig, that, transforms;
    event = o.event, dispatcher = o.dispatcher, spring = o.spring, transforms = o.transforms, delay = o.delay;
    spring = createSpring(this.springSystem, spring.t, spring.f);
    if (!this.springsByEvent[event]) {
      this.springsByEvent[event] = [];
    }
    if (this.springsByEvent[event].indexOf(spring) === -1) {
      this.springsByEvent[event].push(spring);
    }
    if (this.springs.indexOf(spring) === -1) {
      this.springs.push(spring);
    }
    springConfig = spring.getSpringConfig();
    dispatchEl = el;
    if (dispatcher) {
      if (typeof dispatcher === 'function') {
        dispatchEl = dispatcher(el);
      }
    }
    spring.dispatchEl = dispatchEl;
    if (event === 'click') {
      dispatchEl.addEventListener(downEvt, function() {
        return spring.setEndValue(1);
      });
    } else if (event === 'inview') {
      dispatchEl.addEventListener('inview', function() {
        if (delay) {
          return setTimeout(function() {
            return spring.setEndValue(1);
          }, delay);
        } else {
          return spring.setEndValue(1);
        }
      });
    }
    this.applyInitialValue(el, transforms);
    that = this;
    return spring.addListener({
      el: null,
      onSpringUpdate: function(spring) {
        var val;
        this.el = this.el || el;
        val = spring.getCurrentValue();
        return that.applySpringValue(this.el, transforms, val);
      }
    });
  };

  Springs.prototype.applyInitialValue = function(el, t) {
    var _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
    return this.setTransforms(el, {
      x: (_ref = t.x) != null ? _ref[0] : void 0,
      y: (_ref1 = t.y) != null ? _ref1[0] : void 0,
      z: (_ref2 = t.z) != null ? _ref2[0] : void 0,
      s: (_ref3 = t.s) != null ? _ref3[0] : void 0,
      rx: (_ref4 = t.rx) != null ? _ref4[0] : void 0,
      ry: (_ref5 = t.ry) != null ? _ref5[0] : void 0,
      rz: (_ref6 = t.rz) != null ? _ref6[0] : void 0
    });
  };

  Springs.prototype.applySpringValue = function(el, transforms, val) {
    var r, rx, ry, rz, s, x, y, z;
    if (val === 0) {
      return this.applyInitialValue(el, transforms);
    }
    x = transforms.x, y = transforms.y, z = transforms.z, s = transforms.s, r = transforms.r, rx = transforms.rx, ry = transforms.ry, rz = transforms.rz;
    if (x) {
      x = mapValueFromRangeToRange(val, 0, 1, x[0], x[1]);
    }
    if (y) {
      y = mapValueFromRangeToRange(val, 0, 1, y[0], y[1]);
    }
    if (z) {
      z = mapValueFromRangeToRange(val, 0, 1, z[0], z[1]);
    }
    if (s != null) {
      s = mapValueFromRangeToRange(val, 0, 1, s[0], s[1]);
    }
    if (rx) {
      rx = mapValueFromRangeToRange(val, 0, 1, rx[0], rx[1]);
    }
    if (ry) {
      ry = mapValueFromRangeToRange(val, 0, 1, ry[0], ry[1]);
    }
    if (rz) {
      rz = mapValueFromRangeToRange(val, 0, 1, rz[0], rz[1]);
    }
    return this.setTransforms(el, {
      x: x,
      y: y,
      z: z,
      s: s,
      r: r,
      rx: rx,
      ry: ry,
      rz: rz
    });
  };

  Springs.prototype.setTransforms = function(el, _arg) {
    var rx, ry, rz, s, transform, x, y, z;
    x = _arg.x, y = _arg.y, z = _arg.z, s = _arg.s, rx = _arg.rx, ry = _arg.ry, rz = _arg.rz;
    x || (x = 0);
    y || (y = 0);
    z || (z = 0);
    transform = "translate3d(" + x + "px, " + y + "px, " + z + "px)";
    if (s != null) {
      transform += " scale3d(" + s + ", " + s + ", 1)";
    }
    if (rx) {
      transform += " rotateX(" + rx + "deg)";
    }
    if (ry) {
      transform += " rotateY(" + ry + "deg)";
    }
    if (rz) {
      transform += " rotateZ(" + rz + "deg)";
    }
    el.style.mozTransform = el.style.msTransform = el.style.webkitTransform = el.style.transform = transform;
  };

  return Springs;

})();

module.exports = Springs;
