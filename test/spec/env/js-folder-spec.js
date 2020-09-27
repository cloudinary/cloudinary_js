const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const jsPath = path.join(__dirname, '..', '..', '..', 'js');

const SpecReporter = require('jasmine-spec-reporter').SpecReporter;

//Set jasmine reporter
jasmine.getEnv().clearReporters();
jasmine.getEnv().addReporter(new SpecReporter({
  spec: {
    displayPending: true
  },
}));

// List of files to test
const files = [
  {name: 'canvas-to-blob.min.js', checkSum: "33ecbe6885ad339c3a5af0cfa063810d"},
  {name: 'jquery.cloudinary.js', checkSum: "27886431ad43cf97ca3edd2ed3f4e379"},
  {name: 'jquery.fileupload.js', checkSum: "4bfd85460689a29e314ddfad50c184e0"},
  {name: 'jquery.fileupload-image.js', checkSum: "7c40367b00f74b0c7c43bff009dde942"},
  {name: 'jquery.fileupload-process.js', checkSum: "840f65232eaf1619ea0aff1ab4f5e444"},
  {name: 'jquery.fileupload-validate.js', checkSum: "a144e6149c89ed27e0b2d7fcfef09101"},
  {name: 'jquery.iframe-transport.js', checkSum: "f371e8d9f57329f90114d7b52dd5c7a4"},
  {name: 'jquery.ui.widget.js', checkSum: "3d0f0f5ca5d86c5a4b4fc33cda374a17"},
  {name: 'load-image.all.min.js', checkSum: "c4cdadc311ce87bb6f89491d1289b0a3"}
];

/**
 * Generates Checksum for given file
 * @param fileName of file to generate checksum for
 * @param algorithm to use
 * @param encoding to use
 * @return {string} checksum of given file
 */
function generateChecksum(fileName, algorithm='md5', encoding='hex') {
  return crypto
    .createHash(algorithm)
    .update(fs.readFileSync(`${jsPath}/${fileName}`), 'utf8')
    .digest(encoding);
}


describe("js-folder", function () {
  files.forEach(f => {
    it(`${f.name} should not change`, function () {
      const checkSum = generateChecksum(f.name);
      expect(checkSum).toEqual(f.checkSum);
    });
  });
});
