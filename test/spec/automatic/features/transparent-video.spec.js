let myDescribe = describe;

if (/phantom|HeadlessChrome|HeadlessFirefox|Chrome/i.test(navigator.userAgent)) {
  console.warn("Transparent video skipped - Running only on Firefox");
  myDescribe = xdescribe;
}

myDescribe("Transparent Video Test", function () {
  let restoreXHR = () => {};
  let timeout = 60000;
  let cl;
  beforeEach(() => {
    cl = new cloudinary.Cloudinary({cloud_name: "sdk-test"});
    createTestContainer();
  });
  afterEach(() => {
    removeSeeThruScript();
    removeTestContainer();
    restoreXHR();
  });


  describe('SeeThru tests', () => {
    it("Display seeThru canvas if there is no Native support for video", function (done) {
      restoreXHR = forceNativeTransparentSupport(false);
      let container = getTestContainer();


      cl.injectTransparentVideoElement(container, 'transparentVideoTests/transparent-girl', {
        loop: true,
        max_timeout_ms: timeout,
        class: 'a-custom-class'
      }).then((res) => {
        let canvas = res.querySelector('.cld-transparent-video');
        let video = res.querySelector('video');

        expect(canvas).not.toBe(null);
        expect(res).toBe(container);
        expect(video.hasAttribute('autoplay')).toBe(true);
        expect(video.hasAttribute('loop')).toBe(true);
        expect(video.hasAttribute('muted')).toBe(true);
        expect(video.getAttribute('src')).toContain('blob:http://');
        expect(video.hasAttribute('seethruurl')).toBe(false);
        expect(video.hasAttribute('max_timeout_ms')).toBe(false);

        let classes = canvas.className.split(/\s+/);
        expect(classes.indexOf('a-custom-class')).toBeGreaterThanOrEqual(0);
        done();
      }).catch((err) => {
        // Fail test if we reach the catch
        expect(err).toBeUndefined();
        done();
      });
    }, timeout);

    it("Should timeout with a short enough max_timeout_ms", function (done) {
      restoreXHR = forceNativeTransparentSupport(false);
      let container = getTestContainer();

      // Add a more strict check that the function was really rejected in a very short time
      let start = Date.now();
      cl.injectTransparentVideoElement(container, 'transparentVideoTests/transparent-girl', {
        max_timeout_ms: 1
      }).catch((err) => {
        let end = Date.now();
        expect(end - start).toBeLessThan(50);
        // We expect to fail due to a short timeout
        expect(err.status).toBe('error');
        done();
      });
    }, 1000);

    it("seeThru - Loads flat transformation into the URL correctly, and alpha flag injected correctly", function (done) {
        restoreXHR = forceNativeTransparentSupport(false);
        let container = getTestContainer();

        cl.injectTransparentVideoElement(container, 'transparentVideoTests/transparent-girl', {
          max_timeout_ms: timeout,
          width:100,
          height:100,
          crop: 'fit'
        }).then((res) => {
          let canvas = res.querySelector('canvas');
          let video = res.querySelector('video');
          let videoSrc = video.getAttribute('data-video-url');
          expect(videoSrc).toContain("/c_fit,fl_alpha,h_100,w_100/v1/transparentVideoTests/transparent-girl");
          done();
        }).catch((err) => {
          // Fail test if we reach the catch
          expect(err).toBeUndefined();
          done();
        });
    }, timeout); // timeout

    it("Test that a custom seeThru URL can be used", function (done) {
      restoreXHR = forceNativeTransparentSupport(false);
      let container = getTestContainer();
      let cl = new cloudinary.Cloudinary({cloud_name: "test-sdk"});

      cl.injectTransparentVideoElement(container, 'transparentVideoTests/transparent-girl', {
        max_timeout_ms: timeout,
        externalLibraries: {
          seeThru : 'zzz'
        }
      }).catch((err) => {
        // we expect it to fail due to an invalid script
        expect(err.status).toBe('error');
        expect(err.message).toContain('zzz');
        expect(err.status).toBe('error');
        done();
      });
    }, timeout);

    it("Loading two videos should not include seeThru.js twice", function (done) {
      restoreXHR = forceNativeTransparentSupport(false);
      let container = getTestContainer();

      cl.injectTransparentVideoElement(container, 'transparentVideoTests/transparent-girl', {
        max_timeout_ms: timeout
      }).then(() => {
        cl.injectTransparentVideoElement(container, 'transparentVideoTests/transparent-girl', {
          max_timeout_ms: timeout
        }).then(() => {
          let scripts = [...document.head.querySelectorAll("[src*=seethru]")];
          expect(scripts.length).toBe(1);
          done();
        });
      });
    }, timeout * 2);
  });

  describe('Native Transparency Video tests', () => {
    it("Display regular Video Element for if browser supports it", function (done) {
      restoreXHR = forceNativeTransparentSupport(true);
      let container = getTestContainer();

      cl.injectTransparentVideoElement(container, 'transparentVideoTests/transparent-girl', {
        class: 'a-custom-class'
      }).then((res) => {
        let canvas = res.querySelector('canvas.cld-transparent-video');
        let video = res.querySelector('video');

        expect(canvas).toBe(null);
        expect(res).toBe(container);

        // Autoplay and Muted are always on and cannot be overwritten
        expect(video.hasAttribute('autoplay')).toBe(true);
        expect(video.hasAttribute('muted')).toBe(true);
        expect(video.hasAttribute('loop')).toBe(false);

        // no invalid attributes passed to video tag (these are added to options by default)
        expect(video.hasAttribute('seethruurl')).toBe(false);
        expect(video.hasAttribute('max_timeout_ms')).toBe(false);

        // Ensure custom class name is passed down to video element
        let sources = [...video.querySelectorAll('source')];
        expect(sources.length).toBeGreaterThan(0);
        let classes = video.className.split(/\s+/);
        expect(classes.indexOf('a-custom-class')).toBeGreaterThanOrEqual(0);
        done();
      }).catch((err) => {
        // Fail test if we reach the catch
        expect(err).toBeUndefined();
        done();
      });
    }, timeout); // timeout

    it("Native - Loads flat transformation into the URL correctly, and alpha flag injected correctly", function (done) {
      restoreXHR = forceNativeTransparentSupport(true);
      let container = getTestContainer();

      cl.injectTransparentVideoElement(container, 'transparentVideoTests/transparent-girl', {
        width:100,
        height:100,
        crop: 'fit'
      })
        .then((res) => {
          let video = res.querySelector('video');
          let videoSrc = video.children[0].src;
          // Test that the video does not automatically gets the loop attribute
          expect(video.hasAttribute('loop')).toBe(false);
          expect(videoSrc).toContain("/c_fit,fl_alpha,h_100,w_100/v1/transparentVideoTests/transparent-girl");
          done();
        }).catch((err) => {
        // Fail test if we reach the catch
        expect(err).toBeUndefined();
        done();
      });
    }, timeout); // timeout

    it("Has a false loop attribute", function (done) {
      restoreXHR = forceNativeTransparentSupport(true);
      let container = getTestContainer();

      cl.injectTransparentVideoElement(container, 'transparentVideoTests/transparent-girl')
        .then((res) => {
        let video = res.querySelector('video');
        // Test that the video does not automatically gets the loop attribute
        expect(video.hasAttribute('loop')).toBe(false);
        done();
      }).catch((err) => {
        // Fail test if we reach the catch
        expect(err).toBeUndefined();
        done();
      });
    }, timeout); // timeout

    it("Times out correctly", function (done) {
      restoreXHR = forceNativeTransparentSupport(false);
      let container = getTestContainer();

      cl.injectTransparentVideoElement(container, 'transparentVideoTests/transparent-girl', {
        max_timeout_ms: 1
      }).catch((err) => {
        // We expect to fail due to a short timeout
        expect(err.status).toBe('error');
        done();
      });
    }, timeout); // timeout
  });
});

// Utilities for the test
/**
 * @description forces the returned headers from the XHR to be X-Cld-Vmuxed-Alpha or not, based on parameter
 *              Overwrites XHR.prototype.getAllResponseHeaders to return something specific for the test.
 * @param {boolean} isNativeSupported
 * @return {function(...[*]=)}
 */
function forceNativeTransparentSupport(isNativeSupported) {
  let original = HTMLVideoElement.prototype.canPlayType;


  HTMLVideoElement.prototype.canPlayType = () => {
    return isNativeSupported ? 'maybe' : '';
  };

  return () => {
    HTMLVideoElement.prototype.canPlayType = original;
  };
}

/**
 * Appends an HTMLElement container with a specific ID to the DOM
 */
function createTestContainer() {
  let div = document.createElement('div');
  div.setAttribute('id', 'container');
  document.body.append(div);
}

/**
 * Gets the the container created by createTestContainer();
 */
function getTestContainer() {
  return document.getElementById('container');
}

/**
 * Cleans up the container created by createTestContainer();
 */
function removeTestContainer() {
  document.getElementById('container').remove();
}

/**
 * Removes the <script> tag for seeThru, and also deletes the seeThru reference on the window object
 * this is used to make the tests as atomic as possible
 */
function removeSeeThruScript() {
  let scripts = [...document.head.querySelectorAll('script')];

  scripts.forEach((script) => {
    if (script.src.indexOf('seeThru.min.js') >= 0) {
      script.remove();
      delete window.seeThru;
    }
  });
}


