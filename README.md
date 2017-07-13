# autodev

if you need a quick server for development, autodev is your friend.

It watches all dependencies and restarts the server on changes.

### Install

```sh
npm install --save-dev autodev
```

### Usage

```js
// devserver.js
// requires outside won't get watched
Koa = require("koa") // koa
express = require("express") // express
module.exports = (server, isRestart) =>
  // requires inside will get watched
  yourapp = require("./yourapp")
  // your startup code
  // koa
  app = new Koa()
  server.on("request",app.callback())
  // express
  app = express()
  server.on("request",app)
  
  // startup server
  server.listen(8080)
  return () =>
    // your teardown code
```

```sh
# call on terminal:
autodev devserver.js
```
## License
Copyright (c) 2017 Paul Pflugradt
Licensed under the MIT license.
