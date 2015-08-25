# Compile Cache

### Usage:
Assumption:
* Source files are in `./src`.
* Source file extension is `.iced`.
* Client requests `.js` files.

```
var express = require('express');
var CompileCache = require('compilecache');
var ics = require('iced-coffee-script');

var compileCache = new CompileCache('./src', '.iced', function(fileContent, callback) {
  try {
    compiledContent = ics.compile(fileContent);
    callback(null, compiledContent);
  } catch (err) {
    callback(err, null);
  }
});

var app = express();

app.get('/js/:filename', function(req, res, next) {
  compileCache.get(req.params.filename, function(err, compiledContent) {
    if (err) return next();
      res.type('js');
      res.end(compiledContent);
  });
});

```
### Caveats
compilecache uses [Node fs.watch](https://nodejs.org/api/fs.html#fs_fs_watch_filename_options_listener) and therefor is unable to recursively watch directories.
