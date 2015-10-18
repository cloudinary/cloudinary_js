({
    //appDir: "..",
    baseUrl: ".",
    //dir: "../dist",
    paths: {
        jquery: 'empty:'
    },
    map: {
        "*": {util: 'util-jquery'}
    },
    skipDirOptimize: true,
    optimize: "none",
    name: "jquery-extension",
    out: "../dist/jquery.noupload.cloudinary.js"
})
