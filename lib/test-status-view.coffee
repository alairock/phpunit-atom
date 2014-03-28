{View} = require 'atom'

module.exports =
# Internal: The main view for displaying the status from Travis CI.
class TestStatusView extends View
  # Internal: Build up the HTML contents for the fragment.
  @content: ->
    @div class: "phpunit-container"


  initialize: ->
    atom.workspaceView.command "phpunit:destroy", => @destroy()

  # Internal: Destroy the view and tear down any state.
  #
  # Returns nothing.
  destroy: ->
    if @isVisible()
      @detach()
