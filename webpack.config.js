const path = require('path');
const lodashExternals= [
"lodash/assign",
"lodash/cloneDeep",
"lodash/compact",
"lodash/difference",
"lodash/functions",
"lodash/identity",
"lodash/includes",
"lodash/isArray",
"lodash/isElement",
"lodash/isEmpty",
"lodash/isFunction",
"lodash/isPlainObject",
"lodash/isString",
"lodash/merge",
"lodash/trim",
].reduce((map, lib) => {
    map[lib] = {
      commonjs: lib,
      commonjs2: lib,
      amd: lib,
      root: ['_', lib.split('/')[1]]
    };
    return map;
  }, {}
);
let baseConfig = (name, entry, util) => ({
  mode: 'development',
  entry: {
    [name]: entry
  },
  output: {
    library: 'cloudinary',
    libraryTarget: 'umd',
    filename: './cloudinary-[name].js',
    auxiliaryComment: 'Test Comment'
  },
  module: {
    rules: [
      {
        test: /\.coffee$/,
        use: [
          'coffee-loader',
        ]
      }
    ]
  },
  resolve: {
    extensions: ['.coffee', '.js'],
    alias: {
      "../util": path.resolve(__dirname, `src/util/${util}`),
      "./util": path.resolve(__dirname, `src/util/${util}`)
    }
  },
  externals: [{
    jquery: 'jQuery',
    lodash: {
      commonjs: 'lodash',
      amd: 'lodash',
      root: '_' // indicates global variable
    },
    ...lodashExternals,
  },
    function(context, request, callback) {
      if(/^lodash\//.test(request)){
        callback(null,   request.split('/'), 'amd')
      } else {
        callback()
      }
    }
  ],
  node: {
    Buffer: false
  },
  devtool: "source-map"
});


module.exports = [
  baseConfig("core", './src/namespace/cloudinary-core.coffee', "lodash"),
  baseConfig("jquery", './src/namespace/cloudinary-jquery.coffee', "jquery"),
  baseConfig("jquery-file-upload", './src/namespace/cloudinary-jquery-file-upload.coffee', "jquery"),
  {
    ...baseConfig("core-shrinkwrap", './src/namespace/cloudinary-core.coffee', "lodash"),
    externals: {
      jquery: 'jQuery'
    }

  }
];
