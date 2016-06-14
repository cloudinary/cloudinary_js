class sharedExamples
  constructor: (name, examples)->
    @allExamples ?= {}
    if cloudinary.Util.isFunction(examples)
      @allExamples[name] = examples
      examples
    else
      if @allExamples[name]?
        return @allExamples[name]
      else
        return ->
          console.log("Shared example #{name} was not found!")

sharedContext = sharedExamples

itBehavesLike = (name, args...)->
  describe.call this, "behaves like #{name}", ->
    sharedExamples(name).apply(this, args)
includeContext = (name, args...)->
  sharedExamples(name).apply(this, args)
