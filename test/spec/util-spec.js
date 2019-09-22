describe("util", function () {
  describe("isEmpty",function () {
    it("should return false", function () {
      const isEmpty = cloudinary.Util.isEmpty;
      expect(isEmpty("content")).toBe(false, "for empty string");
      expect(isEmpty([1])).toBe(false, "for empty literal array");
      expect(isEmpty({foo: 1})).toBe(false);
      const array = new Array();
      array.push('1');
      expect(isEmpty(array)).toBe(false, "for new Array()");
      if(typeof Map){
        const map = new Map();
        map.set("foo", 1);
        expect(isEmpty(map)).toBe(false, "for new Map()");
      } else {
        console.warn("Map is not preset.")
      }
      if(typeof Set) {
        const set = new Set([1]);
        expect(isEmpty(set)).toBe(false);
      } else {
        console.warn("Set is not preset.")
      }

    });
    it("should return true", function () {
      const isEmpty = cloudinary.Util.isEmpty;
      expect(isEmpty("")).toBe(true, "for empty string");
      expect(isEmpty(true)).toBe(true, "for true");
      expect(isEmpty(4)).toBe(true, "for true");
      expect(isEmpty([])).toBe(true, "for empty literal array");
      expect(isEmpty({})).toBe(true);
      expect(isEmpty(new Array())).toBe(true, "for new Array()");
      if(typeof Map){
        expect(isEmpty(new Map())).toBe(true, "for new Map()");
      } else {
        console.warn("Map is not preset.")
      }
      if(typeof Set) {
        expect(isEmpty(new Set())).toBe(true);
      } else {
        console.warn("Set is not preset.")
      }
    })
  });
  describe("isEqual", function () {
    const isEqual = cloudinary.Util.isEqual;
    it("should return false", function () {
      expect(isEqual({a: 'a'}, {a: 'b'})).toBe(false);
      expect(isEqual(1, 2)).toBe(false);
      expect(isEqual('a', 'b')).toBe(false);
      expect(isEqual(['a'], ['b'])).toBe(false);
    });
    it("should return true", function () {
      expect(isEqual({a: 'a'}, {a: 'a'})).toBe(true);
      expect(isEqual(1, 1)).toBe(true);
      expect(isEqual('a', 'a')).toBe(true);
      expect(isEqual(['a'], ['a'])).toBe(true);
    });
  });
});
