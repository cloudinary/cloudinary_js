const path = require('path');
const lodashExternals = [
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

module.exports = function (env, argv) {
  const isProd = argv.mode === 'production' || env === 'prod' || env && env.prod;
  const mode = isProd ? 'production' : 'development';
  let baseConfig = (name, entry, util) => ({
    name,
    mode,
    entry: {
      [name]: entry
    },
    output: {
      library: 'cloudinary',
      libraryTarget: 'umd',
      filename: `./cloudinary-[name]${isProd ? '.min' : ''}.js`,
      auxiliaryComment: 'Test Comment'
    },
    resolve: {
      extensions: ['.js'],
      alias: {
        "../util$": path.resolve(__dirname, `src/util/${util}`),
        "./util$": path.resolve(__dirname, `src/util/${util}`)
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
      function (context, request, callback) {
        if (/^lodash\//.test(request)) {
          callback(null, request.split('/'), 'amd')
        } else {
          callback()
        }
      }
    ],
    node: {
      Buffer: false,
      process: false
    },
    devtool: "source-map",
    module: isProd ? {
      rules: [
        {
          test: /\.m?js$/,
          exclude: /(node_modules|bower_components)/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: ['@babel/preset-env']
            }
          }
        }
      ]
    } : {},
    plugins: [
    ]
  });


  return [
    baseConfig("core", './src/namespace/cloudinary-core.js', "lodash"),
    baseConfig("jquery", './src/namespace/cloudinary-jquery.js', "jquery"),
    baseConfig("jquery-file-upload", './src/namespace/cloudinary-jquery-file-upload.js', "jquery"),
    {
      ...baseConfig("core-shrinkwrap", './src/namespace/cloudinary-core.js', "lodash"),
      externals: {
        jquery: 'jQuery'
      }

    }
  ];
};
