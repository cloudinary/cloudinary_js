let myDescribe = describe;

if (/phantom|HeadlessChrome|HeadlessFirefox|Chrome/i.test(navigator.userAgent)) {
  console.warn("Transparent video skipped - Running only on Firefox");
  myDescribe = xdescribe;
}

myDescribe("Transparent Video Test", function () {
  let restoreXHR = () => {};
  let timeout = 60000;
  beforeEach(() => {
    createTestContainer();
  });
  afterEach(() => {
    removeSeeThruScript();
    removeTestContainer();
    restoreXHR();
  });


  // Annotations, these will be removed before we merge.
  // TODO global
  //  Skip this test in Chrome and Headless - Run only in FireFox (There was an issue with
  //  Upload the video file and then delete it

  // TODO - seeThru - What was tested?
  //  DONE - Ensure custom class is passed successfully to Canvas
  //  DONE - test max_timout actually times out
  //  DONE - test that we already have seeThru (load a URL twice, ensure no double scriptTags)
  //  DONE - test loop parameter exists
  //       - test for seeThru URL

  // TODO NativeSupport
  //  DONE - Ensure custom class is passed successfully to video element
  //  DONE - test max_timout
  //  DONE - test loop parameter exists
  //  DONE - Test our extra arguments are not passing to video element

  describe('SeeThru tests', () => {
    it("Display seeThru canvas if there is no Native support for video", function (done) {
      restoreXHR = forceNativeTransparentSupport(false);
      let container = getTestContainer();

      let cl = new cloudinary.Cloudinary({cloud_name: "eran2903"});

      cl.createTransparentVideo(container, 'transparency/girl_test_vpusyw', {
        loop: true,
        max_timeout: timeout,
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
        expect(video.hasAttribute('max_timeout')).toBe(false);

        let classes = canvas.className.split(/\s+/);
        expect(classes.indexOf('a-custom-class')).toBeGreaterThanOrEqual(0);
        done();
      }).catch((err) => {
        // Fail test if we reach the catch
        expect(err).toBeUndefined();
        done();
      });
    }, timeout); // timeout

    it("Should timeout with a short enough max_timeout", function (done) {
      restoreXHR = forceNativeTransparentSupport(false);
      let container = getTestContainer();
      let cl = new cloudinary.Cloudinary({cloud_name: "eran2903"});

      cl.createTransparentVideo(container, 'transparency/girl_test_vpusyw', {
        max_timeout: 1
      }).catch((err) => {
        // We expect to fail due to a short timeout
        expect(err.status).toBe('error');
        done();
      });
    }, timeout);

    it("Test that a custom seeThru URL can be used", function (done) {
      restoreXHR = forceNativeTransparentSupport(false);
      let container = getTestContainer();
      let cl = new cloudinary.Cloudinary({cloud_name: "eran2903"});

      cl.createTransparentVideo(container, 'transparency/girl_test_vpusyw', {
        max_timeout: timeout,
        seeThruURL: 'http://abc.xyz.tmp'
      }).catch((err) => {
        // we expect it to fail due to an invalid script
        expect(err.status).toBe('error');
        expect(err.message).toContain('http://abc.xyz.tmp');
        expect(err.status).toBe('error');
        done();
      });
    }, timeout);

    it("Loading two videos should not include seeThru.js twice", function (done) {
      restoreXHR = forceNativeTransparentSupport(false);
      let container = getTestContainer();
      let cl = new cloudinary.Cloudinary({cloud_name: "eran2903"});

      cl.createTransparentVideo(container, 'transparency/girl_test_vpusyw', {
        max_timeout: timeout
      }).then(() => {
        cl.createTransparentVideo(container, 'transparency/girl_test_vpusyw', {
          max_timeout: timeout
        }).then(() => {
          setTimeout(() => {
            let scripts = [...document.head.querySelectorAll('script')];
            expect(scripts.length).toBe(1);
            done();
          });
        });
      });
    }, timeout * 2);
  });

  describe('Native Transparency Video tests', () => {
    it("Display regular Video Element for if browser supports it", function (done) {
      restoreXHR = forceNativeTransparentSupport(true);
      let container = getTestContainer();
      let cl = new cloudinary.Cloudinary({cloud_name: "eran2903"});

      cl.createTransparentVideo(container, 'transparency/girl_test_vpusyw', {
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
        expect(video.hasAttribute('max_timeout')).toBe(false);

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

    it("Has a loop attribute", function (done) {
      restoreXHR = forceNativeTransparentSupport(true);
      let container = getTestContainer();
      let cl = new cloudinary.Cloudinary({cloud_name: "eran2903"});

      cl.createTransparentVideo(container, 'transparency/girl_test_vpusyw')
        .then((res) => {
        let video = res.querySelector('video');
        // Autoplay and Muted are always on and cannot be overwritten
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
      let cl = new cloudinary.Cloudinary({cloud_name: "eran2903"});

      cl.createTransparentVideo(container, 'transparency/girl_test_vpusyw', {
        max_timeout: 1
      }).catch((err) => {
        // We expect to fail due to a short timeout
        expect(err.status).toBe('error');
        done();
      });
    }, timeout); // timeout
  });
});

// Utilities for the test
function forceNativeTransparentSupport(isNativeSupported) {
  let xhr = window.XMLHttpRequest;
  let original = xhr.prototype.getAllResponseHeaders;

  xhr.prototype.getAllResponseHeaders = () => {
    return isNativeSupported ? '' : 'X-Cld-Vmuxed-Alpha';
  };
  return () => {
    xhr.prototype.getAllResponseHeaders = original;
  };
}

function createTestContainer() {
  let div = document.createElement('div');
  div.setAttribute('id', 'container');
  document.body.append(div);
}

function getTestContainer() {
  return document.getElementById('container');
}

function removeTestContainer() {
  document.getElementById('container').remove();
}

function removeSeeThruScript() {
  let scripts = [...document.head.querySelectorAll('script')];
  let script = scripts.find((script) => {
    return script.src.indexOf('seeThru.min.js') >= 0;
  });
  if (script) {
    script.remove();
    delete window.seeThru;
  }
}

