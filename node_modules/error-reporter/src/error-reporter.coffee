# Provide source code context when reporting errors.
#
# @example Reporting errors
#   letters = [
#     'abcde'
#     'fghij'
#     'klmNo'
#     'pqrst'
#     'uvwxy'
#     'Z'
#   ].join '\n'
#
#   errorReporter = new ErrorReporter letters
#   errorReporter.reportError 'Only lowercase letters are allowed', 3, 4
#   errorReporter.reportError 'Only lowercase letters are allowed', 6, 1
#
class ErrorReporter

  # @property [String] The source code to report errors on.
  # @private
  #
  _sourceCode: null


  # Construct a new error reporter.
  #
  # @param sourceCode [String] The source code to report errors on.
  #
  constructor: (sourceCode) ->
    throw new Error 'Source code not provided' unless sourceCode?

    unless toString.call(sourceCode) is '[object String]'
      throw new TypeError 'Source code must be a string'

    @_sourceCode = sourceCode




  # Report an error.
  #
  # @param message [String] A description of the error.
  # @param lineNumber [Number] The line number where the error occurred.
  # @param columnNumber [Number] The column number where the error occurred.
  #
  reportError: (message, lineNumber, columnNumber) =>
    throw new Error 'Message not provided' unless message?

    unless toString.call(message) is '[object String]'
      throw new TypeError 'Message must be a string'

    throw new Error 'Message must not be empty' if message.length is 0


    throw new Error 'Line number not provided' unless lineNumber?

    unless toString.call(lineNumber) is '[object Number]'
      throw new TypeError 'Line number must be a number'

    throw new RangeError 'Line number is invalid' if lineNumber <= 0


    throw new Error 'Column number not provided' unless columnNumber?

    unless toString.call(columnNumber) is '[object Number]'
      throw new TypeError 'Column number must be a number'

    throw new RangeError 'Column number is invalid' if columnNumber <= 0


    lines = @_sourceCode.split '\n'
    throw new RangeError 'Line number is out of range' if lineNumber > lines.length

    currentLine = lines[lineNumber - 1]

    if columnNumber > currentLine.length
      throw new RangeError 'Column number is out of range'


    error = []
    error.push "Error on line #{lineNumber}, column #{columnNumber}: #{message}"
    error.push ''

    previousLineNumber = lineNumber - 1
    nextLineNumber = lineNumber + 1

    # Ensure that indices only exist if they are in range.
    previousLineIndex = previousLineNumber - 1 if previousLineNumber - 1 >= 0
    nextLineIndex = nextLineNumber - 1 if nextLineNumber - 1 <= lines.length - 1

    # Determine the length of the last line number in order to pad the gutter
    # values and maintain a consistent width.
    lastLineNumber = if nextLineIndex? then nextLineNumber else lineNumber
    longestLineNumberLength = "#{lastLineNumber}".length

    # Draw an arrow pointing to the column.
    # The joined array provides (columnNumber - 1) hyphens.
    errorLocator = "#{Array(columnNumber).join('-')}^"

    context = []
    context.push [previousLineNumber, lines[previousLineIndex], previousLineIndex?]
    context.push [lineNumber, currentLine, true]
    context.push ['^', errorLocator, true]
    context.push [nextLineNumber, lines[nextLineIndex], nextLineIndex?]

    for item in context
      gutterValue = item[0]
      lineValue = item[1]
      condition = item[2]

      padding = Array(longestLineNumberLength - "#{gutterValue}".length + 1).join ' '
      gutterValue = "#{padding}#{gutterValue}"

      error.push "#{gutterValue} : #{lineValue}" if condition

    console.error error.join '\n'


    throw new Error message


module.exports = ErrorReporter
