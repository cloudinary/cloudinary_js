export default function stringPad(value, targetLength,padString) {
  targetLength = targetLength>>0; //truncate if number or convert non-number to 0;
  padString = String((typeof padString !== 'undefined' ? padString : ' '));
  if (value.length > targetLength) {
    return String(value);
  }
  else {
    targetLength = targetLength-value.length;
    if (targetLength > padString.length) {
      padString += padString.repeat(targetLength/padString.length); //append to original to ensure we are longer than needed
    }
    return padString.slice(0,targetLength) + String(value);
  }
}
