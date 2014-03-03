PhpunitView = require '../lib/phpunit-view'
{WorkspaceView} = require 'atom'

describe "PhpunitView", ->
  it "has one valid test", ->
    expect("life").toBe "easy"
