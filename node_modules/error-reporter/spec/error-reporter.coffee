if window?
  ErrorReporter = require 'error-reporter'
else
  ErrorReporter = require '../lib/error-reporter'
  chai = require 'chai'
  sinon = require 'sinon'

{expect} = chai


describe 'Error reporter', ->

  describe 'creating an instance', ->

    context 'without source code', ->
      it 'should throw an error', ->
        exercise = -> new ErrorReporter
        expect(exercise).to.throw Error, 'Source code not provided'

    context 'with source code that is not a string', ->
      it 'should throw an error', ->
        exercise = -> new ErrorReporter({})
        expect(exercise).to.throw TypeError, 'Source code must be a string'

    context 'with source code that is a string', ->
      it 'should create an instance', ->
        expect(new ErrorReporter('')).to.be.an.instanceof ErrorReporter


  describe 'reporting an error', ->

    describe 'with a message', ->

      context 'not provided', ->
        it 'should throw an error', ->
          errorReporter = new ErrorReporter 'a'
          exercise = -> errorReporter.reportError null, 1, 1
          expect(exercise).to.throw Error, 'Message not provided'

      context 'that is not a string', ->
        it 'should throw an error', ->
          errorReporter = new ErrorReporter 'a'
          exercise = -> errorReporter.reportError {}, 1, 1
          expect(exercise).to.throw TypeError, 'Message must be a string'

      context 'that is empty', ->
        it 'should throw an error', ->
          errorReporter = new ErrorReporter 'a'
          exercise = -> errorReporter.reportError '', 1, 1
          expect(exercise).to.throw Error, 'Message must not be empty'


    describe 'with a line number', ->

      context 'not provided', ->
        it 'should throw an error', ->
          errorReporter = new ErrorReporter 'a'
          exercise = -> errorReporter.reportError 'Test message', null, 1
          expect(exercise).to.throw Error, 'Line number not provided'

      context 'that is not a number', ->
        it 'should throw an error', ->
          errorReporter = new ErrorReporter 'a'
          exercise = -> errorReporter.reportError 'Test message', {}, 1
          expect(exercise).to.throw TypeError, 'Line number must be a number'

      context 'that is invalid', ->
        it 'should throw an error', ->
          errorReporter = new ErrorReporter 'a'
          exercise = -> errorReporter.reportError 'Test message', 0, 1
          expect(exercise).to.throw RangeError, 'Line number is invalid'

      context 'that is out of range', ->
        it 'should throw an error', ->
          errorReporter = new ErrorReporter 'a'
          exercise = -> errorReporter.reportError 'Test message', 2, 1
          expect(exercise).to.throw RangeError, 'Line number is out of range'


    describe 'with a column number', ->

      context 'not provided', ->
        it 'should throw an error', ->
          errorReporter = new ErrorReporter 'a'
          exercise = -> errorReporter.reportError 'Test message', 1, null
          expect(exercise).to.throw Error, 'Column number not provided'

      context 'that is not a number', ->
        it 'should throw an error', ->
          errorReporter = new ErrorReporter 'a'
          exercise = -> errorReporter.reportError 'Test message', 1, {}
          expect(exercise).to.throw TypeError, 'Column number must be a number'

      context 'that is invalid', ->
        it 'should throw an error', ->
          errorReporter = new ErrorReporter 'a'
          exercise = -> errorReporter.reportError 'Test message', 1, 0
          expect(exercise).to.throw RangeError, 'Column number is invalid'

      context 'that is out of range', ->
        it 'should throw an error', ->
          errorReporter = new ErrorReporter 'a'
          exercise = -> errorReporter.reportError 'Test message', 1, 2
          expect(exercise).to.throw RangeError, 'Column number is out of range'


    context 'with valid parameters', ->
      it 'should output an error in the console', ->
        errorReporter = new ErrorReporter 'a'
        stub = sinon.stub console, 'error'

        try errorReporter.reportError 'Test message', 1, 1

        expect(stub.calledOnce).to.be.true
        stub.restore()

      it 'should throw an error', ->
        errorReporter = new ErrorReporter 'a'
        stub = sinon.stub console, 'error'

        message = 'Test message'
        exercise = -> errorReporter.reportError message, 1, 1

        expect(exercise).to.throw Error, message
        stub.restore()


    describe 'with source code', ->

      context 'that does not have the previous or next line', ->
        it 'should provide the current line as context', ->
          sourceCode = 'a'
          errorReporter = new ErrorReporter sourceCode

          stub = sinon.stub console, 'error'

          message = 'Test error message'
          lineNumber = 1
          columnNumber = 1
          try errorReporter.reportError message, lineNumber, columnNumber

          contextualErrorFixture = [
            "Error on line #{lineNumber}, column #{columnNumber}: #{message}"
            ''
            '1 : a'
            '^ : ^'
          ].join '\n'

          contextualError = stub.firstCall.args[0]
          stub.restore()

          expect(contextualError).to.equal contextualErrorFixture

      context 'that does not have the previous line', ->
        it 'should provide the current and next line as context', ->
          sourceCode = 'ab'.split('').join '\n'
          errorReporter = new ErrorReporter sourceCode

          stub = sinon.stub console, 'error'

          message = 'Test error message'
          lineNumber = 1
          columnNumber = 1
          try errorReporter.reportError message, lineNumber, columnNumber

          contextualErrorFixture = [
            "Error on line #{lineNumber}, column #{columnNumber}: #{message}"
            ''
            '1 : a'
            '^ : ^'
            '2 : b'
          ].join '\n'

          contextualError = stub.firstCall.args[0]
          stub.restore()

          expect(contextualError).to.equal contextualErrorFixture

      context 'that does not have the next line', ->
        it 'should provide the previous and current line as context', ->
          sourceCode = 'ab'.split('').join '\n'
          errorReporter = new ErrorReporter sourceCode

          stub = sinon.stub console, 'error'

          message = 'Test error message'
          lineNumber = 2
          columnNumber = 1
          try errorReporter.reportError message, lineNumber, columnNumber

          contextualErrorFixture = [
            "Error on line #{lineNumber}, column #{columnNumber}: #{message}"
            ''
            '1 : a'
            '2 : b'
            '^ : ^'
          ].join '\n'

          contextualError = stub.firstCall.args[0]
          stub.restore()

          expect(contextualError).to.equal contextualErrorFixture

      context 'that has the previous and next line', ->
        it 'should provide the previous, current, and next line as context', ->
          sourceCode = 'abc'.split('').join '\n'
          errorReporter = new ErrorReporter sourceCode

          stub = sinon.stub console, 'error'

          message = 'Test error message'
          lineNumber = 2
          columnNumber = 1
          try errorReporter.reportError message, lineNumber, columnNumber

          contextualErrorFixture = [
            "Error on line #{lineNumber}, column #{columnNumber}: #{message}"
            ''
            '1 : a'
            '2 : b'
            '^ : ^'
            '3 : c'
          ].join '\n'

          contextualError = stub.firstCall.args[0]
          stub.restore()

          expect(contextualError).to.equal contextualErrorFixture


    describe 'when formatting', ->

      context 'with line numbers of different length', ->
        it 'should pad the gutter values correctly', ->
          sourceCode = 'abcdefghij'.split('').join '\n'
          errorReporter = new ErrorReporter sourceCode

          stub = sinon.stub console, 'error'

          message = 'Test error message'
          lineNumber = 9
          columnNumber = 1
          try errorReporter.reportError message, lineNumber, columnNumber

          contextualErrorFixture = [
            "Error on line #{lineNumber}, column #{columnNumber}: #{message}"
            ''
            ' 8 : h'
            ' 9 : i'
            ' ^ : ^'
            '10 : j'
          ].join '\n'

          contextualError = stub.firstCall.args[0]
          stub.restore()

          expect(contextualError).to.equal contextualErrorFixture
