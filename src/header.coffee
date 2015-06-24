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
            'jquery',
            'jquery.ui.widget',
            'jquery.iframe-transport',
            'jquery.fileupload'
        ], factory);
    } else {
        // Browser globals:
        var $ = window.jQuery;
        factory($);
        $(function() {
            if($.fn.cloudinary_fileupload !== undefined) {
                $("input.cloudinary-fileupload[type=file]").cloudinary_fileupload();
            }
        });
    }
}(function ($) {
`