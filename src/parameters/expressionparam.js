import Param from "./param";
import Expression from "../expression";

class ExpressionParam extends Param {
  serialize() {
    return Expression.normalize(super.serialize());
  }
}

export default ExpressionParam;
