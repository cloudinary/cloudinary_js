`/*
 * Cloudinary's jQuery library - v1.0.24
 * Copyright Cloudinary
 * see https://github.com/cloudinary/cloudinary_js
 */

(function (factory) {
    'use strict';
    if (typeof define === 'function' && define.amd) {
        // Register as an anonymous AMD module:
        define([
            'lodash',
            'jquery',
            'tmpl',
            'load-image',
            'canvas'
        ], factory);
    } else {
        // Browser globals:
        window.cloudinary = {};
        factory(_, jQuery, cloudinary);
    }
}(function (_, jQuery, cloudinary) {
var cloudinary = cloudinary;
`
#  FIXME add fileupload dependency