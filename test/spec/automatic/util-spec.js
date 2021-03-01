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
    });
  });
  describe("extractUrlParams",function () {
    it("should filter non-url param and keep url params", function () {
      const {extractUrlParams} = cloudinary.Util;
      options = {signature: 'signature', signature1: 'signature1'};
      expected = {signature: 'signature'};
      actual = extractUrlParams(options);

      expect(actual).toEqual(expected);
    });
  });
  describe("detectIntersection",function () {
    let onIntersect;
    beforeEach(function() {
      onIntersect = jasmine.createSpy("onIntersect");
      jasmine.clock().install();
    });

    it("should call onIntersect", function () {
      const {detectIntersection} = cloudinary.Util;

      setTimeout(function() {
        detectIntersection({}, onIntersect);
      }, 100);

      expect(onIntersect).not.toHaveBeenCalled();

      jasmine.clock().tick(101);

      expect(onIntersect).toHaveBeenCalled();
    });
  });
});
