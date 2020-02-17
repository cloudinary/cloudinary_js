const presets = [
    [
      "@babel/preset-env", {modules: false}
    ]
];
const plugins = ["@babel/plugin-proposal-object-rest-spread"];

module.exports = {presets, plugins};
