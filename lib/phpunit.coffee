{spawn} = require 'child_process'
$ = require('atom').$
PHPUnitView = require './phpunit-view'

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

    runnableGrammar: ['PHP']

    activate: ->
        console.log "activate phpunit"
        atom.workspaceView.command "phpunit:test", => @check()
        atom.workspace.observeTextEditors (editor) =>
            grammar = editor.getGrammar().name
            editor.getBuffer()?.onDidSave => @save grammar

    save: (editorGrammar)->
        onSave = atom.config.get "phpunit.runOnSave"
        if onSave == true
            @check() if editorGrammar in @runnableGrammar

    check: ->
        phpunitPanel = atom.workspaceView.find(".phpunit-container")
        atom.workspaceView.find(".phpunit-contents").html("")
        atom.workspaceView.prependToBottom new PHPUnitView unless phpunitPanel.is(":visible")
        atom.workspaceView.find(".phpunit-contents").on 'click', 'a', ->
            [uri, line] = "#{$(this).text()}".split ':'
            line = Number(line)
            line = 0 unless line
            atom.workspace.open uri, {initialLine: line}

        projectPaths = atom.project.getPaths()
        exec = atom.config.get "phpunit.execPath"
        options = atom.config.get "phpunit.execOptions"
        tail = spawn exec, ['--configuration', projectPaths + '/phpunit.xml', options]

        tail.stdout.on "data", (data) =>
            breakTag = "<br>"
            data = (data + "").replace /([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, "$1" + breakTag + "$2"
            data = data.replace /((([A-Z]\:)?([\\\/]+\w+)+(\.\w+)+(\:\d+)?))/g, "<a>$1</a>"
            atom.workspaceView.find(".phpunit-contents").append data
            atom.workspaceView.find(".phpunit-contents").scrollToBottom

        tail.stderr.on "data", (data) =>
            breakTag = "<br>"
            data = (data + "").replace /([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, "$1" + breakTag + "$2"
            data = data.replace /\son line\s(\d+)/g, ":$1"
            data = data.replace /((([A-Z]\:)?([\\\/]+\w+)+(\.\w+)+(\:\d+)?))/g, "<a>$1</a>"
            atom.workspaceView.find(".phpunit-contents").append breakTag + "<b>Runtime error</b>" + breakTag + breakTag
            atom.workspaceView.find(".phpunit-contents").append data
            atom.workspaceView.find(".phpunit-contents").scrollToBottom

        tail.on "close", (code) =>
            atom.workspaceView.find(".phpunit-contents").append "<br>Complete<br>"
            atom.workspaceView.find(".phpunit-contents").scrollToBottom
