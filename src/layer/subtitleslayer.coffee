import TextLayer from './textlayer'
export default class SubtitlesLayer extends TextLayer
  ###*
   * Represent a subtitles layer
   * @constructor SubtitlesLayer
   * @param {Object} options - layer parameters
  ###
  constructor: (options)->
    super(options)
    @options.resourceType = "subtitles"
