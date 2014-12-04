{View} = require 'atom'

module.exports =
# Internal: The main view for displaying the status from Travis CI.
class PHPUnitView extends View
    # Internal: Build up the HTML contents for the fragment.
    @content: ->
        @div class: 'phpunit-container', =>
            @button click: 'close', class: 'btn btn-default pull-right', =>
                @span class: 'icon icon-x'
            @button click: 'clear', class: 'btn btn-default pull-right', =>
                @span class: 'icon icon-trashcan'
            @div class: 'phpunit-contents'

    close: ->
        if @isVisible()
          @detach()

    clear: ->
        #todo
