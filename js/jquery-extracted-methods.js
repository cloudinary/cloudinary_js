/**
 * This file includes methods that have been extracted from jQuery in order to decouple
 * the Cloudinary JS client library from the main jQuery library.
 * It is designed to be a drop-in replacement for the full jQuery library and thus utilizes the same namespace.
 */

(function( window, undefined ) {

if ( jQuery !== undefined ) {
  return;
}
  var _$ = window.$,


  // Define a local copy of jQuery
  jQuery = function( selector, context ) {
    // The jQuery object is actually just the init constructor 'enhanced'
    return new jQuery.fn.init( selector, context, rootjQuery );
  };

  jQuery.fn = jQuery.prototype = {
    // The current version of jQuery being used
    jquery: core_version,

    constructor: jQuery,
    init: function (selector, context, rootjQuery) {
      return this;
    }
  };

      $.Widget = function( /* options, element */ ) {};
  $.Widget._childConstructors = [];

  $.Widget.prototype = {
    widget: function () {
      return this.element;
    }
  };

  extend = function() {
    var options, name, src, copy, copyIsArray, clone,
        target = arguments[0] || {},
        i = 1,
        length = arguments.length,
        deep = false;


    // Handle case when target is a string or something (possible in deep copy)
    if ( typeof target !== "object" && !jQuery.isFunction(target) ) {
      target = {};
    }

    // extend jQuery itself if only one argument is passed
    if ( length === i ) {
      target = this;
      --i;
    }

    for ( ; i < length; i++ ) {
      // Only deal with non-null/undefined values
      if ( (options = arguments[ i ]) != null ) {
        // Extend the base object
        for ( name in options ) {
          src = target[ name ];
          copy = options[ name ];

          // Prevent never-ending loop
          if ( target === copy ) {
            continue;
          }

          // Recurse if we're merging plain objects or arrays
          if ( deep && copy && ( jQuery.isPlainObject(copy) || (copyIsArray = jQuery.isArray(copy)) ) ) {
            if ( copyIsArray ) {
              copyIsArray = false;
              clone = src && jQuery.isArray(src) ? src : [];

            } else {
              clone = src && jQuery.isPlainObject(src) ? src : {};
            }

            // Never move original objects, clone them
            target[ name ] = jQuery.extend( deep, clone, copy );

            // Don't bring in undefined values
          } else if ( copy !== undefined ) {
            target[ name ] = copy;
          }
        }
      }
    }

    // Return the modified object
    return target;
  };



// })();
if ( typeof module === "object" && typeof module.exports === "object" ) {
  // Expose jQuery as module.exports in loaders that implement the Node
  // module pattern (including browserify). Do not create the global, since
  // the user will be storing it themselves locally, and globals are frowned
  // upon in the Node module world.
  module.exports = jQuery;
} else {
  // Register as a named AMD module, since jQuery can be concatenated with other
  // files that may use define, but not via a proper concatenation script that
  // understands anonymous AMD modules. A named AMD is safest and most robust
  // way to register. Lowercase jquery is used because AMD module names are
  // derived from file names, and jQuery is normally delivered in a lowercase
  // file name. Do this after creating the global so that if an AMD module wants
  // to call noConflict to hide this version of jQuery, it will work.
  if ( typeof define === "function" && define.amd ) {
    define( "jquery", [], function () { return jQuery; } );
  }
}

// If there is a window object, that at least has a document property,
// define jQuery and $ identifiers
if ( typeof window === "object" && typeof window.document === "object" ) {
  window.jQuery = window.$ = jQuery;
}

})( window );
