Phpunit = require '../lib/phpunit'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Phpunit", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('phpunit')

  describe "when the phpunit:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.phpunit')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'phpunit:test'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.phpunit')).toExist()
        atom.workspaceView.trigger 'phpunit:test'
        expect(atom.workspaceView.find('.phpunit')).not.toExist()
