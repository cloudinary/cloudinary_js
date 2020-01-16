for pkg in core jquery jquery-file-upload; do node_modules/.bin/karma start --single-run --cloudinary.minified --cloudinary.pkg=${pkg}; done
