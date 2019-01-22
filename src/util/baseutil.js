/*
 * Includes common utility methods and shims
 */
/**
 * Return true if all items in list are strings
 * @function Util.allString
 * @param {Array} list - an array of items
 */
export var allStrings = function(list) {
  var item, j, len;
  for (j = 0, len = list.length; j < len; j++) {
    item = list[j];
    if (!Util.isString(item)) {
      return false;
    }
  }
  return true;
};

/**
* Creates a new array without the given item.
* @function Util.without
* @param {Array} array - original array
* @param {*} item - the item to exclude from the new array
* @return {Array} a new array made of the original array's items except for `item`
 */
export var without = function(array, item) {
  var i, length, newArray;
  newArray = [];
  i = -1;
  length = array.length;
  while (++i < length) {
    if (array[i] !== item) {
      newArray.push(array[i]);
    }
  }
  return newArray;
};

/**
* Return true is value is a number or a string representation of a number.
* @function Util.isNumberLike
* @param {*} value
* @returns {boolean} true if value is a number
* @example
*    Util.isNumber(0) // true
*    Util.isNumber("1.3") // true
*    Util.isNumber("") // false
*    Util.isNumber(undefined) // false
 */
export var isNumberLike = function(value) {
  return (value != null) && !isNaN(parseFloat(value));
};

/**
 * Escape all characters matching unsafe in the given string
 * @function Util.smartEscape
 * @param {string} string - source string to escape
 * @param {RegExp} unsafe - characters that must be escaped
 * @return {string} escaped string
 */
export var smartEscape = function(string, unsafe = /([^a-zA-Z0-9_.\-\/:]+)/g) {
  return string.replace(unsafe, function(match) {
    return match.split("").map(function(c) {
      return "%" + c.charCodeAt(0).toString(16).toUpperCase();
    }).join("");
  });
};

/**
 * Assign values from sources if they are not defined in the destination.
 * Once a value is set it does not change
 * @function Util.defaults
 * @param {Object} destination - the object to assign defaults to
 * @param {...Object} source - the source object(s) to assign defaults from
 * @return {Object} destination after it was modified
 */
export var defaults = function(destination, ...sources) {
  return sources.reduce(function(dest, source) {
    var key, value;
    for (key in source) {
      value = source[key];
      if (dest[key] === void 0) {
        dest[key] = value;
      }
    }
    return dest;
  }, destination);
};

/*********** lodash functions */
export var objectProto = Object.prototype;

/**
 * Used to resolve the [`toStringTag`](http://ecma-international.org/ecma-262/6.0/#sec-object.prototype.tostring)
 * of values.
 */
export var objToString = objectProto.toString;

/**
 * Checks if `value` is the [language type](https://es5.github.io/#x8) of `Object`.
 * (e.g. arrays, functions, objects, regexes, `new Number(0)`, and `new String('')`)
 *
 * @param {*} value The value to check.
 * @returns {boolean} Returns `true` if `value` is an object, else `false`.
 * @example
 *
#isObject({});
 * // => true
 *
#isObject([1, 2, 3]);
 * // => true
 *
#isObject(1);
 * // => false
 */
export var isObject = function(value) {
  var type;
  // Avoid a V8 JIT bug in Chrome 19-20.
  // See https://code.google.com/p/v8/issues/detail?id=2291 for more details.
  type = typeof value;
  return !!value && (type === 'object' || type === 'function');
};

export var funcTag = '[object Function]';

/**
* Checks if `value` is classified as a `Function` object.
* @function Util.isFunction
* @param {*} value The value to check.
* @returns {boolean} Returns `true` if `value` is correctly classified, else `false`.
* @example
*
* function Foo(){};  
* isFunction(Foo);
* // => true
*
* isFunction(/abc/);
* // => false
 */
export var isFunction = function(value) {
  // The use of `Object#toString` avoids issues with the `typeof` operator
  // in older versions of Chrome and Safari which return 'function' for regexes
  // and Safari 8 which returns 'object' for typed array constructors.
  return isObject(value) && objToString.call(value) === funcTag;
};

/*********** lodash functions */
/** Used to match words to create compound words. */
export var reWords = (function() {
  var lower, upper;
  upper = '[A-Z]';
  lower = '[a-z]+';
  return RegExp(upper + '+(?=' + upper + lower + ')|' + upper + '?' + lower + '|' + upper + '+|[0-9]+', 'g');
})();

/**
* Convert string to camelCase
* @function Util.camelCase
* @param {string} string - the string to convert
* @return {string} in camelCase format
 */
export var camelCase = function(source) {
  var i, word, words;
  words = source.match(reWords);
  words = (function() {
    var j, len, results;
    results = [];
    for (i = j = 0, len = words.length; j < len; i = ++j) {
      word = words[i];
      word = word.toLocaleLowerCase();
      if (i) {
        results.push(word.charAt(0).toLocaleUpperCase() + word.slice(1));
      } else {
        results.push(word);
      }
    }
    return results;
  })();
  return words.join('');
};

/**
 * Convert string to snake_case
 * @function Util.snakeCase
 * @param {string} string - the string to convert
 * @return {string} in snake_case format
 */
export var snakeCase = function(source) {
  var i, word, words;
  words = source.match(reWords);
  words = (function() {
    var j, len, results;
    results = [];
    for (i = j = 0, len = words.length; j < len; i = ++j) {
      word = words[i];
      results.push(word.toLocaleLowerCase());
    }
    return results;
  })();
  return words.join('_');
};

export var convertKeys = function(source, converter = Util.identity) {
  var key, result, value;
  result = {};
  for (key in source) {
    value = source[key];
    key = converter(key);
    if (!Util.isEmpty(key)) {
      result[key] = value;
    }
  }
  return result;
};

/**
 * Create a copy of the source object with all keys in camelCase
 * @function Util.withCamelCaseKeys
 * @param {Object} value - the object to copy
 * @return {Object} a new object
 */
export var withCamelCaseKeys = function(source) {
  return convertKeys(source, Util.camelCase);
};

/**
 * Create a copy of the source object with all keys in snake_case
 * @function Util.withSnakeCaseKeys
 * @param {Object} value - the object to copy
 * @return {Object} a new object
 */
export var withSnakeCaseKeys = function(source) {
  return convertKeys(source, Util.snakeCase);
};

// Browser
// Node.js
export var base64Encode = typeof btoa !== 'undefined' && isFunction(btoa) ? btoa : typeof Buffer !== 'undefined' && isFunction(Buffer) ? function(input) {
  if (!(input instanceof Buffer)) {
    input = new Buffer.from(String(input), 'binary');
  }
  return input.toString('base64');
} : function(input) {
  throw new Error("No base64 encoding function found");
};

/**
* Returns the Base64-decoded version of url.<br>
* This method delegates to `btoa` if present. Otherwise it tries `Buffer`.
* @function Util.base64EncodeURL
* @param {string} url - the url to encode. the value is URIdecoded and then re-encoded before converting to base64 representation
* @return {string} the base64 representation of the URL   
 */
export var base64EncodeURL = function(input) {
  var ignore;
  try {
    input = decodeURI(input);
  } catch (error) {
    ignore = error;
  }
  input = encodeURI(input);
  return base64Encode(input);
};
