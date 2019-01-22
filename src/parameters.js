var ArrayParam, ExpressionParam, LayerParam, Param, RangeParam, RawParam, TransformationParam;

import Expression from './expression';

import {
  allStrings,
  compact,
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
Param = class Param {
  /**
   * Represents a single parameter
   * @class Param
   * @param {string} name - The name of the parameter in snake_case
   * @param {string} shortName - The name of the serialized form of the parameter.
   *                         If a value is not provided, the parameter will not be serialized.
   * @param {function} [process=Util.identity ] - Manipulate origValue when value is called
   * @ignore
   */
  constructor(name, shortName, process = Util.identity) {
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

  build_array(arg = []) {
    if (isArray(arg)) {
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

};

ArrayParam = class ArrayParam extends Param {
  /**
   * A parameter that represents an array
   * @param {string} name - The name of the parameter in snake_case
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
    var arrayValue, flat, t;
    if (this.shortName != null) {
      arrayValue = this.value();
      if (isEmpty(arrayValue)) {
        return '';
      } else if (isString(arrayValue)) {
        return `${this.shortName}_${arrayValue}`;
      } else {
        flat = (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = arrayValue.length; i < len; i++) {
            t = arrayValue[i];
            if (isFunction(t.serialize)) {
              results.push(t.serialize()); // Param or Transformation
            } else {
              results.push(t);
            }
          }
          return results;
        })();
        return `${this.shortName}_${flat.join(this.sep)}`;
      }
    } else {
      return '';
    }
  }

  value() {
    var i, len, ref, results, v;
    if (isArray(this.origValue)) {
      ref = this.origValue;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        v = ref[i];
        results.push(this.process(v));
      }
      return results;
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

};

TransformationParam = class TransformationParam extends Param {
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

  serialize() {
    var joined, result, t;
    if (isEmpty(this.value())) {
      return '';
    } else if (allStrings(this.value())) {
      joined = this.value().join(this.sep);
      if (!isEmpty(joined)) {
        return `${this.shortName}_${joined}`;
      } else {
        return '';
      }
    } else {
      result = (function() {
        var i, len, ref, results;
        ref = this.value();
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          t = ref[i];
          if (t != null) {
            if (isString(t) && !isEmpty(t)) {
              results.push(`${this.shortName}_${t}`);
            } else if (isFunction(t.serialize)) {
              results.push(t.serialize());
            } else if (isPlainObject(t) && !isEmpty(t)) {
              results.push(new Transformation(t).serialize());
            } else {
              results.push(void 0);
            }
          }
        }
        return results;
      }).call(this);
      return compact(result);
    }
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

RangeParam = class RangeParam extends Param {
  /**
   * A parameter that represents a range
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

};

RawParam = class RawParam extends Param {
  constructor(name, shortName, process = Util.identity) {
    super(name, shortName, process);
  }

  serialize() {
    return this.value();
  }

};

LayerParam = (function() {
  var LAYER_KEYWORD_PARAMS;

  class LayerParam extends Param {
    // Parse layer options
    // @return [string] layer transformation string
    // @private
    value() {
      var layerOptions, result;
      layerOptions = this.origValue;
      if (isPlainObject(layerOptions)) {
        layerOptions = withCamelCaseKeys(layerOptions);
        if (layerOptions.resourceType === "text" || (layerOptions.text != null)) {
          result = new TextLayer(layerOptions).toString();
        } else if (layerOptions.resourceType === "subtitles") {
          result = new SubtitlesLayer(layerOptions).toString();
        } else if (layerOptions.resourceType === "fetch" || (layerOptions.url != null)) {
          result = new FetchLayer(layerOptions).toString();
        } else {
          result = new Layer(layerOptions).toString();
        }
      } else if (/^fetch:.+/.test(layerOptions)) {
        result = new FetchLayer(layerOptions.substr(6)).toString();
      } else {
        result = layerOptions;
      }
      return result;
    }

    textStyle(layer) {
      return (new TextLayer(layer)).textStyleIdentifier();
    }

  };

  LAYER_KEYWORD_PARAMS = [["font_weight", "normal"], ["font_style", "normal"], ["text_decoration", "none"], ["text_align", null], ["stroke", "none"], ["letter_spacing", null], ["line_spacing", null]];

  return LayerParam;

}).call(this);

ExpressionParam = class ExpressionParam extends Param {
  serialize() {
    return Expression.normalize(super.serialize());
  }

};

export {
  Param,
  ArrayParam,
  TransformationParam,
  RangeParam,
  RawParam,
  LayerParam,
  ExpressionParam
};
