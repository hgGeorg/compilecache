fs = require 'fs'
path = require 'path'

class CompileCache
    constructor: (@rootPath, @watchType, @compile) ->
        @memcache = {}
        memcache = @memcache
        rootPath = @rootPath
        # caveat: as of current date recursive only work on OSX version of node
        # https://nodejs.org/api/fs.html#fs_fs_watch_filename_options_listener
        fs.watch @rootPath, { persistent: true, recursive: true }, (event, filename) ->
            if filename?
                if memcache[filename]?
                    delete memcache[filename]
            else
                await fs.readdir rootPath, defer err, files
                filesToDelete = []
                filesToDelete.push file for file of memcache when file not in files
                delete memcache[file] for file in filesToDelete

    get: (filename, callback) ->
        watchedFile = filename.substr(0, filename.lastIndexOf('.')) + @watchType
        unless @memcache[watchedFile]?
            @memcache[watchedFile] = {}
            await fs.readFile path.join(@rootPath, watchedFile), { encoding: 'utf-8' }, defer err, fileContent
            unless err?
                await @compile fileContent, defer compileErr, compiledContent
                @memcache[watchedFile].err = compileErr
                @memcache[watchedFile].content = compiledContent
            else
                @memcache[watchedFile].err = err
                @memcache[watchedFile].content = null
        callback @memcache[watchedFile].err, @memcache[watchedFile].content

module.exports = CompileCache
