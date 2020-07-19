/**
 * Verify existence of all needed files in each package.
 * This test file should be run before each release.
 */

const fs = require('fs');
const path = require('path');
const {execSync} = require('child_process');
const tar = require('tar');
const SpecReporter = require('jasmine-spec-reporter').SpecReporter;

//Set jasmine reporter
jasmine.getEnv().clearReporters();
jasmine.getEnv().addReporter(new SpecReporter({
  spec: {
    displayPending: true
  },
}));

const mainPath = path.join(__dirname, '..', '..', '..');
const pkgPath = path.join(__dirname, '..', '..', '..', 'pkg');
const buildPath = path.join(__dirname, '..', '..', '..', 'dist');
const version = getVersion();
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
  const packedFiles = getPackedFiles(pkg);
  const actualFiles = fs.readdirSync(`${pkgPath}/${pkg.name}`).filter(f => !f.endsWith('.tgz') && !f.startsWith('src/'));
  const pkgVersion = getVersion(pkg);

  describe(pkg.name, () => {
    it('Folder should contain required files', () => {
      getArrayDiff(pkg.files, actualFiles).forEach(file => {
        fail(file);
      });
    });
    it('Folder should not contain redundant files', () => {
      getArrayDiff(actualFiles, pkg.files).forEach(file => {
        fail(file);
      });
    });
    it('Pack file should contain required files', () => {
      getArrayDiff(pkg.files, packedFiles).forEach(file => {
        fail(file);
      });
    });
    it('Pack file should not contain redundant files', () => {
      getArrayDiff(packedFiles, pkg.files).forEach(file => {
        fail(file);
      });
    });
    it(`Package version should be same as cloudinary_js: ${version}`, () => {
      expect(pkgVersion).toEqual(version);
    });
    it(`Package files should equal files in dist folder`, () => {
      expect(getUnequalBuildFiles(pkg, actualFiles)).toEqual([]);
    });
  });
}

/**
 * Creates a package object with name and files
 * @param pkgName
 * @param extensions
 * @returns {{name: *, files: string[]}}
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

/**
 * Run "npm pack" for given pkg
 * @param pkg
 */
function createPackageFile(pkg) {
  const currentPath = `${pkgPath}/${pkg.name}`;
  execSync('npm pack', {cwd: currentPath});
}

/**
 * Deletes tar of given pkg
 * @param pkg
 */
function deletePackageFile(pkg) {
  const tarFile = `${pkgPath}/${pkg.name}/${pkg.name}-${version}.tgz`;
  fs.unlinkSync(tarFile);
}

/**
 * Get array of files in given pkg tar file
 * @param pkg
 * @returns {any[]}
 */
function getPackedFiles(pkg) {
  createPackageFile(pkg);
  const tarFile = `${pkgPath}/${pkg.name}/${pkg.name}-${version}.tgz`;
  const files = new Set();

  // Loop over tar file entries
  tar.t({
    sync: true,
    file: tarFile,
    onentry: entry => files.add(getTarEntryPath(entry))
  });

  deletePackageFile(pkg);

  return [...files];
}

/**
 * Get real file path from tar entry path
 * @param entry
 * @returns {*}
 */
function getTarEntryPath(entry) {
  if (entry.path.startsWith("src/") || entry.path.startsWith("package/src/")) {
    return 'src';
  }

  return entry.path.replace("package/", "");
}

/**
 * Get version from package.json
 * @param pkg
 * @returns {*}
 */
function getVersion(pkg = null) {
  if (!pkg) {
    // get cloudinary_js version
    return JSON.parse(fs.readFileSync(`${mainPath}/package.json`)).version;
  }
  // get pkg version
  return JSON.parse(fs.readFileSync(`${pkgPath}/${pkg.name}/package.json`)).version;
}

/**
 * Get list of package files that are not equal build files
 * @param pkg
 * @param pkgFiles
 * @returns Array of file names
 */
function getUnequalBuildFiles(pkg, pkgFiles) {
  let result = [];

  //filter files that should not exist in build but should exist in package
  const files = pkgFiles.filter(file => !['README.md', `${pkg.name}.d.ts`, 'package.json', 'src'].includes(file));

  files.forEach(fileName => {
    const pkgFilePath = `${pkgPath}/${pkg.name}/${fileName}`;
    const buildFilePath = `${buildPath}/${fileName}`;
    const buildFileExists = fs.existsSync(buildFilePath);
    const buildFileEquals = buildFileExists && compareFiles(buildFilePath, pkgFilePath);
    if (!buildFileEquals) {
      result.push(fileName);
    }
  });
  return result;
}

/**
 * Compare two files content
 * @param fileA
 * @param fileB
 * @returns true if equal, false otherwise
 */
function compareFiles(fileA, fileB) {
  const bufferA = fs.readFileSync(fileA);
  const bufferB = fs.readFileSync(fileB);
  return bufferA.equals(bufferB);
}

requiredPackages.forEach(pkg => {
  verifyPackageConsistency(pkg);
});
