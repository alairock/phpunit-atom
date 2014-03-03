{BufferedProcess} = require 'atom'

module.exports =
    configDefaults:
        phpunitExecutablePath: '/usr/local/bin/phpunit'

    activate: ->
      atom.workspaceView.command "phpunit:test", => @check()

    check: ->
        projectPath = atom.project.getPath()
        command = atom.config.get "phpunit.phpunitExecutablePath"
        args = ['--configuration', projectPath]
        stdout = (output) -> console.log(output)
        exit = (code) -> console.log("unit test exited with #{code}")
        try
            process = new BufferedProcess({command, args, stdout, exit})
        catch error
          console.log error
