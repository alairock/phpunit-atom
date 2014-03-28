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
        projectPath = atom.project.getPath()
        command = atom.config.get "phpunit.phpunitExecutablePath"
        tail = spawn(command, ['--configuration ' + projectPath])

        tail.stdout.on "data", (data) ->
            console.log "stdout: " + data

        tail.stderr.on "data", (data) ->
            console.log "stderr: " + data

        tail.on "close", (code) ->
            console.log "child process exited with code " + code
