/**
 * Test existance of all needed files in each package.
 * This test file should be run before each release.
 */

const fs = require('fs');
const path = require('path');
const SpecReporter = require('jasmine-spec-reporter').SpecReporter;

// We use 'jasmine-spec-reporter' to get nice logs to console.
jasmine.getEnv().clearReporters();               // remove default reporter logs
jasmine.getEnv().addReporter(new SpecReporter({  // add jasmine-spec-reporter
  spec: {
    displayPending: true // display each pending spec
  },
}));

/**
 * Get path of given fileName in given pkgName
 * @param pkgName
 * @param fileName
 * @returns {*}
 */
const getPath = (pkgName, fileName) => path.join(__dirname, '..', '..', 'pkg', pkgName, fileName);


/**
 * Test that a given fileName exist in given pkgName
 * @param pkgName
 * @param fileName
 */
testFileExists = (pkgName, fileName) => {
  const filePath = getPath(pkgName, fileName);
  const result = fs.existsSync(filePath);
  it(filePath, () => {
    expect(result).toEqual(true);
  })
};

/**
 * Test that all given files exist in given pkgName
 * @param pkgName
 * @param files
 */
testPkg = (pkgName, files) => {
  describe(`${pkgName}:`, function () {
    files.forEach(fileName => testFileExists(pkgName, fileName));
  });
};

testPkg('cloudinary-core',
  [
    'src',
    'cloudinary-core.d.ts',
    'cloudinary-core.js',
    'cloudinary-core.min.js',
    'cloudinary-core.js.map',
    'cloudinary-core-shrinkwrap.js',
    'cloudinary-core-shrinkwrap.js.map',
    'cloudinary-core-shrinkwrap.min.js',
    'package.json',
    'README.md'
  ]
);

testPkg('cloudinary-jquery',
  [
    'src',
    'cloudinary-jquery.d.ts',
    'cloudinary-jquery.js',
    'cloudinary-jquery.js.map',
    'cloudinary-jquery.min.js',
    'package.json',
    'README.md'
  ]
);

testPkg('cloudinary-jquery-file-upload',
  [
    'src',
    'cloudinary-jquery-file-upload.d.ts',
    'cloudinary-jquery-file-upload.js',
    'cloudinary-jquery-file-upload.js.map',
    'cloudinary-jquery-file-upload.min.js',
    'package.json',
    'README.md'
  ]
);
