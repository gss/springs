var assert, chai, expect, springs;

if (typeof window !== "undefined" && window !== null) {
  springs = require('springs');
} else {
  if (!chai) {
    chai = require('chai');
  }
  springs = require('../lib/springs');
}

expect = chai.expect, assert = chai.assert;

describe("springs", function() {
  return describe("hello", function() {
    return it("it's alive!", function() {
      return assert(springs != null);
    });
  });
});
