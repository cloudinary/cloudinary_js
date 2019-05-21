import Param from "./param";
import { allStrings, isArray, isEmpty, isFunction, isPlainObject, isString } from "../util";
// eslint-disable-next-line import/no-cycle
import Transformation from "../transformation";

class TransformationParam extends Param {
  /**
   * A parameter that represents a transformation.
   * @param {string} name - The name of the parameter in snake_case.
   * @param {string} [shortName='t'] - The name of the serialized form of the parameter.
   * @param {string} [sep='.'] - The separator to use when joining the array elements together.
   * @param {function} [process=Util.identity ] - Manipulate origValue when value is called.
   * @class TransformationParam
   * @extends Param
   * @ignore
   */
  constructor(name, shortName = "t", sep = '.', process) {
    super(name, shortName, process);
    this.sep = sep;
  }

  serialize() {
    if (isEmpty(this.value())) {
      return '';
    } else if (allStrings(this.value())) {
      let joined = this.value().join(this.sep);
      if (!isEmpty(joined)) {
        return `${this.shortName}_${joined}`;
      } else {
        return '';
      }
    } else {
      return this.value().map((t) => {
        if (t == null) {
          return t;
        } else if (isString(t) && !isEmpty(t)) {
          return `${this.shortName}_${t}`;
        } else if (isFunction(t.serialize)) {
          return t.serialize();
        } else if (isPlainObject(t) && !isEmpty(t)) {
          return new Transformation(t).serialize();
        } else {
          return undefined;
        }
      }).filter(t => t);
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
}

export default TransformationParam;
