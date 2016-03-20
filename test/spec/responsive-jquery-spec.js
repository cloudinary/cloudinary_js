describe('Cloudinary', function() {
  var cl, defaultConfig;
  defaultConfig = {
    cloud_name: 'demo'
  };
  cl = null;
  return describe("responsive", function() {
    var container, fixtureContainer, testDocument, testWindow, triggerResize;
    fixtureContainer = void 0;
    testDocument = null;
    container = void 0;
    testWindow = null;
    beforeAll(function(done) {
      testWindow = window.open("responsive-jquery-test.html", "Cloudinary test " + ((new Date()).toLocaleString()), "width=500, height=500");
      return testWindow.addEventListener('load', (function(_this) {
        return function() {
          var image1;
          testDocument = testWindow.document;
          image1 = testDocument.getElementById('image1');
          expect(image1.getAttribute('src')).toBeDefined();
          return done();
        };
      })(this), false);
    });
    afterAll(function() {
      return testWindow.close();
    });
    beforeEach(function() {
      cl = $.cloudinary = new cloudinary.CloudinaryJQuery(defaultConfig);
      fixtureContainer = document.createElement('div');
      fixtureContainer.id = "fixture";
      return document.body.appendChild(fixtureContainer);
    });
    afterEach(function() {
      return fixtureContainer.remove();
    });
    triggerResize = function(window) {
      var evt;
      evt = window.document.createEvent('UIEvents');
      evt.initUIEvent('resize', true, false, window, 0);
      return window.dispatchEvent(evt);
    };
    it('should traverse up the DOM to find a parent that has clientWidth', function() {
      var aContainer, divContainer, img;
      aContainer = void 0;
      divContainer = void 0;
      img = void 0;
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
      expect(img.attr('src')).toEqual(window.location.protocol + '//res.cloudinary.com/demo/image/upload/c_scale,dpr_' + dpr + ',w_200/sample.jpg');
      container.css('width', 211);
      expect(img.attr('src')).toEqual(window.location.protocol + '//res.cloudinary.com/demo/image/upload/c_scale,dpr_' + dpr + ',w_200/sample.jpg');
      $(window).resize();
      return window.setTimeout((function() {
        expect(img.attr('src')).toEqual(window.location.protocol + '//res.cloudinary.com/demo/image/upload/c_scale,dpr_' + dpr + ',w_300/sample.jpg');
        container.css('width', 101);
        return window.setTimeout((function() {
          expect(img.attr('src')).toEqual(window.location.protocol + '//res.cloudinary.com/demo/image/upload/c_scale,dpr_' + dpr + ',w_300/sample.jpg');
          return done();
        }), 200);
      }), 200);
    });
    return it("should not resize images with fixed width containers", function(done) {
      var currentWidth, handler, image1, src;
      image1 = testDocument.getElementById('image1');
      src = image1.getAttribute('src');
      expect(src).toBeDefined();
      currentWidth = src.match(/w_(\d+)/)[1];
      handler = function() {
        var newWidth;
        src = image1.getAttribute('src');
        newWidth = src.match(/w_(\d+)/)[1];
        expect(newWidth).toEqual(currentWidth);
        return done();
      };
      testWindow.addEventListener('resize', handler);
      return testWindow.resizeBy(200, 0);
    });
  });
});

//# sourceMappingURL=responsive-jquery-spec.js.map
