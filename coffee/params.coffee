class @Params
  init: ->
    @args = Arg.all()

  src: ->
    if @args.gist?
      return gist: @args.gist

    nil

