path = require 'path'
fs = require 'fs-plus'
temp = require 'temp'

describe "PHPUnit", ->

    beforeEach ->
        atom.workspaceEle = atom.views.getView(atom.workspace)
        # atom.config.set("phpunit.execPath", '/usr/local/bin/phpunit')
        atom.config.set("phpunit.execPath", '/Applications/mampstack-5.4.19-0/php/bin/phpunit')
        atom.config.set("phpunit.displayInTextBuffer", false)

        waitsForPromise ->
            atom.packages.activatePackage('phpunit').then ->
                atom.pu = atom.packages.getLoadedPackage('phpunit')

    describe "when phpunit.displayInTextBuffer is false", ->
        it "returns undefined when calling phpunit.getTextEditor", ->
            actual = atom.pu.mainModule.getTextEditor()
            expect(actual).not.toBeDefined()

    describe "when the phpunit:alltests event is triggered", ->
        it "calls phpunit.executeTests", ->
            spyOn(atom.pu.mainModule, 'executeTests')

            runs ->
                atom.pu.mainModule.executeTests()
                atom.commands.dispatch atom.workspaceEle, 'phpunit:alltests'

            waitsFor ( ->
                return atom.pu.mainModule.executeTests.wasCalled), 'executeTests() to be called', 1000

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
                waitsForPromise ->
                    atom.packages.activatePackage('language-php')

            describe "when the current buffer uses PHP grammar", ->

                beforeEach ->
                    runs ->
                        editor.setGrammar atom.grammars.selectGrammar('text.html.php')

                it "calls phpunit.runProject", ->
                    spyOn(atom.pu.mainModule, 'runProject')

                    runs ->
                        buffer.save()
                        expect(atom.pu.mainModule.runProject).toHaveBeenCalled()

            describe "when the current buffer does not use PHP grammar", ->

                beforeEach ->
                    runs ->
                        editor.setGrammar atom.grammars.selectGrammar('text.plain')

                it "does nothing", ->
                    spyOn(atom.pu.mainModule, 'runProject')

                    runs ->
                        buffer.save()
                        expect(atom.pu.mainModule.runProject).not.toHaveBeenCalled()

        describe "when the RunOnSave option is disabled", ->

            beforeEach ->
                atom.config.set("phpunit.runOnSave", false)

            it "does nothing", ->
                spyOn(atom.pu.mainModule, 'runProject')

                runs ->
                    buffer.save()
                    expect(atom.pu.mainModule.runProject).not.toHaveBeenCalled()

        describe "when displayInTextBuffer is true and after running PHPUnit", ->
            it "returns a valid TextEditor when calling getTextEditor()", ->
                atom.config.set("phpunit.displayInTextBuffer", true)

                runs ->
                    atom.commands.dispatch atom.workspaceEle, 'phpunit:alltests'

                waitsFor ( ->
                    editor = atom.pu.mainModule.getTextEditor()
                    if editor? then return true
                    return false), 1000
