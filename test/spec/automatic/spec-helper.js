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

let expectedImageTagFromParams = function (
    publicId,
    commonTransStr = '',
    customTransStr = '',
    srcsetBreakpoints = [],
    attributes = {}) {

  let DEFAULT_UPLOAD_PATH = `${protocol}//res.cloudinary.com/test123/image/upload/`;

  const isEmpty = cloudinary.Util.isEmpty;

  if (isEmpty(attributes.src)) {
    Object.assign(attributes, {
      src: DEFAULT_UPLOAD_PATH + (!isEmpty(commonTransStr) ? commonTransStr + '/' : '') + publicId
    });
  }

  if (isEmpty(customTransStr)) {
    customTransStr = commonTransStr;
  }

  if (!isEmpty(srcsetBreakpoints)) {
    let srcset = [];
    srcsetBreakpoints.forEach((w) => {
      srcset.push(
          DEFAULT_UPLOAD_PATH + (!isEmpty(customTransStr) ? customTransStr + '/' : '') + 'c_scale,w_' + w + '/' +
          publicId + ' ' + w + 'w'
      );
    });
    Object.assign(attributes, {
      srcset: srcset.join(', ')
    });
  }

  attributes = Object.keys(attributes).sort().reduce(
      (obj, key) => {
        obj[key] = attributes[key];
        return obj;
      },
      {}
  );

  let attributesArray = [];
  let attributesStr = '';
  for(let key in attributes){
    attributesArray.push(key + '="' + attributes[key] + '"');
  }
  attributesStr = attributesArray.join(' ');

  return '<img ' + attributesStr + '>';
};

//# sourceMappingURL=spec-helper.js.map
