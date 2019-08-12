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

//List of required packages and files
const packages = [
  {
    name: 'cloudinary-core',
    files: [
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
  },
  {
    name: 'cloudinary-jquery',
    files: [
      'src',
      'cloudinary-jquery.d.ts',
      'cloudinary-jquery.js',
      'cloudinary-jquery.js.map',
      'cloudinary-jquery.min.js',
      'package.json',
      'README.md'
    ]
  },
  {
    name: 'cloudinary-jquery-file-upload',
    files: [
      'src',
      'cloudinary-jquery-file-upload.d.ts',
      'cloudinary-jquery-file-upload.js',
      'cloudinary-jquery-file-upload.js.map',
      'cloudinary-jquery-file-upload.min.js',
      'package.json',
      'README.md'
    ]
  }
];

/**
 * Get path of given fileName in given pkgName
 * @param pkgName
 * @param fileName
 * @returns {*}
 */
const getPath = (pkgName, fileName) => {
  if (fileName) {
    return path.join(__dirname, '..', '..', 'pkg', pkgName, fileName);
  }

  return path.join(__dirname, '..', '..', 'pkg', pkgName);
};

/**
 * Return an array of files in given folder path
 * @param folderPath
 * @returns {Array}
 */
const getFilesList = (folderPath) => {
  let fileList = [];
  fs.readdirSync(folderPath).forEach(file => {
    fileList.push(file);
  });
  return fileList;
};

/**
 * Assert that a given path exists
 * @param filePath
 */
assertPathExists = (filePath) => {
  const result = fs.existsSync(filePath);
  it(filePath, () => {
    expect(result).toEqual(true);
  })
};

/**
 * Verify that a package has only required files
 * @param pkg
 */
verifyPackageConsistency = (pkg) => {
  const currentFiles = getFilesList(getPath(pkg.name));
  const unnecessaryFiles = currentFiles.filter(file => pkg.files.indexOf(file) < 0);

  describe(`${pkg.name}:`, function () {

    //test that necessary files exist
    describe(`Required Files:`, function () {
      pkg.files.forEach(fileName => {
        it(fileName, () => {
          expect(currentFiles.includes(fileName)).toBeTruthy();
        });
      });
    });

    //test that unnecessary files do not exist
      describe(`Unnecessary Files:`, function () {
        unnecessaryFiles.forEach(fileName => {
          it(fileName, () => {
            expect(fileName).toBeUndefined();
          });
        });
      });
  });
};

//Verify each package from packages list
packages.forEach(pkg => {
  verifyPackageConsistency(pkg);
});
