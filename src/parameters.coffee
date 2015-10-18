((root, factory) ->
  if (typeof define == 'function') && define.amd
    define ['util', 'transformation', 'require'], factory
  else if typeof exports == 'object'
    module.exports = factory(require('util'), require('transformation'), require)
  else
    root.cloudinary ||= {}
    root.cloudinary.parameters = factory(root.cloudinary.Util, root.cloudinary.Transformation, ()-> cloudinary.Transformation)


#/**
# * @license
# * lodash 3.10.0 (Custom Build) <https://lodash.com/>
#* Build: `lodash modern -o ./lodash.js`
#* Copyright 2012-2015 The Dojo Foundation <http://dojofoundation.org/>
#* Based on Underscore.js 1.8.3 <http://underscorejs.org/LICENSE>
#* Copyright 2009-2015 Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors
#* Available under MIT license <https://lodash.com/license>
#*/
)(this,  (Util, Transformation, require)->
  class Param
    ###*
     * Represents a single parameter
     * @class Param
     * @param {string} name - The name of the parameter in snake_case
     * @param {string} short - The name of the serialized form of the parameter.
     *                         If a value is not provided, the parameter will not be serialized.
     * @param {function} [process=Util.identity ] - Manipulate origValue when value is called
     * @ignore
    ###
    constructor: (name, short, process = Util.identity)->
      ###*
       * The name of the parameter in snake_case
       * @member {string} Param#name
      ###
      @name = name
      ###*
       * The name of the serialized form of the parameter
       * @member {string} Param#short
      ###
      @short = short
      ###*
       * Manipulate origValue when value is called
       * @member {function} Param#process
      ###
      @process = process

    ###*
     * Set a (unprocessed) value for this parameter
     * @function Param#set
     * @param {*} origValue - the value of the parameter
     * @return {Param} self for chaining
    ###
    set: (@origValue)->
      this

    ###*
     * Generate the serialized form of the parameter
     * @function Param#serialize
     * @return {string} the serialized form of the parameter
    ###
    serialize: ->
      val = @value()
      valid = if Util.isArray(val) || Util.isPlainObject(val) || Util.isString(val)
          !Util.isEmpty(val)
        else
          val?
      if @short? && valid
        "#{@short}_#{val}"
      else
        ''

    ###*
     * Return the processed value of the parameter
     * @function Param#value
    ###
    value: ->
      @process(@origValue)

    @norm_color: (value) -> value?.replace(/^#/, 'rgb:')

    build_array: (arg = []) ->
      if Util.isArray(arg)
        arg
      else
        [arg]
    ###*
    * Covert value to video codec string.
    *
    * If the parameter is an object,
    * @param {(string|Object)} param - the video codec as either a String or a Hash
    * @return {string} the video codec string in the format codec:profile:level
    * @example
    * vc_[ :profile : [level]]
    * or
      { codec: 'h264', profile: 'basic', level: '3.1' }
    * @ignore
    ###
    @process_video_params = (param) ->
      switch param.constructor
        when Object
          video = ""
          if 'codec' of param
            video = param['codec']
            if 'profile' of param
              video += ":" + param['profile']
              if 'level' of param
                video += ":" + param['level']
          video
        when String
          param
        else
          null

  class ArrayParam extends Param
    ###*
     * A parameter that represents an array
     * @param {string} name - The name of the parameter in snake_case
     * @param {string} short - The name of the serialized form of the parameter
     *                         If a value is not provided, the parameter will not be serialized.
     * @param {string} [sep='.'] - The separator to use when joining the array elements together
     * @param {function} [process=Util.identity ] - Manipulate origValue when value is called
     * @class ArrayParam
     * @ignore
    ###
    constructor: (name, short, sep = '.', process) ->
      @sep = sep
      super(name, short, process)

    serialize: ->
      if @short?
        array = @value()
        if Util.isEmpty(array)
          ''
        else
          flat = for t in @value()
            if Util.isFunction( t.serialize)
              t.serialize() # Param or Transformation
            else
              t
          "#{@short}_#{flat.join(@sep)}"
      else
        ''

    set: (origValue)->
      if !origValue? || Util.isArray(origValue)
        super(origValue)
      else
        super([origValue])

  class TransformationParam extends Param
    ###*
     * A parameter that represents a transformation
     * @param {string} name - The name of the parameter in snake_case
     * @param {string} [short='t'] - The name of the serialized form of the parameter
     * @param {string} [sep='.'] - The separator to use when joining the array elements together
     * @param {function} [process=Util.identity ] - Manipulate origValue when value is called
     * @class TransformationParam
     * @ignore
    ###
    constructor: (name, short = "t", sep = '.', process) ->
      @sep = sep
      super(name, short, process)

    serialize: ->
      if Util.isEmpty(@value())
        ''
      else if Util.allStrings(@value())
        joined = @value().join(@sep)
        if !Util.isEmpty(joined)
          "#{@short}_#{joined}"
        else
          ''
      else
        result = for t in @value() when t?
          if Util.isString( t) && !Util.isEmpty(t)
            "#{@short}_#{t}"
          else if Util.isFunction( t.serialize)
            t.serialize()
          else if Util.isPlainObject(t) && !Util.isEmpty(t)
            Transformation ||= require('transformation')
            new Transformation(t).serialize()
        Util.compact(result)

    set: (@origValue)->
      if Util.isArray(@origValue)
        super(@origValue)
      else
        super([@origValue])

  class RangeParam extends Param
    ###*
     * A parameter that represents a range
     * @param {string} name - The name of the parameter in snake_case
     * @param {string} short - The name of the serialized form of the parameter
     *                         If a value is not provided, the parameter will not be serialized.
     * @param {string} [sep='.'] - The separator to use when joining the array elements together
     * @param {function} [process=norm_range_value ] - Manipulate origValue when value is called
     * @class RangeParam
     * @ignore
    ###
    constructor: (name, short, process = @norm_range_value)->
      super(name, short, process)

    @norm_range_value: (value) ->
      offset = String(value).match(new RegExp('^' + offset_any_pattern + '$'))
      if offset
        modifier = if offset[5]? then 'p' else ''
        value = (offset[1] or offset[4]) + modifier
      value

  class RawParam extends Param
    constructor: (name, short, process = Util.identity)->
      super(name, short, process)
    serialize: ->
      @value()



  parameters = {}
  parameters.Param = Param
  parameters.ArrayParam = ArrayParam
  parameters.RangeParam = RangeParam
  parameters.RawParam = RawParam
  parameters.TransformationParam = TransformationParam
  parameters
)