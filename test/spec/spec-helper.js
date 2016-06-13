var includeContext, itBehavesLike, sharedContext, sharedExamples,
  slice = [].slice;

sharedExamples = (function() {
  function sharedExamples(name, examples) {
    if (this.allExamples == null) {
      this.allExamples = {};
    }
    if (_.isFunction(examples)) {
      console.log("** define shared " + name);
      this.allExamples[name] = examples;
      examples;
    } else {
      if (this.allExamples[name] != null) {
        console.log("** return shared " + name);
        return this.allExamples[name];
      } else {
        return function() {
          return console.log("Shared example " + name + " was not found!");
        };
      }
    }
  }

  return sharedExamples;

})();

sharedContext = sharedExamples;

itBehavesLike = function() {
  var args, name;
  name = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
  console.log("it behaves like " + name);
  return describe.call(this, "behaves like " + name + " " + (Math.random()), function() {
    console.log('context "behaves like #{name}"');
    return sharedExamples(name).apply(this, args);
  });
};

includeContext = function() {
  var args, name;
  name = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
  console.log("includeContext " + name);
  return sharedExamples(name).apply(this, args);
};

//# sourceMappingURL=spec-helper.js.map
