var cloudinary = require('cloudinary-core');
var tag = cloudinary.ImageTag.new("sample", {cloud_name: "demo", width: 300});
document.body.appendChild(tag.toDOM());
document.body.appendChild(
    tag.transformation()
        .angle(15)
        .width(200)
        .crop("scale")
        .effect("grayscale")
        .getParent().toDOM()
);
