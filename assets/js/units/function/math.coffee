# take some for free from Math
mathFuncNames = Object.getOwnPropertyNames(Math).filter (prop) ->
  typeof Math[prop] == 'function'

funcs = _.map mathFuncNames, (name) ->
  func = Math[name]
  func.names = [name]
  func

# operators
funcs = funcs.concat [
  _.extend ((x, y) -> x + y),
    names: ['+']
  _.extend ((x, y) -> x - y),   names: ['-']
  _.extend ((x, y) -> x / y),   names: ['/']
  _.extend ((x, y) -> x * y),   names: ['*']
  _.extend ((x, y) -> x % y),   names: ['%']
  _.extend ((x, y) -> x & y),
    names: ['&']
    tags: ['bitwise']
  _.extend ((x, y) -> x | y),   names: ['|'] # bitwise
  _.extend ((x, y) -> x ^ y),   names: ['^'] # bitwise
  _.extend ((x) -> ~ x),        names: ['~'] # bitwise
  _.extend ((x, y) -> x << y),  names: ['<<'] # left shift
  _.extend ((x, y) -> x >> y),  names: ['>>'] # sign-propagating right shift
  _.extend ((x, y) -> x >>> y), names: ['>>>'] # 0-fill right shift
  _.extend ((x, y) -> x == y),  names: ['==']
  _.extend ((x, y) -> x != y),  names: ['!=']
  _.extend ((x, y) -> x > y),   names: ['>']
  _.extend ((x, y) -> x < y),   names: ['<']
  _.extend ((x, y) -> x >= y),  names: ['>=']
  _.extend ((x, y) -> x <= y),  names: ['<=']
  _.extend ((x, y) -> x && y),  names: ['&&', 'and'] # logical
  _.extend ((x, y) -> x || y),  names: ['||', 'or'] # logical
  _.extend ((x) -> not x),      names: ['!', 'not'] # logical
  _.extend ((x) -> return Math.log(x) / Math.log(2)), names: ['log2']
  _.extend ((x) -> return Math.log(x) / Math.log(10)), names: ['log10']
  _.extend ((x) -> return 20 * (Math.log(x) / Math.log(10))), names: ['atodb']
  _.extend ((x) -> return Math.pow(10, x / 20)), names: ['dbtoa']
]

# midi to frequency
funcs.push _.extend (x) ->
  (Math.pow 2, (x - 57) / 12) * 440
, names: ['mtof']

# frequency to midi
funcs.push _.extend (x) ->
  (Math.round(Math.log x / 440 / Math.log 2)) * 12 + 57
, names: ['ftom']

# from http://www.musicdsp.org/showone.php?id=238
funcs.push _.extend (x) ->
  return -1 if x < -3
  return  1 if x > 3
  squared = x * x
  return (27 + squared) / (27 + 9 * squared)
, names: ['rtanh']


for func in funcs
  do (func) ->
    class MathFunc extends patchosaur.Unit
      @names = func.names
      @tags  = (func.tags or []).concat ['math']
      setup: (@objectModel) ->
        @func = func
        @args = @objectModel.get 'unitArgs'
        numInlets = @func.length
        @currArgs = [0, @args...]
        @objectModel.set numInlets: numInlets
        @objectModel.set numOutlets: 1
        @inlets = @makeInlets numInlets, @call

      call: (i, arg) =>
        @currArgs[i] = arg
        if i == 0
          @out 0, @func @currArgs...

    patchosaur.units.add MathFunc


