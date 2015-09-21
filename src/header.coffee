`/*
 * Cloudinary's Javascript library - v1.0.24
 * Copyright Cloudinary
 * see https://github.com/cloudinary/cloudinary_js
 */

(function (factory) {
    'use strict';
    if (typeof define === 'function' && define.amd) {
        // Register as an anonymous AMD module:
        define([
            'lodash'
        ], factory);
    } else {
        // Browser globals:
        window.cloudinary = {};
        factory(_, cloudinary);
    }
}(function (_, cloudinary) {
var cloudinary = cloudinary;
`