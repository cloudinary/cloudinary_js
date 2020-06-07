let describeAicTest = describe;

if (/phantom|HeadlessChrome|HeadlessFirefox/i.test(navigator.userAgent)) {
  console.warn("Skipping responsive tests in PhantomJS or HeadlessChrome");
  describeAicTest = xdescribe;
}

describeAicTest('client side advanced image component' + navigator.userAgent, function () {
  describe("lazy loading", function () {
    var container, fixtureContainer, testDocument, testWindow, triggerScroll, lazyLoad;
    fixtureContainer = void 0;
    testDocument = null;
    container = void 0;
    testWindow = null;
    beforeAll(function (done) {
      var testURL;
      // Open a new window with test HTML. A dynamic title is required in order to open a *new* window each time even if
      // previous window was not closed.
      testURL = "aic-core-test.html";
      if (typeof __karma__ !== "undefined") {
        testURL = `/base/test/docRoot/${testURL}`;
      }
      testWindow = window.open(testURL, `Cloudinary test ${(new Date()).toLocaleString()}`, "width=500, height=500");
      testWindow.addEventListener('karma-ready', () => {
        testDocument = testWindow.document;
        var lazy1 = testDocument.getElementById('lazy1');
        expect(lazy1).toBeDefined();
        done();
      }, false);
    });
    afterAll(function () {
      testWindow.close();
    });
    triggerScroll = function (window) {
      window.scrollTo(0, 3010);
    };
    lazyLoad = function(element){
      return () => {
        const url = element.getAttribute('data-src');
        element.removeAttribute('data-src');
        element.setAttribute('src', url);
      };
    };
    it('should lazy load image on scroll', function (done) {
      var lazy1 = testDocument.getElementById('lazy1');
      var url = lazy1.getAttribute('data-src');
      expect(url.startsWith('http')).toEqual(true);

      cloudinary.Util.detectIntersection(lazy1, lazyLoad(lazy1));

      setTimeout(()=>{
        expect(lazy1.getAttribute('src')).toEqual(null);
        expect(lazy1.getAttribute('data-src')).toEqual(url);
        triggerScroll(testWindow);

        setTimeout(()=>{
          expect(lazy1.getAttribute('src')).toEqual(url);
          expect(lazy1.getAttribute('data-src')).toEqual(null);
          done();
        }, 100);

      }, 100);
    });
  });
});