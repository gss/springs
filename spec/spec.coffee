if window?
  springs = require 'springs'
else
  chai = require 'chai' unless chai
  springs  = require '../lib/springs'

{expect, assert} = chai

describe "springs", ->
  
  describe "hello", ->
  
    it "it's alive!", ->
      assert springs?