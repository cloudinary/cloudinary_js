for pkg in core jquery jquery-file-upload; do karma start --single-run --browsers=ChromeHeadless --cloudinary.pkg=${pkg}; done
