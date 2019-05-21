import Param from "./param";
import { isPlainObject, isString, withCamelCaseKeys } from "../util";
import TextLayer from "../layer/textlayer";
import SubtitlesLayer from "../layer/subtitleslayer";
import FetchLayer from "../layer/fetchlayer";
import Layer from "../layer/layer";

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
    let result;
    let layerOptions = this.origValue;
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
    } else if (isString(layerOptions) && /^fetch:.+/.test(layerOptions)) {
      result = new FetchLayer(layerOptions.substr(6)).toString();
    } else {
      result = layerOptions;
    }
    return result;
  }

  textStyle(layer) {
    return (new TextLayer(layer)).textStyleIdentifier();
  }
}

export default LayerParam;
