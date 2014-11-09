{View} = require 'atom'

module.exports =
# Internal: The main view for displaying the status from Travis CI.
class PHPUnitView extends View
    # Internal: Build up the HTML contents for the fragment.
    @content: ->
        @div class: "phpunit-container", =>
            @button click: 'destroy', class: 'btn btn-error pull-right', =>
                @span class: "icon icon-x"
                @span 'close'
            @div class: "phpunit-contents"

    # Internal: Destroy the view and tear down any state.
    #
    # Returns nothing.
    destroy: ->
        if @isVisible()
          @detach()
