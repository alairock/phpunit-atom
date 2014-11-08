{spawn} = require 'child_process'

PHPUnitView = require './test-status-view'

module.exports =
    config:
        execPath:
            title: 'phpUnit Executable Path'
            type: 'string'
            default: '/usr/local/bin/phpunit'
        execOptions:
            title: 'phpUnit Command Line Options'
            type: 'string'
            default: ''
        runOnSave:
            title: 'Run on Save'
            type: 'boolean'
            default: false

    activate: ->
        console.log "activate phpunit"
        atom.workspaceView.command "phpunit:test", => @check()
        atom.workspace.observeTextEditors (editor) =>
            if editor.getGrammar().name == 'PHP'
                editor.getBuffer()?.onDidSave => @save()

    save: (editor)->
        onSave = atom.config.get "phpunit.runOnSave"
        if onSave == true then @check()

    check: ->
        phpunitPanel = atom.workspaceView.find(".phpunit-container")
        atom.workspaceView.find(".phpunit-contents").html("")
        atom.workspaceView.prependToBottom new PHPUnitView unless phpunitPanel.is(":visible")

        projectPaths = atom.project.getPaths()
        exec = atom.config.get "phpunit.execPath"
        options = atom.config.get "phpunit.execOptions"
        tail = spawn exec, ['--configuration', projectPaths + '/phpunit.xml', options]

        tail.stdout.on "data", (data) ->
            breakTag = "<br>"
            data = (data + "").replace /([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, "$1" + breakTag + "$2"
            atom.workspaceView.find(".phpunit-contents").append(data)
            atom.workspaceView.find(".phpunit-contents").scrollToBottom()

        tail.stderr.on "data", (data) ->
            atom.workspaceView.find(".phpunit-contents").append("<br>Runtime error<br>Please open console<br>")
            atom.workspaceView.find(".phpunit-contents").scrollToBottom()
            console.log "stderr: " + data

        tail.on "close", (code) ->
            atom.workspaceView.find(".phpunit-contents").append("<br>Complete<br>")
            atom.workspaceView.find(".phpunit-contents").scrollToBottom()
            console.log "child process exited with code " + code
