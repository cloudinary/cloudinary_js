(function() {
  var ArrayParam, CloudinaryConfiguration, Param, RangeParam, RawParam, Transformation, TransformationBase, TransformationParam, cloudinary_config, config, crc32, default_transformation_params, filtered_transformation_params, number_pattern, offset_any_pattern, process_video_params, utf8_encode,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  crc32 = function(str) {
    var crc, i, iTop, table, x, y;
    str = utf8_encode(str);
    table = '00000000 77073096 EE0E612C 990951BA 076DC419 706AF48F E963A535 9E6495A3 0EDB8832 79DCB8A4 E0D5E91E 97D2D988 09B64C2B 7EB17CBD E7B82D07 90BF1D91 1DB71064 6AB020F2 F3B97148 84BE41DE 1ADAD47D 6DDDE4EB F4D4B551 83D385C7 136C9856 646BA8C0 FD62F97A 8A65C9EC 14015C4F 63066CD9 FA0F3D63 8D080DF5 3B6E20C8 4C69105E D56041E4 A2677172 3C03E4D1 4B04D447 D20D85FD A50AB56B 35B5A8FA 42B2986C DBBBC9D6 ACBCF940 32D86CE3 45DF5C75 DCD60DCF ABD13D59 26D930AC 51DE003A C8D75180 BFD06116 21B4F4B5 56B3C423 CFBA9599 B8BDA50F 2802B89E 5F058808 C60CD9B2 B10BE924 2F6F7C87 58684C11 C1611DAB B6662D3D 76DC4190 01DB7106 98D220BC EFD5102A 71B18589 06B6B51F 9FBFE4A5 E8B8D433 7807C9A2 0F00F934 9609A88E E10E9818 7F6A0DBB 086D3D2D 91646C97 E6635C01 6B6B51F4 1C6C6162 856530D8 F262004E 6C0695ED 1B01A57B 8208F4C1 F50FC457 65B0D9C6 12B7E950 8BBEB8EA FCB9887C 62DD1DDF 15DA2D49 8CD37CF3 FBD44C65 4DB26158 3AB551CE A3BC0074 D4BB30E2 4ADFA541 3DD895D7 A4D1C46D D3D6F4FB 4369E96A 346ED9FC AD678846 DA60B8D0 44042D73 33031DE5 AA0A4C5F DD0D7CC9 5005713C 270241AA BE0B1010 C90C2086 5768B525 206F85B3 B966D409 CE61E49F 5EDEF90E 29D9C998 B0D09822 C7D7A8B4 59B33D17 2EB40D81 B7BD5C3B C0BA6CAD EDB88320 9ABFB3B6 03B6E20C 74B1D29A EAD54739 9DD277AF 04DB2615 73DC1683 E3630B12 94643B84 0D6D6A3E 7A6A5AA8 E40ECF0B 9309FF9D 0A00AE27 7D079EB1 F00F9344 8708A3D2 1E01F268 6906C2FE F762575D 806567CB 196C3671 6E6B06E7 FED41B76 89D32BE0 10DA7A5A 67DD4ACC F9B9DF6F 8EBEEFF9 17B7BE43 60B08ED5 D6D6A3E8 A1D1937E 38D8C2C4 4FDFF252 D1BB67F1 A6BC5767 3FB506DD 48B2364B D80D2BDA AF0A1B4C 36034AF6 41047A60 DF60EFC3 A867DF55 316E8EEF 4669BE79 CB61B38C BC66831A 256FD2A0 5268E236 CC0C7795 BB0B4703 220216B9 5505262F C5BA3BBE B2BD0B28 2BB45A92 5CB36A04 C2D7FFA7 B5D0CF31 2CD99E8B 5BDEAE1D 9B64C2B0 EC63F226 756AA39C 026D930A 9C0906A9 EB0E363F 72076785 05005713 95BF4A82 E2B87A14 7BB12BAE 0CB61B38 92D28E9B E5D5BE0D 7CDCEFB7 0BDBDF21 86D3D2D4 F1D4E242 68DDB3F8 1FDA836E 81BE16CD F6B9265B 6FB077E1 18B74777 88085AE6 FF0F6A70 66063BCA 11010B5C 8F659EFF F862AE69 616BFFD3 166CCF45 A00AE278 D70DD2EE 4E048354 3903B3C2 A7672661 D06016F7 4969474D 3E6E77DB AED16A4A D9D65ADC 40DF0B66 37D83BF0 A9BCAE53 DEBB9EC5 47B2CF7F 30B5FFE9 BDBDF21C CABAC28A 53B39330 24B4A3A6 BAD03605 CDD70693 54DE5729 23D967BF B3667A2E C4614AB8 5D681B02 2A6F2B94 B40BBE37 C30C8EA1 5A05DF1B 2D02EF8D';
    crc = 0;
    x = 0;
    y = 0;
    crc = crc ^ -1;
    i = 0;
    iTop = str.length;
    while (i < iTop) {
      y = (crc ^ str.charCodeAt(i)) & 0xFF;
      x = '0x' + table.substr(y * 9, 8);
      crc = crc >>> 8 ^ x;
      i++;
    }
    crc = crc ^ -1;
    if (crc < 0) {
      crc += 4294967296;
    }
    return crc;
  };

  if (typeof module !== "undefined" && module.exports) {
    exports.crc32 = crc32;
  } else {
    window.crc32 = crc32;
  }

  utf8_encode = function(argString) {
    var c1, enc, end, n, start, string, stringl, utftext;
    if (argString === null || typeof argString === 'undefined') {
      return '';
    }
    string = argString + '';
    utftext = '';
    start = void 0;
    end = void 0;
    stringl = 0;
    start = end = 0;
    stringl = string.length;
    n = 0;
    while (n < stringl) {
      c1 = string.charCodeAt(n);
      enc = null;
      if (c1 < 128) {
        end++;
      } else if (c1 > 127 && c1 < 2048) {
        enc = String.fromCharCode(c1 >> 6 | 192, c1 & 63 | 128);
      } else {
        enc = String.fromCharCode(c1 >> 12 | 224, c1 >> 6 & 63 | 128, c1 & 63 | 128);
      }
      if (enc !== null) {
        if (end > start) {
          utftext += string.slice(start, end);
        }
        utftext += enc;
        start = end = n + 1;
      }
      n++;
    }
    if (end > start) {
      utftext += string.slice(start, stringl);
    }
    return utftext;
  };

  if (typeof module !== "undefined" && module.exports) {
    exports.utf8_encode = utf8_encode;
  } else {
    window.utf8_encode = utf8_encode;
  }

  cloudinary_config = void 0;

  CloudinaryConfiguration = (function() {
    function CloudinaryConfiguration(configuration) {
      this.configuration = configuration;
    }

    CloudinaryConfiguration.prototype.set = function(config, value) {
      if (_.isUndefined(value)) {
        if (_.isPlainObject(config)) {
          this.merge(config);
        }
      } else {
        this.config[config] = value;
      }
      return this;
    };

    CloudinaryConfiguration.prototype.get = function(name) {
      return this.configuration[name];
    };

    CloudinaryConfiguration.prototype.merge = function(config) {
      if (config == null) {
        config = {};
      }
      return _.assign(this.configuration, config);
    };

    CloudinaryConfiguration.prototype.fromDocument = function() {
      var el, j, len, meta_elements;
      meta_elements = typeof document !== "undefined" && document !== null ? document.getElementsByTagName("meta") : void 0;
      if (meta_elements) {
        for (j = 0, len = meta_elements.length; j < len; j++) {
          el = meta_elements[j];
          this.cloudinary_config[el.getAttribute('name').replace('cloudinary_', '')] = el.getAttribute('content');
        }
      }
      return this;
    };

    CloudinaryConfiguration.prototype.fromEnvironment = function() {
      var cloudinary_url, k, ref, ref1, uri, v;
      cloudinary_url = typeof process !== "undefined" && process !== null ? (ref = process.env) != null ? ref.CLOUDINARY_URL : void 0 : void 0;
      if (cloudinary_url != null) {
        uri = require('url').parse(cloudinary_url, true);
        cloudinary_config = {
          cloud_name: uri.host,
          api_key: uri.auth && uri.auth.split(":")[0],
          api_secret: uri.auth && uri.auth.split(":")[1],
          private_cdn: uri.pathname != null,
          secure_distribution: uri.pathname && uri.pathname.substring(1)
        };
        if (uri.query != null) {
          ref1 = uri.query;
          for (k in ref1) {
            v = ref1[k];
            cloudinary_config[k] = v;
          }
        }
      }
      return this;
    };

    CloudinaryConfiguration.prototype.config = function(new_config, new_value) {
      if ((this.configuration == null) || new_config === true) {
        this.fromEnvironment();
        if (!this.configuration) {
          this.fromDocument();
        }
      }
      if (!_.isUndefined(new_value)) {
        this.set(new_config, new_value);
        return this.configuration;
      } else if (_.isString(new_config)) {
        return this.get(new_config);
      } else if (_.isObject(new_config)) {
        this.merge(new_config);
        return this.configuration;
      } else {
        return this.configuration;
      }
    };

    return CloudinaryConfiguration;

  })();

  if (typeof module !== "undefined" && module !== null ? module.exports : void 0) {
    exports.config = config;
  } else {
    window.config = config;
  }

  config = config || function() {
    return {};
  };


  /**
   * Parameters that are filtered out before passing the options to an HTML tag
   */

  filtered_transformation_params = ["angle", "audio_codec", "audio_frequency", "background", "bit_rate", "border", "color", "color_space", "crop", "default_image", "delay", "density", "dpr", "duration", "effect", "end_offset", "fetch_format", "flags", "gravity", "offset", "opacity", "overlay", "page", "prefix", "quality", "radius", "raw_transformation", "responsive_width", "size", "start_offset", "transformation", "underlay", "video_codec", "video_sampling", "x", "y", "zoom"];


  /**
   * Defaults values for parameters.
   *
   * (Previously defined using option_consume() )
   */

  default_transformation_params = {
    responsive_width: config().responsive_width,
    transformation: [],
    dpr: config().dpr,
    type: "upload",
    resource_type: "image",
    cloud_name: config().cloud_name,
    private_cdn: config().private_cdn,
    type: 'upload',
    resource_type: "image",
    cloud_name: config().cloud_name,
    private_cdn: config().private_cdn,
    secure_distribution: config().secure_distribution,
    cname: config().cname,
    cdn_subdomain: config().cdn_subdomain,
    secure_cdn_subdomain: config().secure_cdn_subdomain,
    shorten: config().shorten,
    secure: window.location.protocol === 'https:',
    protocol: config().protocol,
    use_root_path: config().use_root_path,
    source_types: [],
    source_transformation: {},
    fallback_content: ''
  };

  Param = (function() {
    function Param(name1, short, process1) {
      this.name = name1;
      this.short = short;
      this.process = process1 != null ? process1 : _.identity;
      console.log("setting up " + this.name);
    }

    Param.prototype.set = function(value1) {
      this.value = value1;
      console.log("Set " + this.name + "= " + this.value);
      return this;
    };

    Param.prototype.flatten = function() {
      console.log("flatten " + this.value);
      console.dir(this);
      return this.short + "_" + (this.process(this.value));
    };

    Param.norm_range_value = function(value) {
      var modifier, offset;
      offset = String(value).match(new RegExp('^' + offset_any_pattern + '$'));
      if (offset) {
        modifier = offset[5] != null ? 'p' : '';
        value = (offset[1] || offset[4]) + modifier;
      }
      return value;
    };

    Param.norm_color = function(value) {
      return value.replace(/^#/, 'rgb:');
    };

    Param.prototype.build_array = function(arg) {
      if (arg == null) {
        arg = [];
      }
      if (_.isArray(arg)) {
        return arg;
      } else {
        return [arg];
      }
    };

    return Param;

  })();

  ArrayParam = (function(superClass) {
    extend(ArrayParam, superClass);

    function ArrayParam(name1, short, sep1, process1) {
      this.name = name1;
      this.short = short;
      this.sep = sep1 != null ? sep1 : '.';
      this.process = process1 != null ? process1 : _.identity;
      ArrayParam.__super__.constructor.call(this, this.name, this.short, this.process);
    }

    ArrayParam.prototype.flatten = function() {
      var flat, t;
      flat = (function() {
        var j, len, ref, results;
        ref = this.value;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          t = ref[j];
          if (_.isFunction(t.flatten)) {
            results.push(t.flatten());
          } else {
            results.push(t);
          }
        }
        return results;
      }).call(this);
      return this.short + "_" + (flat.join(this.sep));
    };

    ArrayParam.prototype.set = function(value1) {
      this.value = value1;
      return ArrayParam.__super__.set.call(this, _.toArray(this.value));
    };

    return ArrayParam;

  })(Param);

  TransformationParam = (function(superClass) {
    extend(TransformationParam, superClass);

    function TransformationParam(name1, short, sep1, process1) {
      this.name = name1;
      this.short = short != null ? short : "t";
      this.sep = sep1 != null ? sep1 : '.';
      this.process = process1 != null ? process1 : _.identity;
      TransformationParam.__super__.constructor.call(this, this.name, this.short, this.process);
    }

    TransformationParam.prototype.flatten = function() {
      var j, len, ref, results, t;
      if (_.all(this.value, _.isString)) {
        return [this.short + "_" + (this.value.join(this.sep))];
      } else {
        ref = this.value;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          t = ref[j];
          if (_.isString(t) || _.isFunction(t.flatten)) {
            if (_.isString(t)) {
              results.push(this.short + "_" + t);
            } else if (_.isFunction(t.flatten)) {
              results.push(t.flatten());
            } else {
              results.push(void 0);
            }
          }
        }
        return results;
      }
    };

    TransformationParam.prototype.set = function(value1) {
      this.value = value1;
      return TransformationParam.__super__.set.call(this, _.toArray(this.value));
    };

    return TransformationParam;

  })(Param);

  RangeParam = (function(superClass) {
    extend(RangeParam, superClass);

    function RangeParam(name1, short, process1) {
      this.name = name1;
      this.short = short;
      this.process = process1 != null ? process1 : this.norm_range_value;
      RangeParam.__super__.constructor.call(this, this.name, this.short, this.process);
    }

    return RangeParam;

  })(Param);

  RawParam = (function(superClass) {
    extend(RawParam, superClass);

    function RawParam(name1, short, process1) {
      this.name = name1;
      this.short = short;
      this.process = process1 != null ? process1 : _.identity;
      RawParam.__super__.constructor.call(this, this.name, this.short, this.process);
    }

    RawParam.prototype.flatten = function() {
      return this.value;
    };

    return RawParam;

  })(Param);


  /**
   * A video codec parameter can be either a String or a Hash.
   * @param {Object} param <code>vc_<codec>[ : <profile> : [<level>]]</code>
   *                       or <code>{ codec: 'h264', profile: 'basic', level: '3.1' }</code>
   * @return {String} <code><codec> : <profile> : [<level>]]</code> if a Hash was provided
   *                   or the param if a String was provided.
   *                   Returns null if param is not a Hash or String
   */

  process_video_params = function(param) {
    var video;
    switch (param.constructor) {
      case Object:
        video = "";
        if ('codec' in param) {
          video = param['codec'];
          if ('profile' in param) {
            video += ":" + param['profile'];
            if ('level' in param) {
              video += ":" + param['level'];
            }
          }
        }
        return video;
      case String:
        return param;
      default:
        return null;
    }
  };

  number_pattern = "([0-9]*)\\.([0-9]+)|([0-9]+)";

  offset_any_pattern = "(" + number_pattern + ")([%pP])?";

  TransformationBase = (function() {
    TransformationBase.prototype.param = function(value, name, abbr, default_value, process) {
      if (process == null) {
        process = _.identity;
      }
      if (_.isFunction(default_value) && (process == null)) {
        process = default_value;
      }
      console.dir(this);
      console.dir(this.trans);
      return this.trans[name] = new Param(name, abbr, process).set(value);
    };

    TransformationBase.prototype.rawParam = function(value, name, abbr, default_value, process) {
      if (process == null) {
        process = _.identity;
      }
      if (_.isFunction(default_value) && (process == null)) {
        process = default_value;
      }
      return this.trans[name] = new RawParam(name, abbr, process).set(value);
    };

    TransformationBase.prototype.rangeParam = function(value, name, abbr, default_value, process) {
      if (process == null) {
        process = _.identity;
      }
      if (_.isFunction(default_value) && (process == null)) {
        process = default_value;
      }
      return this.trans[name] = new RangeParam(name, abbr, process).set(value);
    };

    TransformationBase.prototype.arrayParam = function(value, name, abbr, sep, default_value, process) {
      if (sep == null) {
        sep = ":";
      }
      if (process == null) {
        process = _.identity;
      }
      if (_.isFunction(default_value) && (process == null)) {
        process = default_value;
      }
      return this.trans[name] = new ArrayParam(name, abbr, sep, process).set(value);
    };

    function TransformationBase(trans) {
      this.trans = trans != null ? trans : {};
      this.trans = {};
      this.whitelist = _.functions(TransformationBase.prototype);
      _.difference(this.whitelist, ["_set", "param", "rawParam", "rangeParam", "arrayParam"]);
      console.log(this.whitelist);
    }

    TransformationBase.prototype.angle = function(value) {
      return this.param(value, "angle", "a");
    };

    TransformationBase.prototype.audio_codec = function(value) {
      return this.param(value, "audio_codec", "ac");
    };

    TransformationBase.prototype.audio_frequency = function(value) {
      return this.param(value, "audio_frequency", "f");
    };

    TransformationBase.prototype.background = function(value) {
      return this.param(value, "background", "b", Param.norm_color);
    };

    TransformationBase.prototype.bit_rate = function(value) {
      return this.param(value, "bit_rate", "r");
    };

    TransformationBase.prototype.border = function(value) {
      return this.param(value, "border", "bo", function(border) {
        if (_.isPlainObject(border)) {
          _.assign({
            color: "black",
            width: 2
          }, border);
          return border.width + "px_solid_" + (Param.norm_color(border.color));
        } else {
          return border;
        }
      });
    };

    TransformationBase.prototype.color = function(value) {
      return this.param(value, "color", "co", Param.norm_color);
    };

    TransformationBase.prototype.color_space = function(value) {
      return this.param(value, "color_space", "s");
    };

    TransformationBase.prototype.crop = function(value) {
      return this.param(value, "crop", "c");
    };

    TransformationBase.prototype.default_image = function(value) {
      return this.param(value, "default_image", "d");
    };

    TransformationBase.prototype.delay = function(value) {
      return this.param(value, "delay", "l");
    };

    TransformationBase.prototype.density = function(value) {
      return this.param(value, "density", "n");
    };

    TransformationBase.prototype.duration = function(value) {
      return this.rangeParam(value, "duration", "du");
    };

    TransformationBase.prototype.dpr = function(value) {
      return this.param(value, "dpr", "dpr", function(dpr) {
        if (dpr === "auto") {
          return "1.0";
        } else if (dpr != null ? dpr.match(/^d+$/) : void 0) {
          return dpr + ".0";
        } else {
          return dpr;
        }
      });
    };

    TransformationBase.prototype.effect = function(value) {
      return this.arrayParam(value, "effect", "e", ":");
    };

    TransformationBase.prototype.end_offset = function(value) {
      return this.rangeParam(value, "end_offset", "eo");
    };

    TransformationBase.prototype.fetch_format = function(value) {
      return this.param(value, "fetch_format", "f");
    };

    TransformationBase.prototype.flags = function(value) {
      return this.arrayParam(value, "flags", "fl", ".");
    };

    TransformationBase.prototype.gravity = function(value) {
      return this.param(value, "gravity", "g");
    };

    TransformationBase.prototype.height = function(value) {
      return this.param(value, "height", "h");
    };

    TransformationBase.prototype.html_height = function(value) {
      return this.param(value, "html_height");
    };

    TransformationBase.prototype.html_width = function(value) {
      return this.param(value, "html_width");
    };

    TransformationBase.prototype.offset = function(value) {
      var end_o, ref, start_o;
      ref = _.isFunction(value != null ? value.split : void 0) ? value.split('..') : _.isArray(value) ? value : [null, null], start_o = ref[0], end_o = ref[1];
      if (start_o != null) {
        this.start_offset(start_o);
      }
      if (end_o != null) {
        return this.end_offset(end_o);
      }
    };

    TransformationBase.prototype.opacity = function(value) {
      return this.param(value, "opacity", "o");
    };

    TransformationBase.prototype.overlay = function(value) {
      return this.param(value, "overlay", "l");
    };

    TransformationBase.prototype.page = function(value) {
      return this.param(value, "page", "g");
    };

    TransformationBase.prototype.prefix = function(value) {
      return this.param(value, "prefix", "p");
    };

    TransformationBase.prototype.quality = function(value) {
      return this.param(value, "quality", "q");
    };

    TransformationBase.prototype.radius = function(value) {
      return this.param(value, "radius", "r");
    };

    TransformationBase.prototype.raw_transformation = function(value) {
      return this.rawParam(value, "raw_transformation");
    };

    TransformationBase.prototype.size = function(value) {
      var height, ref, width;
      if (_.isFunction(value != null ? value.split : void 0)) {
        ref = value.split('x'), width = ref[0], height = ref[1];
        this.width(width);
        return this.height(height);
      }
    };

    TransformationBase.prototype.start_offset = function(value) {
      return this.rangeParam(value, "start_offset", "so");
    };

    TransformationBase.prototype.transformation = function(value) {
      return this.arrayParam(value, "transformation", "t", ".", function(transformation_array) {
        var j, len, results, t;
        results = [];
        for (j = 0, len = transformation_array.length; j < len; j++) {
          t = transformation_array[j];
          if (_.isString(t)) {
            results.push(t);
          } else {
            results.push(new Transformation(t));
          }
        }
        return results;
      });
    };

    TransformationBase.prototype.underlay = function(value) {
      return this.param(value, "underlay", "u");
    };

    TransformationBase.prototype.video_codec = function(value) {
      return this.param(value, "video_codec", "vc", process_video_params);
    };

    TransformationBase.prototype.video_sampling = function(value) {
      return this.param(value, "video_sampling", "s");
    };

    TransformationBase.prototype.width = function(value) {
      return this.param(value, "width", "w");
    };

    TransformationBase.prototype.x = function(value) {
      return this.param(value, "x", "x");
    };

    TransformationBase.prototype.y = function(value) {
      return this.param(value, "y", "y");
    };

    TransformationBase.prototype.zoom = function(value) {
      return this.param(value, "zoom", "z");
    };

    return TransformationBase;

  })();


  /**
   *  A single transformation.
   *
   *  Usage:
   *
   *      t = new Transformation();
   *      t.angle(20).crop("scale").width("auto");
   *
   *  or
   *      t = new Transformation( {angle: 20, crop: "scale", width: "auto"});
   */

  Transformation = (function(superClass) {
    extend(Transformation, superClass);

    function Transformation(options) {
      if (options == null) {
        options = {};
      }
      Transformation.__super__.constructor.call(this);
      this.fromOptions(options);
    }

    Transformation.prototype.fromOptions = function(options) {
      var j, k, len, ref;
      if (options == null) {
        options = {};
      }
      if (_.isString(options) || _.isArray(options)) {
        options = {
          transformation: options
        };
      }
      console.dir(_.intersection(options, this.whitelist));
      ref = _.intersection(_.keys(options), this.whitelist);
      for (j = 0, len = ref.length; j < len; j++) {
        k = ref[j];
        console.log("setting " + k + " to " + options[k]);
        this[k](options[k]);
      }
      return this;
    };

    Transformation.prototype.getValue = function(name) {
      var ref;
      return (ref = this.trans[name]) != null ? ref.value : void 0;
    };

    Transformation.prototype.get = function(name) {
      return this.trans[name];
    };

    Transformation.prototype.remove = function(name) {
      var temp;
      temp = this.trans[name];
      delete this.trans[name];
      return temp;
    };

    Transformation.prototype.flatten = function() {
      var param_list, result_array, t, transformation_string, transformations, width;
      param_list = this.trans.sort();
      result_array = [];
      console.log("filtered_transformation_params");
      console.log(filtered_transformation_params);
      transformations = remove("transformation");
      if (transformations) {
        result_array.concat(transformations.flatten());
      }
      if (!_.any([this.getValue("overlay"), this.getValue("underlay"), _.contains(["fit", "limit", "lfill"], this["crop"])])) {
        width = this.getValue("width");
        if (width && width !== "auto" && parseFloat(width) >= 1.0) {
          if (!this.get("html_width")) {
            html_width(width);
          }
        }
        if (this.get("height") && parseFloat(this.getValue("height")) >= 1.0) {
          if (!this.get("html_height")) {
            html_height(height);
          }
        }
      }
      if (!_.any([this.getValue("crop"), this.getValue("overlay"), this.getValue("underlay")])) {
        _.pull(param_list, "width", "height");
      }
      transformation_string = ((function() {
        var results;
        results = [];
        for (t in param_list) {
          results.push(this.get(t).flatten());
        }
        return results;
      }).call(this)).join(',');
      if (!_.isEmpty(transformation_string)) {
        result_array.push(transformation_string);
      }
      return result_array.join('/');
    };

    Transformation.prototype.listNames = function() {
      return this.whitelist;
    };

    Transformation.prototype.isValidParamName = function(name) {
      return this.whitelist.indexOf(name) >= 0;
    };

    return Transformation;

  })(TransformationBase);

  if (typeof module !== "undefined" && module !== null ? module.exports : void 0) {
    exports.Transformation = Transformation;
  } else {
    window.Transformation = Transformation;
  }

}).call(this);
