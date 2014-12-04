{spawn} = require 'child_process'
$ = require('atom').$
PHPUnitView = require './phpunit-view'

module.exports =
    config:
        execPath:
            title: 'PHPUnit Executable Path'
            description: 'PHPUnit executable full path
                        (/usr/local/bin/phpunit on Linux)'
            type: 'string'
            default: '/usr/local/bin/phpunit'
        execOptions:
            title: 'PHPUnit Command Line Options'
            description: 'Any PHPUnit command line option,
                          except -c|--configuration'
            type: 'string'
            default: ''
        runOnSave:
            title: 'Run on Save'
            description: 'Run automatically PHPUnit tests
                          after saving a PHP file'
            type: 'boolean'
            default: false
        filePattern:
            title: 'Test filename pattern'
            description: 'RegExp pattern for PHPUnit tests in projects
                          (any if empty)'
            type: 'string'
            default: '.*Test\.php.*'
        fileDefaultFolder:
            title: 'Tests folder'
            description: 'Default folder location for PHPUnit tests in projects
                          (any if empty)'
            type: 'string'
            default: 'tests/'

    runnableGrammar: ['PHP']

    activate: ->
        console.log "activate phpunit"
        atom.workspaceView.command "phpunit:alltests", => @runProject()
        atom.workspaceView.command "phpunit:current", => @runEditor atom.workspace.getActiveTextEditor()
        atom.workspaceView.command "phpunit:workspace", => @runWorkspace()
        atom.workspace.observeTextEditors (editor) =>
            editor.getBuffer()?.onDidSave => @runOnSave editor

    runOnSave: (editor) ->
        onSave = atom.config.get "phpunit.runOnSave"
        @runProject() if onSave is true and isRunnable editor

    runProject: ->
        projectPaths = atom.project.getPaths()
        options = atom.config.get "phpunit.execOptions"
        @executeTests ['--configuration', projectPaths + '/phpunit.xml', options]

    runWorkspace: ->
      for editor in atom.workspace.getTextEditors()
          @runEditor editor if @isRunnable editor

    runEditor: (editor) ->
      if @isRunnable editor
        file = editor.getPath()
        options = atom.config.get "phpunit.execOptions"
        @executeTests [options, file]

    isRunnable: (editor) ->
      runnable = editor.getGrammar().name in @runnableGrammar

      filterFolder = atom.project.getPaths() + '/' + atom.config.get "phpunit.fileDefaultFolder"
      filterFolder.replace /([\\/])\1+/g, "$1"
      regexPath = ///^#{filterFolder}.*///
      runnable = runnable && regexPath.test(editor.getPath())

      filterPattern = atom.config.get "phpunit.filePattern"
      regexName = ///#{filterPattern}///
      runnable = runnable && regexName.test(editor.getTitle())

    executeTests: (options) ->
        @initView()
        tail = @execPHPUnit options

        tail.stdout.on "data", (data) =>
            @showOutput data

        tail.stderr.on "data", (data) =>
            @showOutput "<br><b>Runtime error</b><br><br>"
            @showOutput data

        tail.on "close", (code) =>
            @showOutput "<br>Complete<br>", false

    initView: ->
        phpunitPanel = atom.workspaceView.find(".phpunit-container")
        atom.workspaceView.find(".phpunit-contents").html("")
        atom.workspaceView.prependToBottom new PHPUnitView unless phpunitPanel.is(":visible")
        atom.workspaceView.find(".phpunit-contents").on 'click', 'a', ->
            [uri, line] = "#{$(this).text()}".split ':'
            line = Number(line)
            line = 0 unless line
            atom.workspace.open uri, {initialLine: line}

    execPHPUnit: (params)->
        exec = atom.config.get "phpunit.execPath"
        spawn exec, params

    showOutput: (data, parse = true) ->
        breakTag = "<br>"
        data = data + ""
        if parse is true
            data = data.replace /([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, "$1" + breakTag + "$2"
            data = data.replace /\son line\s(\d+)/g, ":$1"
            data = data.replace /((([A-Z]\:)?([\\\/]+\w+)+(\.\w+)+(\:\d+)?))/g, "<a>$1</a>"
        atom.workspaceView.find(".phpunit-contents").append data
        atom.workspaceView.find(".phpunit-contents").scrollToBottom
