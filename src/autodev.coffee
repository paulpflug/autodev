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

  connections = []
  startup = (isRestart) =>
    console.log "\x1b[36mautodev: " + (if isRestart then "starting up again" else "starting up") + "\x1b[0m"
    server = http.createServer()
    server.on "connection", (con) => connections.push con
    try
      start = await require(entry)
    catch e
      console.error e
    filesToWatch = []
    unless isRestart
      for k,v of require.cache
        unwatchedModules.push k
      filesToWatch.push entry
    if typeof start == "function"
      try
        close = await start(server,isRestart)
      catch e
        console.error e
      for k,v of require.cache
        filesToWatch.push k unless ~unwatchedModules.indexOf(k)
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
    console.log "autodev: tearing down\n"
    promise = new Promise (resolve) =>
      try
        await close?()
      catch e
        console.error e
      close = null
      resolve()
    if server
      server.once "close", => 
        await promise
        startup(true)
      server.close()
      server = null
      for con in connections
        con?.destroy?()
      connections = []
    else
      await promise
      return startup(true)