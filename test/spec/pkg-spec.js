/**
 * Verify existance of all needed files in each package.
 * This test file should be run before each release.
 */

const fs = require('fs');
const path = require('path');
const SpecReporter = require('jasmine-spec-reporter').SpecReporter;

//Set jasmine reporter
jasmine.getEnv().clearReporters();
jasmine.getEnv().addReporter(new SpecReporter({
  spec: {
    displayPending: true
  },
}));

const commonExtensions = ['d.ts', 'js', 'min.js', 'js.map'];
const shrinkwrapExtensions = ['shrinkwrap.js', 'shrinkwrap.js.map', 'shrinkwrap.min.js'];
const commonFiles = ['src', 'package.json', 'README.md'];

/**
 * Adds file names to given files array
 * @param files
 * @param pkgName
 * @param extensions
 * @param delimiter
 * @returns {*}
 */
const addToFiles = (files, pkgName, extensions, delimiter) => {
  return files.concat(extensions.map(extension => `${pkgName}${delimiter}${extension}`));
};

/**
 * Creates a package object with name and files
 * @param pkgName
 * @param withShrinkwrap
 * @returns {{name: *, files: *}}
 */
const createPackage = (pkgName, withShrinkwrap) => {
  let files = addToFiles([...commonFiles], pkgName, commonExtensions, '.');

  if (withShrinkwrap) {
    files = addToFiles(files, pkgName, shrinkwrapExtensions, '-');
  }

  return {
    name: pkgName,
    files
  };
};

/**
 * Get path of given fileName in given pkgName
 * @param pkgName
 * @param fileName
 * @returns {*}
 */
const getPath = (pkgName, fileName = '') => {
  return path.join(__dirname, '..', '..', 'pkg', pkgName, fileName);
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

const requiredPackages = [
  createPackage('cloudinary-core', true),
  createPackage('cloudinary-jquery'),
  createPackage('cloudinary-jquery-file-upload')
];

requiredPackages.forEach(pkg => {
  verifyPackageConsistency(pkg);
});
