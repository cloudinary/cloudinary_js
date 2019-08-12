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

const pkgPath = path.join(__dirname, '..', '..', 'pkg');
const commonFiles = ['src', 'package.json', 'README.md'];

const commonExtensions = {
  extensions: ['d.ts', 'js', 'min.js', 'js.map'],
  delimiter: '.'
};

const shrinkwrapExtensions = {
  extensions: ['shrinkwrap.js', 'shrinkwrap.js.map', 'shrinkwrap.min.js'],
  delimiter: '-'
};

const requiredPackages = [
  createPackage('cloudinary-core', commonExtensions, shrinkwrapExtensions),
  createPackage('cloudinary-jquery', commonExtensions),
  createPackage('cloudinary-jquery-file-upload', commonExtensions)
];

/**
 * Verify that a package has only required files
 * @param pkg
 */
function verifyPackageConsistency(pkg) {
  const actualFiles = fs.readdirSync(`${pkgPath}/${pkg.name}`);

  describe(pkg.name, () => {
    it('Should contain required files:', () => {
      getArrayDiff(pkg.files, actualFiles).forEach(file => {
        fail(file);
      })
    });
    it('Should not contain redundant files:', () => {
      getArrayDiff(actualFiles, pkg.files).forEach(file => {
        fail(file);
      })
    });
  });
}

/**
 * Creates a package object with name and files
 * @param pkgName
 * @param withShrinkwrap
 * @returns {{name: *, files: *}}
 */
function createPackage(pkgName, ...extensions) {
  let files = [...commonFiles];
  extensions.forEach(extensionsItem => {
    files = extendFileList(files, pkgName, extensionsItem.extensions, extensionsItem.delimiter);
  });

  return {
    name: pkgName,
    files
  };
}

/**
 * Adds file names to given files array
 * @param files
 * @param pkgName
 * @param extensions
 * @param delimiter
 * @returns {*}
 */
function extendFileList(files, pkgName, extensions, delimiter) {
  return files.concat(extensions.map(extension => `${pkgName}${delimiter}${extension}`));
}

/**
 * return items from arr1 that arr2 does not contain
 * @param arr1
 * @param arr2
 * @returns {*}
 */
function getArrayDiff(arr1, arr2) {
  return arr1.filter(item => !arr2.includes(item));
}

requiredPackages.forEach(pkg => {
  verifyPackageConsistency(pkg);
});
