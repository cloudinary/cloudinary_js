var SharedExamples, includeContext, itBehavesLike, sharedContext, sharedExamples;

SharedExamples = class SharedExamples {
  constructor(name, examples) {
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
          return console.log(`Shared example ${name} was not found!`);
        };
      }
    }
  }

};

sharedExamples = function(name, examples) {
  return new SharedExamples(name, examples);
};

sharedContext = sharedExamples;

itBehavesLike = function(name, ...args) {
  return describe.call(this, `behaves like ${name}`, function() {
    return sharedExamples(name).apply(this, args);
  });
};

includeContext = function(name, ...args) {
  return sharedExamples(name).apply(this, args);
};

//# sourceMappingURL=spec-helper.js.map
