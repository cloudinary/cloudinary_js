const path = require('path');
const TerserPlugin = require('terser-webpack-plugin');
const webpack = require('webpack');
const fs = require('fs');
const version = require('./package.json').version;
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

// Create a list of Class names to preserve when minifying
const namespace = fs.readFileSync('./src/namespace/cloudinary-jquery-file-upload.js').toString();
const reserved = namespace.match(/(\w+)(?= from)/g);

/**
 * Determine the build mode.
 * @param {object} env - webpack environment
 * @param {boolean} [env.production] - when true, set mode to production
 * @param {boolean} [env.development] - when true, set mode to development
 * @param {object} argv - webpack options
 * @param {string} [argv.mode] - the build mode
 */
function getMode(env, argv) {
  // When running from parallel-webpack, grab the cli parameters
  argv = Object.keys(argv).length ? argv : require('minimist')(process.argv.slice(2));
  var isProd = (argv.mode || env.mode) === 'production' || env === 'prod' || env.prod;
  return isProd ? 'production' : 'development';
}

/**
 * This function is used by webpack to resolve individual lodash modules
 * @param context
 * @param request
 * @param callback
 */
function resolveLodash(context, request, callback) {
  if (/^lodash\//.test(request)) {
    callback(null, {
      commonjs: request,
      commonjs2: request,
      amd: request,
      root: ['_', request.split('/')[1]]
    });
  } else {
    callback();
  }
}


/**
 * Generate a webpack configuration
 * @param {string} name the name of the package
 * @param {string} mode either development or production
 * @return {object} webpack configuration
 */
function baseConfig(name, mode) {
  const config = {
    name: `${name}-${mode}`,
    mode,
    output: {
      library: 'cloudinary',
      libraryTarget: 'umd',
      globalObject: "this",
      pathinfo: false
    },
    optimization: {
      concatenateModules: true,
      moduleIds: 'named',
      usedExports: true,
      minimizer: [new TerserPlugin({
        terserOptions: {
          mangle: {
            keep_classnames: true,
            reserved: reserved,
            ie8: true
          }
        },
      })]
    },
    resolve: {
      extensions: ['.js']
    },
    externals: [
      {
        jquery: 'jQuery'
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
          use: {loader: 'babel-loader'}
        }
      ]
    },
    plugins: [
      new webpack.BannerPlugin({
        banner: `/**
   * cloudinary-[name].js
   * Cloudinary's JavaScript library - Version ${version}
   * Copyright Cloudinary
   * see https://github.com/cloudinary/cloudinary_js
   *
   */`, // the banner as string or function, it will be wrapped in a comment
        raw: true, // if true, banner will not be wrapped in a comment
        entryOnly: true, // if true, the banner will only be added to the entry chunks
      })
    ]
  };

  let filename = `cloudinary-${name}`;
  if(mode === 'production') { filename += '.min';}

  const util = name.startsWith('jquery') ? 'jquery' : 'lodash';
  const utilPath = path.resolve(__dirname, `src/util/${util}`);

  config.output.filename = `./${filename}.js`;
  config.entry = `./src/namespace/cloudinary-${name}.js`;
  config.resolve.alias = {
    "../util$": utilPath,
    "./util$": utilPath
  };
  // Add reference to each lodash function as a separate module.
  if (name === 'core') {
    config.externals.push(resolveLodash);
  }
  config.plugins.push(
    new BundleAnalyzerPlugin({
      analyzerMode: 'static',
      reportFilename: `./${filename}-visualizer.html`,
      openAnalyzer: false
    })
  );
  return config;
}

const names = [
  "core",
  "jquery",
  "jquery-file-upload",
  "core-shrinkwrap"
];
const modes = [
  'production',
  'development'
];

module.exports = names.reduce(
  (configs, name)=> configs.concat(
    modes.map(mode=> baseConfig(name, mode))
  ), []
);
