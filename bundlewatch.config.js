const bundlewatchConfig = {
  files: [
    {
      path: './dist/cloudinary-core.min.js',
      maxSize: '22kb'
    },
    {
      path: './dist/cloudinary-core-shrinkwrap.min.js',
      maxSize: '30kb'
    },
    {
      path: './dist/cloudinary-jquery.min.js',
      maxSize: '22kb'
    },
    {
      path: './dist/cloudinary-jquery-file-upload.min.js',
      maxSize: '23kb'
    }
  ],
  defaultCompression: 'gzip',
};

module.exports = bundlewatchConfig;
