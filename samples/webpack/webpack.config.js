var path;

path = require('path');

module.exports = {
    entry: ['./index'],
    output: {
        filename: "bundle.js",
        path: "."
    },
    resolveLoader: {
        modulesDirectories: [
            path.resolve('.')
        ]
    },
};
