({
    baseUrl: ".",
    paths: {
        lodash: 'empty:'
    },
    map: {
        "*": {util: 'util-lodash'}
    },
    skipDirOptimize: true,
    optimize: "none",
    name: "cloudinary-main",
    out: "../dist/cloudinary.js"
})
