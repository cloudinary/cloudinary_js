(function() {
  describe('cloudinary', function() {
    var cl, fixtureContainer, test_cloudinary_url;
    cl = {};
    fixtureContainer = void 0;
    test_cloudinary_url = function(public_id, options, expected_url, expected_options) {
      var result;
      result = cl.url(public_id, options);
      expect(new cloudinary.Transformation(options).toHtmlAttributes()).toEqual(expected_options);
      return expect(result).toEqual(expected_url);
    };
    beforeEach(function() {
      cl = new cloudinary.Cloudinary({
        cloud_name: 'test123'
      });
      fixtureContainer = document.createElement('div');
      fixtureContainer.id = "fixture";
      return document.body.appendChild(fixtureContainer);
    });
    afterEach(function() {
      return fixtureContainer.remove();
    });
    return describe("responsive", function() {
      var container, originWindow, resizeWindow, testDocument, testWindow;
      testDocument = null;
      container = void 0;
      testWindow = null;
      originWindow = window;
      beforeAll(function(done) {
        testWindow = window.open("spec-empty-window.html", "Cloudinary responsive test", "width=500, height=500");
        testDocument = testWindow.document;
        return testWindow.addEventListener('load', function() {
          var image1;
          image1 = testDocument.getElementById('image1');
          expect(image1.getAttribute('src')).toBeDefined();
          return done();
        });
      });
      afterAll(function() {
        return testWindow.close();
      });
      resizeWindow = function(window) {
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
        divContainer = document.createElement('div');
        divContainer.style.width = 101;
        fixtureContainer.appendChild(divContainer);
        aContainer = document.createElement('a');
        divContainer.appendChild(aContainer);
        img = cl.image('sample.jpg', {
          width: 'auto',
          dpr: 'auto',
          crop: 'scale',
          responsive: true
        });
        aContainer.appendChild(img);
        cl.responsive();
        return expect(img.getAttribute('src')).not.toEqual(void 0);
      });
      it('should compute breakpoints correctly', function() {
        var el;
        el = document.createElement('img');
        expect(cl.calc_breakpoint(el, 1)).toEqual(10);
        expect(cl.calc_breakpoint(el, 10)).toEqual(10);
        expect(cl.calc_breakpoint(el, 11)).toEqual(20);
        cl.config('breakpoints', [50, 150]);
        expect(cl.calc_breakpoint(el, 1)).toEqual(50);
        expect(cl.calc_breakpoint(el, 100)).toEqual(150);
        expect(cl.calc_breakpoint(el, 180)).toEqual(150);
        cl.config('breakpoints', function(width) {
          return width / 2;
        });
        expect(cl.calc_breakpoint(el, 100)).toEqual(50);
        el.setAttribute('data-breakpoints', '70,140');
        expect(cl.calc_breakpoint(el, 1)).toEqual(70);
        return expect(cl.calc_breakpoint(el, 100)).toEqual(140);
      });
      it('should correctly resize responsive images', function(done) {
        var dpr, img;
        container = void 0;
        img = void 0;
        dpr = cl.device_pixel_ratio();
        container = document.createElement('div');
        container.style.width = "101px";
        fixtureContainer.appendChild(container);
        img = cl.image('sample.jpg', {
          width: 'auto',
          dpr: 'auto',
          crop: 'scale',
          responsive: true
        });
        container.appendChild(img);
        expect(img.getAttribute('src')).toBeFalsy();
        cl.responsive();
        expect(img.getAttribute('src')).toEqual(window.location.protocol + '//res.cloudinary.com/test123/image/upload/c_scale,dpr_' + dpr + ',w_101/sample.jpg');
        container.style.width = "111px";
        expect(img.getAttribute('src')).toEqual(window.location.protocol + '//res.cloudinary.com/test123/image/upload/c_scale,dpr_' + dpr + ',w_101/sample.jpg');
        window.dispatchEvent(new Event('resize'));
        return window.setTimeout(function() {
          expect(img.getAttribute('src')).toEqual(window.location.protocol + '//res.cloudinary.com/test123/image/upload/c_scale,dpr_' + dpr + ',w_120/sample.jpg');
          container.style.width = "101px";
          return window.setTimeout(function() {
            expect(img.getAttribute('src')).toEqual(window.location.protocol + '//res.cloudinary.com/test123/image/upload/c_scale,dpr_' + dpr + ',w_120/sample.jpg');
            return done();
          }, 200);
        }, 200);
      });
      return it("should not resize images with fixed width containers", function() {
        var currentWidth, image1, src;
        image1 = testDocument.getElementById('image1');
        src = image1.getAttribute('src');
        expect(src).toBeDefined();
        return currentWidth = src.match(/w_(\d+)/)[1];
      });
    });
  });

}).call(this);
