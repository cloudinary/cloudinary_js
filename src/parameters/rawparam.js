import Param from "./param";
import { identity } from "../util";

class RawParam extends Param {
  constructor(name, shortName, process = identity) {
    super(name, shortName, process);
  }

  serialize() {
    return this.value();
  }
}

export default RawParam;
