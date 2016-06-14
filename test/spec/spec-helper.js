var includeContext, itBehavesLike, sharedContext, sharedExamples,
  slice = [].slice;

sharedExamples = (function() {
  function sharedExamples(name, examples) {
    if (this.allExamples == null) {
      this.allExamples = {};
    }
    if (cloudinary.Util.isFunction(examples)) {
      this.allExamples[name] = examples;
      examples;
    } else {
      if (this.allExamples[name] != null) {
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
  return describe.call(this, "behaves like " + name, function() {
    return sharedExamples(name).apply(this, args);
  });
};

includeContext = function() {
  var args, name;
  name = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
  return sharedExamples(name).apply(this, args);
};

//# sourceMappingURL=spec-helper.js.map
