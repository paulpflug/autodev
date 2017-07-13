#!/usr/bin/env node
var program = require('commander'),
  fs = require('fs'),
  path = require('path')
program
  .version(JSON.parse(fs.readFileSync(path.join(__dirname, 'package.json'), 'utf8')).version)
  .usage('<file>')
  .parse(process.argv);

require("./autodev.js")(program)