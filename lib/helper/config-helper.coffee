fs = require 'fs-plus'
cson = require 'season'
path = require 'path'
_ = require 'lodash'

module.exports = ConfigHelper =
  configFileName: '.sync-config.cson'

  initialise: (f) ->
    config = @getConfigPath f
    if not fs.isFileSync config
      csonSample = cson.stringify @sample
      fs.writeFileSync config, csonSample
    atom.workspace.open config

  load: (f) ->
    config = @getConfigPath f
    return if not config or not fs.isFileSync config
    cson.readFileSync config

  loadReal: (f) ->
    config = @load f
    if config
      config.filename = f
    else
      for fRealPath in atom.project.getPaths() 
        if (f.indexOf fRealPath) is -1
          try config = cson.readFileSync fRealPath + '/' + @configFileName
          catch e then config = false
          if config and (f.indexOf config?.option?.localRoot) isnt -1
            config.filename = fRealPath + f.substr config.option.localRoot.length
    config
    if (config?)
      config = false

  assert: (f) ->
    config = @load f
    if not config then throw new Error "You must create remote config first"
    config

  isExcluded: (str, exclude) ->
    for pattern in exclude
      return true if (str.indexOf pattern) isnt -1
    return false

  getRelativePath: (f) ->
     path.relative (@getRootPath f), f

  getRootPath: (f) ->
    _.find atom.project.getPaths(), (x) -> (f.indexOf x) isnt -1

  getConfigPath: (f) ->
    base = @getRootPath f
    return if not base
    path.join base, @configFileName

  sample:
    remote:
      host: "HOSTNAME"
      user: "USERNAME"
      path: "REMOTE_DIR"
    behaviour:
      uploadOnSave: true
      syncDownOnOpen: true
      forgetConsole: false
      autoHideConsole: true
      alwaysSyncAll: false
    option:
      localRoot: ""
      deleteFiles: false
      exclude: [
        '.sync-config.cson'
        '.git'
        'node_modules'
        'tmp'
        'vendor'
      ]
