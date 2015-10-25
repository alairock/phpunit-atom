$ = require 'jquery'
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
        displayInTextBuffer:
            title: 'Display in text buffer'
            description: 'Display PHPUnit results in a text buffer'
            type: 'boolean'
            default: false

    runnableGrammar: ['PHP']

    activate: ->
        console.log "activate phpunit"

        @phpUnitView = new PHPUnitView
        atom.commands.add 'atom-workspace', 'phpunit:alltests', => @runProject()
        atom.commands.add 'atom-workspace', 'phpunit:current', => @runEditor atom.workspace.getActiveTextEditor()
        atom.commands.add 'atom-workspace', 'phpunit:workspace', => @runWorkspace()
        atom.commands.add 'atom-workspace', 'phpunit:kill', => @killProcess()
        atom.commands.add 'atom-workspace', 'phpunit:hide', => @hideView()
        atom.workspace.observeTextEditors (editor) =>
            editor.getBuffer()?.onDidSave => @runOnSave editor

    runOnSave: (editor) ->
        onSave = atom.config.get 'phpunit.runOnSave'
        @runProject() if onSave is true and @isRunnable editor

    runProject: ->
        projectPaths = atom.project.getPaths()
        options = atom.config.get 'phpunit.execOptions'
        @executeTests ['--configuration', projectPaths + '/phpunit.xml', options]

    runWorkspace: ->
      for editor in atom.workspace.getTextEditors()
          @runEditor editor if @isRunnable editor

    runEditor: (editor) ->
      if @isRunnable editor
        file = editor.getPath()
        options = atom.config.get 'phpunit.execOptions'
        @executeTests [options, file]

    isRunnable: (editor) ->
      # check if editor grammar compatible with PHPUnit
      runnable = editor.getGrammar().name in @runnableGrammar
      # check if editor file is in tests folder
      filterFolder = atom.project.getPaths() + '/' + atom.config.get 'phpunit.fileDefaultFolder'
      filterFolder.replace /([\\/])\1+/g, "$1"
      regexPath = ///^#{filterFolder}.*///
      runnable ||= regexPath.test(editor.getPath())
      # check if editor file is a test file
      filterPattern = atom.config.get 'phpunit.filePattern'
      regexName = ///#{filterPattern}///
      runnable ||= regexName.test(editor.getTitle())

    executeTests: (options) ->
        if not atom.config.get "phpunit.displayInTextBuffer"
            @initView()
        @prepareExecPHPUnit options

    initView: ->
        @phpUnitView.clear()
        atom.workspace.addBottomPanel({ item: @phpUnitView })
        @phpUnitView.output.on 'click', 'a', ->
            [uri, line] = "#{$(this).text()}".split ':'
            line = Number(line)
            line = 0 unless line
            atom.workspace.open uri, {initialLine: line}

    textEditorDestroyed: ()->
        console.log('phpunit textEditor destroyed.')
        @textEditor = null

    # Run PHPUnit after text editor is ready.
    gotTextEditor: (textEdit, params)->
        @textEditor = textEdit
        @textEditor.onDidDestroy( => @textEditorDestroyed() )
        @execPHPUnit(params)

    errOpeningTextEditor: ->
        @textEditor = null
        @editorPane = null

    # If displaying in a text editor, ensure the text editor exists.
    prepareExecPHPUnit: (params)->
        @phpUnitView.buttonKill.enable()
        useTextEditor = atom.config.get "phpunit.displayInTextBuffer"
        if useTextEditor
            if @textEditor?
                @textEditor.selectAll()
                @textEditor.delete()
                if @editorPane? and @textEditor in @editorPane.getItems()
                    @editorPane.activate()
                    @editorPane.activateItem(@textEditor)
                else
                    @editorPane = null
                    # ToDo: if text editor moved, search all panes for it and
                    # activate it.
                @execPHPUnit(params)
            else
                @editorPane = atom.workspace.getActivePane().splitDown()
                promise = atom.workspace.open()
                promise.then(
                    ( (editor) => @gotTextEditor(editor, params) ),
                    => @errOpeningTextEditor() )
        else
            @execPHPUnit(params)

    execPHPUnit: (params)->
        options =
            cwd: atom.project.getPaths()[0]
        spawn = require('child_process').spawn
        exec = atom.config.get "phpunit.execPath"
        useTextEditor = atom.config.get "phpunit.displayInTextBuffer"

        @phpunit = spawn exec, params, options

        @phpunit.stdout.on 'data', (data) =>
            if useTextEditor
                if @textEditor?
                    str = data.toString()
                    @textEditor.insertText(str)
            else
                @phpUnitView.append data

        @phpunit.stderr.on 'data', (data) =>
            if useTextEditor
                if @textEditor?
                    @textEditor.insertText('Runtime error')
                    str = data.toString()
                    @textEditor.insertText(str)
            else
                @phpUnitView.append '<br><b>Runtime error</b><br><br>'
                @phpUnitView.append data

        @phpunit.on 'close', (code, signal) =>
            if signal then log = "Process killed with signal #{signal}"
            else log = 'Complete.'
            if useTextEditor
                if @textEditor?
                    @textEditor.insertText(log)
            else
                @phpUnitView.append "<br>#{log}<br><hr>", false
                @phpUnitView.buttonKill.disable()

    killProcess: ->
        if @phpunit.pid
            if useTextEditor
                if @textEditor?
                    @textEditor.insertText('Killing current PHPUnit execution...')
            else
                @phpUnitView.append 'Killing current PHPUnit execution...<br>'
                @phpunit.kill 'SIGHUP'

    hideView: ->
        @phpUnitView.close()

    getTextEditor: ->
        return @textEditor
