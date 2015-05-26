{View} = require 'atom-space-pen-views'

module.exports =
# Internal: The main view for displaying the status from Travis CI.
class PHPUnitView extends View
    # Internal: Build up the HTML contents for the fragment.
    @content: ->
        @div class: 'phpunit-container', outlet: 'container', =>
            @button click: 'close', class: 'btn btn-default pull-right', =>
                @span class: 'icon icon-x'
            @button click: 'clear', class: 'btn btn-default pull-right', =>
                @span class: 'icon icon-trashcan'
            @button click: 'kill', class: 'btn btn-default pull-right', outlet: 'buttonKill', disabled: true, =>
                @span class: 'icon icon-zap'
            @button click: 'copy', class: 'btn btn-default pull-right', =>
                @span class: 'icon icon-clippy'
            @div class: 'phpunit-contents', outlet: 'output'

    close: ->
        if @isVisible()
          @detach()

    clear: ->
        @output.html ""

    kill: ->
        atom.commands.dispatch(atom.views.getView(atom.workspace), 'phpunit:kill')

    copy: ->
        atom.clipboard.write @output.text()

    append: (data, parse = true) ->
        breakTag = "<br>"
        data = data + ""
        if parse is true
            data = data.replace /([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, "$1" + breakTag + "$2"
            data = data.replace /\son line\s(\d+)/g, ":$1"
            data = data.replace /((([A-Z]\\:)?([\\/]+(\w|-|_|\.)+)+(\.(\w|-|_)+)+(:\d+)?))/g, "<a>$1</a>"
        @output.append data
