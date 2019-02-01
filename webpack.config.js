var path = require('path');
var TerserPlugin = require('terser-webpack-plugin');
var webpack = require('webpack');
var fs = require('fs');
var pkg = require('./package.json');
// Create a list of Class names to preserve when minifying
var namespace = fs.readFileSync('./src/namespace/cloudinary-jquery-file-upload.js').toString();
var reserved = namespace.match(/(\w+)(?= from)/g);

// Create a list of lodash modules to exclude from the bundle
var lodashUtil= fs.readFileSync('./src/util/lodash.js').toString();
var lodashExternals = lodashUtil.match(/lodash\/\w+/g);
lodashExternals = lodashExternals.reduce((map, lib) => {
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
  var isProd = argv.mode === 'production' || env === 'prod' || env && env.prod;
  var mode = isProd ? 'production' : 'development';
  console.log(`Building for ${mode}`);
  var baseConfig = (name, entry, util) => ({
    name,
    mode,
    entry: {
      [name]: entry
    },
    output: {
      library: 'cloudinary',
      libraryTarget: 'umd',
      globalObject: "this",
      filename: `./cloudinary-[name]${isProd ? '.min' : ''}.js`,
      pathinfo: false
    },
    optimization: {
      minimizer: [new TerserPlugin({
        terserOptions :{
          mangle:{
          keep_classnames: true,
            reserved: reserved,
          ie8: true
          },
          concatenateModules: true
        },
      })]
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
      }},
      lodashExternals,
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
    module: {
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
    },
    plugins: [
      new webpack.BannerPlugin({
        banner: `/**
 * cloudinary-[name].js
 * Cloudinary's JavaScript library - Version ${pkg.version}
 * Copyright Cloudinary
 * see https://github.com/cloudinary/cloudinary_js
 *
 */`, // the banner as string or function, it will be wrapped in a comment
        raw: true, // if true, banner will not be wrapped in a comment
        entryOnly: true, // if true, the banner will only be added to the entry chunks
      })
    ]
  });


  return [
    baseConfig("core", './src/namespace/cloudinary-core.js', "lodash"),
    baseConfig("jquery", './src/namespace/cloudinary-jquery.js', "jquery"),
    baseConfig("jquery-file-upload", './src/namespace/cloudinary-jquery-file-upload.js', "jquery"),
    Object.assign(
      baseConfig("core-shrinkwrap", './src/namespace/cloudinary-core.js', "lodash"),
      {
        externals: {
          jquery: 'jQuery'
        }
      }
    )
  ];
};
