{WorkspaceView} = require 'atom'
Phpunit = require '../lib/phpunit'

describe "Phpunit", ->
  [activationPromise] = []

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('phpunit')

  describe "when the phpunit:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.phpunit-container')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'phpunit:test'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.phpunit-container')).toExist()
