{BufferedProcess} = require 'atom'

module.exports =
    activate: ->
      atom.workspaceView.command "phpunit:test", => @check()

    check: ->
        projectPath = atom.project.getPath()
        command = '/usr/local/bin/phpunit'
        args = ['--configuration', projectPath]
        stdout = (output) -> console.log(output)
        exit = (code) -> console.log("unit test exited with #{code}")
        try
            process = new BufferedProcess({command, args, stdout, exit})
        catch error
          console.log error
