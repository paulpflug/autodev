http = require("http")
chokidar = require("chokidar")
uncache = require("recursive-uncache")
path = require("path")

module.exports = (program) =>
  return unless program.args?[0]?
  if path.extname(program.args[0]) == ".coffee"
    try
      require "coffeescript/register"
    catch
      try
        require "coffee-script/register"
  entry = path.resolve(program.args[0])
  server = null
  close = null
  watcher = null
  busy = false
  unwatchedModules = []
  for k,v of require.cache
    unwatchedModules.push k
  connections = []
  startup = (isRestart) =>
    console.log "autodev: " + if isRestart then "restart" else "startup"
    server = http.createServer()
    server.on "connection", (con) ->
      connections.push con
    try
      close = require(entry)(server,isRestart)
    catch e
      return console.log e
    filesToWatch = []
    for k,v of require.cache
      if unwatchedModules.indexOf(k) < 0
        filesToWatch.push k
    unless watcher?
      watcher = chokidar.watch filesToWatch, ignoreInitial: true
      .on "all", (e,filepath) =>
        return if busy
        uncache(filepath,__filename)
        restart()
    else
      watcher.add filesToWatch
    busy = false
  startup(false)
  restart = =>
    return if busy
    busy = true
    close?()
    close = null
    if server
      server.once "close", startup.bind(null, true)
      server.close()
      server = null
      for con in connections
        con?.destroy?()
      connections = []
    else
      startup(true)