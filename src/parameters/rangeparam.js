import Param from "./param";

const number_pattern = "([0-9]*)\\.([0-9]+)|([0-9]+)";
const offset_any_pattern = "(" + number_pattern + ")([%pP])?";

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
    this.process = this.process || this.norm_range_value;
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

export default RangeParam;
