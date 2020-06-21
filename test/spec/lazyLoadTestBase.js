// This file is imported using a script tag, in lazy-load html files.
function testLazyLoad(fileName) {
  let describeLazyLoadTest = describe;

  if (/phantom|HeadlessChrome|HeadlessFirefox/i.test(navigator.userAgent)) {
    console.warn("Skipping LazyLoad tests in PhantomJS or HeadlessChrome");
    describeLazyLoadTest = xdescribe;
  }

  function triggerScroll(window) {
    window.scrollTo(0, 3010);
  }

  describeLazyLoadTest('client side advanced image component' + navigator.userAgent, function () {
    describe("lazy loading", function () {
      let testDocument, testWindow;
      beforeAll(function (done) {
        // Open a new window with test HTML. A dynamic title is required in order to open a *new* window each time even if
        // previous window was not closed.
        if (typeof __karma__ !== "undefined") {
          testURL = `/base/test/docRoot/${fileName}`;
        }
        testWindow = window.open(testURL, `Cloudinary test ${(new Date()).toLocaleString()}`, "width=500, height=500");
        testWindow.addEventListener('karma-ready', () => {
          testDocument = testWindow.document;
          const lazyImage = testDocument.getElementById('lazyImage');
          expect(lazyImage).toBeDefined();
          done();
        }, false);
      });
      afterAll(function () {
        testWindow.close();
      });
      it('detectIntersection() should call callback when lazyImage is in view', function (done) {
        let isCalled = false;
        const callback = () => (isCalled = true);
        const lazyImage = testDocument.getElementById('lazyImage');

        //Activate intersection detection for lazyImage
        cloudinary.Util.detectIntersection(lazyImage, callback);

        //Scroll to lazyImage, so it's in view
        triggerScroll(testWindow);

        // Check that callback was called
        setTimeout(() => {
          expect(isCalled).toEqual(true);
          done();
        }, 100);
      });
    });
  });
}