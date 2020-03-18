const bundlewatchConfig = {
  files: [
    {
      path: './dist/cloudinary-core.min.js',
      maxSize: '80kb',
      compression: 'none',
    },
    {
      path: './dist/cloudinary-core-shrinkwrap.min.js',
      maxSize: '130kb',
      compression: 'none',
    },
  ],

  defaultCompression: 'gzip',  // Do we want the results in gzip form?
};

module.exports = bundlewatchConfig;
