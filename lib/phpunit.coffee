fs = require 'fs'
path = require 'path'
{spawn} = require 'child_process'


TestStatusView = require './test-status-view'

module.exports =
    configDefaults:
        phpunitExecutablePath: '/usr/local/bin/phpunit'

    # Internal: The build matrix bottom panel view.
    buildMatrixView: null

    # Internal: The build status status bar entry view.
    buildStatusView: null

    activate: ->
      atom.workspaceView.command "phpunit:test", => @check()

    check: ->
        phpunitPanel = atom.workspaceView.find(".phpunit-container")
        atom.workspaceView.prependToBottom new TestStatusView unless phpunitPanel.is(":visible")

        projectPath = atom.project.getPath()
        command = atom.config.get "phpunit.phpunitExecutablePath"
        tail = spawn(command, ['--configuration ' + projectPath])

        tail.stdout.on "data", (data) ->
            breakTag = "<br>"
            data = (data + "").replace /([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, "$1" + breakTag + "$2"
            atom.workspaceView.find(".phpunit-container").append("#{data}")
            atom.workspaceView.find(".phpunit-container").scrollToBottom()

        tail.stderr.on "data", (data) ->
            console.log "stderr: " + data

        tail.on "close", (code) ->
            atom.workspaceView.find(".phpunit-container").append("<br>To close this window: Press ctrl+p then press x ")
            atom.workspaceView.find(".phpunit-container").scrollToBottom()
            console.log "child process exited with code " + code
