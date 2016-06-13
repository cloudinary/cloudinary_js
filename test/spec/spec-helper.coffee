class sharedExamples
  constructor: (name, examples)->
    @allExamples ?= {}
    if _.isFunction(examples)
      console.log("** define shared #{name}" )
      @allExamples[name] = examples
      examples
    else
      if @allExamples[name]?
        console.log("** return shared #{name}" )
        return @allExamples[name]
      else
        return ->
          console.log("Shared example #{name} was not found!")

sharedContext = sharedExamples

itBehavesLike = (name, args...)->
  console.log("it behaves like #{name}")
  describe.call this, "behaves like #{name} #{Math.random()}", ->
    console.log( 'context "behaves like #{name}"')
    sharedExamples(name).apply(this, args)
includeContext = (name, args...)->
  console.log("includeContext #{name}")
  sharedExamples(name).apply(this, args)
