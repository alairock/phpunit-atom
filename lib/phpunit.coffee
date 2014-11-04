fs = require 'fs'
path = require 'path'
{spawn} = require 'child_process'

PHPUnitView = require './test-status-view'

module.exports =
    configDefaults:
        phpunitExecutablePath: '/usr/local/bin/phpunit'
        phpunitOptions: ''
        ExecuteOnSave: false

    activate: ->
      atom.workspaceView.command "phpunit:test", => @check()

      atom.workspace.eachEditor (editor) =>
         buffer = editor.getBuffer()
         buffer.on 'saved', => @save()


    save: ->
        onSave = atom.config.get "phpunit.ExecuteOnSave"
        if onSave == true then @check()

    check: ->
        phpunitPanel = atom.workspaceView.find(".phpunit-container")
        atom.workspaceView.find(".phpunit-contents").html("")
        atom.workspaceView.prependToBottom new PHPUnitView unless phpunitPanel.is(":visible")


        projectPaths = atom.project.getPaths()
        command = atom.config.get "phpunit.phpunitExecutablePath"
        options = atom.config.get "phpunit.phpunitExecutableOptions"
        tail = spawn command, ['--configuration', projectPaths + '/phpunit.xml', options]

        tail.stdout.on "data", (data) ->
            breakTag = "<br>"
            data = (data + "").replace /([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, "$1" + breakTag + "$2"
            atom.workspaceView.find(".phpunit-contents").append("#{data}")
            atom.workspaceView.find(".phpunit-contents").scrollToBottom()

        tail.stderr.on "data", (data) ->
            console.log "stderr: " + data
            atom.workspaceView.find(".phpunit-contents").append("<br>Runtime error<br>Please open console<br>")
            atom.workspaceView.find(".phpunit-contents").scrollToBottom()

        tail.on "close", (code) ->
            atom.workspaceView.find(".phpunit-contents").append("<br>Complete<br>")
            atom.workspaceView.find(".phpunit-contents").scrollToBottom()
            console.log "child process exited with code " + code
