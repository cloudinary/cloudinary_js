const bundlewatchConfig = {
  files: [
    {
      path: './dist/cloudinary-core.min.js',
      maxSize: '24kb'
    },
    {
      path: './dist/cloudinary-core-shrinkwrap.min.js',
      maxSize: '32kb'
    },
    {
      path: './dist/cloudinary-jquery.min.js',
      maxSize: '23kb'
    },
    {
      path: './dist/cloudinary-jquery-file-upload.min.js',
      maxSize: '24kb'
    }
  ],
  defaultCompression: 'gzip',
};

module.exports = bundlewatchConfig;
