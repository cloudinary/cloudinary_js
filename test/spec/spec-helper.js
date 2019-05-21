var allExamples = {};

function sharedExamples(name, examples) {
  if (this.allExamples == null) {
    this.allExamples = {};
  }
  if (cloudinary.Util.isFunction(examples)) {
    this.allExamples[name] = examples;
    return examples;
  } else {
    if (this.allExamples[name] != null) {
      return this.allExamples[name];
    } else {
      return function () {
        return console.log(`Shared example ${name} was not found!`);
      };
    }
  }
}


const sharedContext = sharedExamples;

function itBehavesLike(name, ...args) {
  return describe.call(this, `behaves like ${name}`, function () {
    return sharedExamples(name).apply(this, args);
  });
}

function includeContext(name, ...args) {
  return sharedExamples(name).apply(this, args);
}
