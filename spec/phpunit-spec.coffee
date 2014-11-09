{WorkspaceView} = require 'atom'
path = require 'path'
fs = require 'fs-plus'
temp = require 'temp'

describe "PHPUnit", ->

    beforeEach ->
        atom.workspaceView = new WorkspaceView
        atom.workspace = atom.workspaceView.model
        atom.config.set("phpunit.execPath", '/usr/local/bin/phpunit')

        waitsForPromise ->
            atom.packages.activatePackage('phpunit')

    describe "when the phpunit:test event is triggered", ->
        it "attaches and then detaches the view", ->
            expect(atom.workspaceView.find('.phpunit-container')).not.toExist
            atom.workspaceView.trigger 'phpunit:test'

            runs ->
                expect(atom.workspaceView.find('.phpunit-container')).toExist

    describe "when the buffer is saved", ->
        [editor, buffer] = []

        beforeEach ->
            directory = temp.mkdirSync()
            atom.project.setPaths(directory)
            filePath = path.join(directory, 'phpunit-atom.txt')
            fs.writeFileSync(filePath, 'phpunit-spec')

            waitsForPromise ->
                atom.workspace.open(filePath).then (o) -> editor = o

            runs ->
                buffer = editor.getBuffer()

        describe "when the RunOnSave option is enabled", ->

            beforeEach ->
                atom.config.set("phpunit.runOnSave", true)

            it "attaches and then detaches the view", ->
                expect(atom.workspaceView.find('.phpunit-container')).not.toExist
                editor.save()

                runs ->
                    expect(atom.workspaceView.find('.phpunit-container')).toExist

        describe "when the RunOnSave option is disabled", ->

            beforeEach ->
                atom.config.set("phpunit.runOnSave", false)

            it "does nothing", ->
                expect(atom.workspaceView.find('.phpunit-container')).not.toExist
                buffer.save()

                runs ->
                    expect(atom.workspaceView.find('.phpunit-container')).not.toExist
