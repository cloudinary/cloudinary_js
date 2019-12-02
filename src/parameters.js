import Expression from './expression';
import Transformation from "./transformation";

import {
  allStrings,
  identity,
  isArray,
  isEmpty,
  isFunction,
  isPlainObject,
  isString,
  withCamelCaseKeys
} from './util';

import Layer from './layer/layer';

import TextLayer from './layer/textlayer';

import SubtitlesLayer from './layer/subtitleslayer';

import FetchLayer from './layer/fetchlayer';

/**
 * Transformation parameters
 * Depends on 'util', 'transformation'
 */
class Param {
  /**
   * Represents a single parameter.
   * @class Param
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} shortName - The name of the serialized form of the parameter.
   *                         If a value is not provided, the parameter will not be serialized.
   * @param {function} [process=Util.identity ] - Manipulate origValue when value is called
   * @ignore
   */
  constructor(name, shortName, process = identity) {
    /**
     * The name of the parameter in snake_case
     * @member {string} Param#name
     */
    this.name = name;
    /**
     * The name of the serialized form of the parameter
     * @member {string} Param#shortName
     */
    this.shortName = shortName;
    /**
     * Manipulate origValue when value is called
     * @member {function} Param#process
     */
    this.process = process;
  }

  /**
   * Set a (unprocessed) value for this parameter
   * @function Param#set
   * @param {*} origValue - the value of the parameter
   * @return {Param} self for chaining
   */
  set(origValue) {
    this.origValue = origValue;
    return this;
  }

  /**
   * Generate the serialized form of the parameter
   * @function Param#serialize
   * @return {string} the serialized form of the parameter
   */
  serialize() {
    var val, valid;
    val = this.value();
    valid = isArray(val) || isPlainObject(val) || isString(val) ? !isEmpty(val) : val != null;
    if ((this.shortName != null) && valid) {
      return `${this.shortName}_${val}`;
    } else {
      return '';
    }
  }

  /**
   * Return the processed value of the parameter
   * @function Param#value
   */
  value() {
    return this.process(this.origValue);
  }

  static norm_color(value) {
    return value != null ? value.replace(/^#/, 'rgb:') : void 0;
  }

  build_array(arg) {
    if(arg == null) {
      return [];
    } else if (isArray(arg)) {
      return arg;
    } else {
      return [arg];
    }
  }

  /**
  * Covert value to video codec string.
  *
  * If the parameter is an object,
  * @param {(string|Object)} param - the video codec as either a String or a Hash
  * @return {string} the video codec string in the format codec:profile:level
  * @example
  * vc_[ :profile : [level]]
  * or
    { codec: 'h264', profile: 'basic', level: '3.1' }
  * @ignore
   */
  static process_video_params(param) {
    var video;
    switch (param.constructor) {
      case Object:
        video = "";
        if ('codec' in param) {
          video = param['codec'];
          if ('profile' in param) {
            video += ":" + param['profile'];
            if ('level' in param) {
              video += ":" + param['level'];
            }
          }
        }
        return video;
      case String:
        return param;
      default:
        return null;
    }
  }

}

class ArrayParam extends Param {
  /**
   * A parameter that represents an array.
   * @param {string} name - The name of the parameter in snake_case.
   * @param {string} shortName - The name of the serialized form of the parameter
   *                         If a value is not provided, the parameter will not be serialized.
   * @param {string} [sep='.'] - The separator to use when joining the array elements together
   * @param {function} [process=Util.identity ] - Manipulate origValue when value is called
   * @class ArrayParam
   * @extends Param
   * @ignore
   */
  constructor(name, shortName, sep = '.', process) {
    super(name, shortName, process);
    this.sep = sep;
  }

  serialize() {
    if (this.shortName != null) {
      let arrayValue = this.value();
      if (isEmpty(arrayValue)) {
        return '';
      } else if (isString(arrayValue)) {
        return `${this.shortName}_${arrayValue}`;
      } else {
        let flat = arrayValue.map(t=>isFunction(t.serialize) ? t.serialize() : t).join(this.sep);
        return `${this.shortName}_${flat}`;
      }
    } else {
      return '';
    }
  }

  value() {
    if (isArray(this.origValue)) {
      return this.origValue.map(v=>this.process(v));
    } else {
      return this.process(this.origValue);
    }
  }

  set(origValue) {
    if ((origValue == null) || isArray(origValue)) {
      return super.set(origValue);
    } else {
      return super.set([origValue]);
    }
  }

}

var TransformationParam = class TransformationParam extends Param {
  /**
   * A parameter that represents a transformation
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} [shortName='t'] - The name of the serialized form of the parameter
   * @param {string} [sep='.'] - The separator to use when joining the array elements together
   * @param {function} [process=Util.identity ] - Manipulate origValue when value is called
   * @class TransformationParam
   * @extends Param
   * @ignore
   */
  constructor(name, shortName = "t", sep = '.', process) {
    super(name, shortName, process);
    this.sep = sep;
  }

  /**
   * Generate string representations of the transformation.
   * @returns {*} Returns either the transformation as a string, or an array of string representations.
   */
  serialize() {
    let result = '';
    const val = this.value();

    // val is an array of strings so join them
    if (!isEmpty(val) && allStrings(val)) {
      const joined = val.join(this.sep);  // creates t1.t2.t3 in case multiple named transformations were configured
      if (!isEmpty(joined)) {
        // in case options.transformation was not set with an empty string (val != ['']);
        result = `${this.shortName}_${joined}`;
      }
    } else { // Convert val to an array of strings
      result = val.map(t => {
        switch (true) {
          case isString(t) && !isEmpty(t):
            return `${this.shortName}_${t}`;
          case isFunction(t.serialize):
            return t.serialize();
          case isPlainObject(t) && !isEmpty(t):
            return new Transformation(t).serialize();
          default: return undefined;
        }
      }).filter(t=>t);
    }
    result = isArray(result) ? result.map(t=>t.replace(' ','%20')) : result.replace(' ','%20');
    return result;
  }

  set(origValue1) {
    this.origValue = origValue1;
    if (isArray(this.origValue)) {
      return super.set(this.origValue);
    } else {
      return super.set([this.origValue]);
    }
  }

};

class RangeParam extends Param {
  /**
   * A parameter that represents a range.
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} shortName - The name of the serialized form of the parameter
   *                         If a value is not provided, the parameter will not be serialized.
   * @param {function} [process=norm_range_value ] - Manipulate origValue when value is called
   * @class RangeParam
   * @extends Param
   * @ignore
   */
  constructor(name, shortName, process) {
    super(name, shortName, process);
    this.process || (this.process = this.norm_range_value);
  }

  static norm_range_value(value) {
    var modifier, offset;
    offset = String(value).match(new RegExp('^' + offset_any_pattern + '$'));
    if (offset) {
      modifier = offset[5] != null ? 'p' : '';
      value = (offset[1] || offset[4]) + modifier;
    }
    return value;
  }

}

var RawParam = class RawParam extends Param {
  constructor(name, shortName, process = identity) {
    super(name, shortName, process);
  }

  serialize() {
    return this.value();
  }

};

const LAYER_KEYWORD_PARAMS = [
  ["font_weight", "normal"],
  ["font_style", "normal"],
  ["text_decoration", "none"],
  ["text_align", null],
  ["stroke", "none"],
  ["letter_spacing", null],
  ["line_spacing", null],
  ["font_antialias", null],
  ["font_hinting", null]
];

class LayerParam extends Param {
  // Parse layer options
  // @return [string] layer transformation string
  // @private
  value() {
    if (this.origValue == null) {
      return '';
    }
    let result;
    if (this.origValue instanceof Layer) {
      result = this.origValue;
    } else if (isPlainObject(this.origValue)) {
      let layerOptions = withCamelCaseKeys(this.origValue);
      if (layerOptions.resourceType === "text" || (layerOptions.text != null)) {
        result = new TextLayer(layerOptions);
      } else if (layerOptions.resourceType === "subtitles") {
        result = new SubtitlesLayer(layerOptions);
      } else if (layerOptions.resourceType === "fetch" || (layerOptions.url != null)) {
        result = new FetchLayer(layerOptions);
      } else {
        result = new Layer(layerOptions);
      }
    } else if (isString(this.origValue)) {
      if (/^fetch:.+/.test(this.origValue)) {
        result = new FetchLayer(this.origValue.substr(6));
      } else {
        result = this.origValue;
      }
    } else {
      result = '';
    }
    return result.toString();
  }

  textStyle(layer) {
    return (new TextLayer(layer)).textStyleIdentifier();
  }

}

class ExpressionParam extends Param {
  serialize() {
    return Expression.normalize(super.serialize());
  }

}

export {
  Param,
  ArrayParam,
  TransformationParam,
  RangeParam,
  RawParam,
  LayerParam,
  ExpressionParam
};
