const presets = [
    [
      "@babel/preset-env",
      {
        "targets": {
          "ie": "11"
        }
      }
    ]
];
const plugins = ["@babel/plugin-proposal-object-rest-spread"];

module.exports = {presets, plugins};
