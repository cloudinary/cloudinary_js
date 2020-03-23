const bundlewatchConfig = {
  files: [
    {
      path: './dist/cloudinary-core.min.js',
      maxSize: '20kb'
    },
    {
      path: './dist/cloudinary-core-shrinkwrap.min.js',
      maxSize: '27kb'
    },
    {
      path: './dist/cloudinary-jquery.js',
      maxSize: '45kb'
    },
    {
      path: './dist/cloudinary-jquery-file-upload.js',
      maxSize: '47kb'
    }
  ],
  defaultCompression: 'gzip',
};

module.exports = bundlewatchConfig;
