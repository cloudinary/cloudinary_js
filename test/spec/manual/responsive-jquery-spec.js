var cl, topPosition;

topPosition = 0;

cl = null;

let describeTest = describe;

if (/phantom|HeadlessChrome|HeadlessFirefox/i.test(navigator.userAgent)) {
  console.warn("Skipping responsive tests in PhantomJS or HeadlessChrome");
  describeTest = xdescribe;
}

describeTest('client side responsive', function() {
  let defaultConfig = {
    cloud_name: 'sdk-test'
  };

  return describe("responsive", function() {
    var container, fixtureContainer, handler, originalTimeout, testDocument, testWindow, triggerResize;
    fixtureContainer = void 0;
    testDocument = null;
    container = void 0;
    testWindow = null;
    originalTimeout = 0;
    beforeAll(function(done) {
      var testURL;
      // Open a new window with test HTML. A dynamic title is required in order to open a *new* window each time even if
      // previous window was not closed.
      testURL = "responsive-jquery-test.html";
      if (typeof __karma__ !== "undefined") {
        testURL = `/base/test/docRoot/${testURL}`;
      }
      testWindow = window.open(testURL, `Cloudinary test ${(new Date()).toLocaleString()}`, "width=500, height=500, top=" + topPosition, false);
      topPosition = 500;
      return testWindow.addEventListener('karma-ready', () => {
        var image1;
        testDocument = testWindow.document;
        image1 = testDocument.getElementById('image1');
        expect(image1).toBeDefined();
        return done();
      }, false);
    });
    afterAll(function() {
      testWindow.removeEventListener('resize', handler);
      return testWindow.close();
    });
    beforeEach(function() {
      originalTimeout = jasmine.DEFAULT_TIMEOUT_INTERVAL;
      jasmine.DEFAULT_TIMEOUT_INTERVAL = 10000;
      cl = $.cloudinary = new cloudinary.CloudinaryJQuery(defaultConfig);
      fixtureContainer = document.createElement('div');
      fixtureContainer.id = "fixture";
      return document.body.appendChild(fixtureContainer);
    });
    afterEach(function() {
      fixtureContainer.remove();
      return jasmine.DEFAULT_TIMEOUT_INTERVAL = originalTimeout;
    });
    triggerResize = function(window) {
      var evt;
      evt = window.document.createEvent('UIEvents');
      evt.initUIEvent('resize', true, false, window, 0);
      return window.dispatchEvent(evt);
    };
    it('should traverse up the DOM to find a parent that has clientWidth', function() {
      var aContainer, divContainer, img;
      divContainer = $('<div>').css({
        width: 101
      }).appendTo(fixtureContainer);
      aContainer = $('<a>').appendTo(divContainer);
      img = cl.image('sample.jpg', {
        width: 'auto',
        dpr: 'auto',
        crop: 'scale',
        responsive: true
      });
      img.appendTo(aContainer);
      cl.responsive();
      return expect(img.attr('src')).not.toEqual(void 0);
    });
    it('should compute breakpoints correctly', function() {
      var el;
      el = $('<img/>');
      expect(cl.calc_breakpoint(el, 1)).toEqual(100);
      expect(cl.calc_breakpoint(el, 10)).toEqual(100);
      expect(cl.calc_breakpoint(el, 110)).toEqual(200);
      cl.config().breakpoints = [50, 150];
      expect(cl.calc_breakpoint(el, 1)).toEqual(50);
      expect(cl.calc_breakpoint(el, 100)).toEqual(150);
      expect(cl.calc_breakpoint(el, 180)).toEqual(150);
      cl.config().breakpoints = function(width) {
        return width / 2;
      };
      expect(cl.calc_breakpoint(el, 100)).toEqual(50);
      $(el).data('breakpoints', '70,140');
      expect(cl.calc_breakpoint(el, 1)).toEqual(70);
      return expect(cl.calc_breakpoint(el, 100)).toEqual(140);
    });
    it('should correctly resize responsive images', function(done) {
      var dpr, img;
      container = void 0;
      img = void 0;
      dpr = cl.device_pixel_ratio();
      container = $('<div></div>').css({
        width: 101
      }).appendTo(fixtureContainer);
      img = cl.image('sample.jpg', {
        width: 'auto',
        dpr: 'auto',
        crop: 'scale',
        responsive: true
      });
      img.appendTo(container);
      expect(img.attr('src')).toBeFalsy();
      cl.responsive();
      expect(img.attr('src')).toEqual(window.location.protocol + '//res.cloudinary.com/sdk-test/image/upload/c_scale,dpr_' + dpr + ',w_200/sample.jpg');
      container.css('width', 211);
      expect(img.attr('src')).toEqual(window.location.protocol + '//res.cloudinary.com/sdk-test/image/upload/c_scale,dpr_' + dpr + ',w_200/sample.jpg');
      $(window).resize();
      return window.setTimeout(function() {
        // wait(200)
        expect(img.attr('src')).toEqual(window.location.protocol + '//res.cloudinary.com/sdk-test/image/upload/c_scale,dpr_' + dpr + ',w_300/sample.jpg');
        container.css('width', 101);
        return window.setTimeout(function() {
          // wait(200)
          expect(img.attr('src')).toEqual(window.location.protocol + '//res.cloudinary.com/sdk-test/image/upload/c_scale,dpr_' + dpr + ',w_300/sample.jpg');
          return done();
        }, 200);
      }, 200);
    });
    it("should not resize images with fixed width containers", function(done) {
      var currentWidth, image1, src;
      image1 = testDocument.getElementById('image1');
      src = image1.getAttribute('src');
      expect(src).toBeDefined();
      expect(src).not.toBe('');
      currentWidth = src.match(/w_(auto:)?(breakpoints[_\d]*:)?(\d+)/)[3];
      handler = function() {
        var newWidth;
        src = image1.getAttribute('src');
        expect(src).toBeDefined();
        newWidth = src.match(/w_(\d+)/)[1];
        expect(newWidth).toEqual(currentWidth);
        return done();
      };
      testWindow.addEventListener('resize', handler);
      testWindow.resizeBy(200, 0);
      triggerResize(window);
    });
    return describe("responsive_class", function() {
      return it("should set the class used for responsive functionality", function() {
        var img;
        img = cl.image("sample", {
          responsive: true,
          responsive_class: "cl-foobar"
        });
        return expect(cloudinary.Util.hasClass(img, "cl-foobar")).toBeTruthy();
      });
    });
  });
});

//# sourceMappingURL=responsive-jquery-spec.js.map
