/**
 * Returns a shallow copy of obj without the keys listed in the keys argument.
 * @param {object} obj - the source object
 * @param {string[]} keys - a list of keys to exclude from the new copy
 * @returns {object} the new object
 */
export function omit(obj, keys) {
  obj = obj || {};
  return Object.keys(obj).reduce((result, key) => {
    if (keys.indexOf(key) === -1) {
      result[key] = obj[key];
    }
    return result;
  }, {});
}


/**
 * Creates a new array without the given item.
 * @function Util.without
 * @param {Array} array - original array
 * @param {*} item - the item to exclude from the new array
 * @return {Array} a new array made of the original array's items except for `item`
 */
export function without(array, item) {
  return array.filter(v => v !== item);
}


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
export function isNumberLike(value) {
  // eslint-disable-next-line no-restricted-globals
  const localIsNan = Number.isNaN ? Number.isNaN : isNaN;
  return (value != null) && !localIsNan(parseFloat(value));
}


/**
 * Escape all characters matching unsafe in the given string
 * @function Util.smartEscape
 * @param {string} string - source string to escape
 * @param {RegExp} unsafe - characters that must be escaped
 * @return {string} escaped string
 */
export function smartEscape(string, unsafe = /([^a-zA-Z0-9_.\-\/:]+)/g) {
  return string.replace(unsafe, function (match) {
    return match.split("").map(function (c) {
      return "%" + c.charCodeAt(0).toString(16).toUpperCase();
    }).join("");
  });
}


/**
 * Assign values from sources if they are not defined in the destination.
 * Once a value is set it does not change
 * @function Util.defaults
 * @param {Object} destination - the object to assign defaults to
 * @param {...Object} sources - the source object(s) to assign defaults from
 * @return {Object} destination after it was modified
 */
export function defaults(destination, ...sources) {
  return sources.reduce(function (dest, source) {
    let key, value;
    for (key in source) {
      value = source[key];
      if (dest[key] === void 0) {
        dest[key] = value;
      }
    }
    return dest;
  }, destination);
}

/** ********* lodash functions */
const objectProto = Object.prototype;

/**
 * Used to resolve the [`toStringTag`](http://ecma-international.org/ecma-262/6.0/#sec-object.prototype.tostring)
 * of values.
 */
const objToString = objectProto.toString;


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
export function isObject(value) {
  var type;
  // Avoid a V8 JIT bug in Chrome 19-20.
  // See https://code.google.com/p/v8/issues/detail?id=2291 for more details.
  type = typeof value;
  return !!value && (type === 'object' || type === 'function');
}

const funcTag = '[object Function]';


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
export function isFunction(value) {
  // The use of `Object#toString` avoids issues with the `typeof` operator
  // in older versions of Chrome and Safari which return 'function' for regexes
  // and Safari 8 which returns 'object' for typed array constructors.
  return isObject(value) && objToString.call(value) === funcTag;
}

/** ********* lodash functions */
/** Used to match words to create compound words. */
const reWords = (function () {
  var lower, upper;
  upper = '[A-Z]';
  lower = '[a-z]+';
  return RegExp(upper + '+(?=' + upper + lower + ')|' + upper + '?' + lower + '|' + upper + '+|[0-9]+', 'g');
})();


/**
 * Convert string to camelCase
 * @function Util.camelCase
 * @param {string} source - the string to convert
 * @return {string} in camelCase format
 */
export function camelCase(source) {
  var words = source.match(reWords);
  words = words.map(word => word.charAt(0).toLocaleUpperCase() + word.slice(1).toLocaleLowerCase());
  words[0] = words[0].toLocaleLowerCase();

  return words.join('');
}


/**
 * Convert string to snake_case
 * @function Util.snakeCase
 * @param {string} source - the string to convert
 * @return {string} in snake_case format
 */
export function snakeCase(source) {
  var words = source.match(reWords);
  words = words.map(word => word.toLocaleLowerCase());
  return words.join('_');
}


/**
 * Creates a new object from source, with the keys transformed using the converter.
 * @param {object} source
 * @param {function|null} converter
 * @returns {object}
 */
export function convertKeys(source, converter) {
  var result, value;
  result = {};
  for (let key in source) {
    value = source[key];
    if (converter) {
      key = converter(key);
    }
    if (!isEmpty(key)) {
      result[key] = value;
    }
  }
  return result;
}


/**
 * Create a copy of the source object with all keys in camelCase
 * @function Util.withCamelCaseKeys
 * @param {Object} value - the object to copy
 * @return {Object} a new object
 */
export function withCamelCaseKeys(source) {
  return convertKeys(source, camelCase);
}


/**
 * Create a copy of the source object with all keys in snake_case
 * @function Util.withSnakeCaseKeys
 * @param {Object} value - the object to copy
 * @return {Object} a new object
 */
export function withSnakeCaseKeys(source) {
  return convertKeys(source, snakeCase);
}

// Browser
// Node.js
let base64Encode;
if (typeof btoa !== 'undefined' && isFunction(btoa)) {
  base64Encode = btoa;
} else if (typeof Buffer !== 'undefined' && isFunction(Buffer)) {
  base64Encode = function (input) {
    if (!(input instanceof Buffer)) {
      input = new Buffer.from(String(input), 'binary');
    }
    return input.toString('base64');
  };
} else {
  base64Encode = function (input) {
    throw new Error("No base64 encoding function found");
  };
}


/**
 * Returns the Base64-decoded version of url.<br>
 * This method delegates to `btoa` if present. Otherwise it tries `Buffer`.
 * @function Util.base64EncodeURL
 * @param {string} url - the url to encode. the value is URIdecoded and then re-encoded before converting to base64 representation
 * @return {string} the base64 representation of the URL
 */
export function base64EncodeURL(url) {
  try {
    url = decodeURI(url);
  } finally {
    url = encodeURI(url);
  }
  return base64Encode(url);
}

/**
 * A list of keys used by the url() function.
 * @private
 */
const URL_KEYS = [
  'api_secret',
  'auth_token',
  'cdn_subdomain',
  'cloud_name',
  'cname',
  'format',
  'private_cdn',
  'resource_type',
  'secure',
  'secure_cdn_subdomain',
  'secure_distribution',
  'shorten',
  'sign_url',
  'ssl_detected',
  'type',
  'url_suffix',
  'use_root_path',
  'version'
];

/**
 * Create a new object with only URL parameters
 * @param {object} options The source object
 * @return {Object} An object containing only URL parameters
 */
export function extractUrlParams(options) {
  return URL_KEYS.reduce((obj, key) => {
    if (options[key] != null) {
      obj[key] = options[key];
    }
    return obj;
  }, {});
}


/**
 * Handle the format parameter for fetch urls
 * @private
 * @param options url and transformation options. This argument may be changed by the function!
 */
export function patchFetchFormat(options) {
  if (options == null) {
    options = {};
  }
  if (options.type === "fetch") {
    if (options.fetch_format == null) {
      options.fetch_format = optionConsume(options, "format");
    }
  }
}

/**
 * Deletes `option_name` from `options` and return the value if present.
 * If `options` doesn't contain `option_name` the default value is returned.
 * @param {Object} options a collection
 * @param {String} option_name the name (key) of the desired value
 * @param {*} [default_value] the value to return is option_name is missing
 */
export function optionConsume(options, option_name, default_value) {
  let result = options[option_name];
  delete options[option_name];
  if (result != null) {
    return result;
  } else {
    return default_value;
  }
}

/**
 * Returns true if value is empty:
 * <ul>
 *   <li>value is null or undefined</li>
 *   <li>value is an array or string of length 0</li>
 *   <li>value is an object with no keys</li>
 * </ul>
 * @function Util.isEmpty
 * @param value
 * @returns {boolean} true if value is empty
 */
export function isEmpty(value) {
  if (value == null) {
    return true;
  }
  if (typeof value.length === "number") {
    return value.length === 0;
  }
  if (typeof value.size === "number") {
    return value.size === 0;
  }
  if (typeof value === "object") {
    for (let key in value) {
      if (value.hasOwnProperty(key)) {
        return false;
      }
    }
    return true;
  }
  return true;
}
