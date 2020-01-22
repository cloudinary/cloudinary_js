for pkg in core jquery jquery-file-upload; do karma start --single-run --cloudinary.minified --cloudinary.pkg=${pkg}; done
