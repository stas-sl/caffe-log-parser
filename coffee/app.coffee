class @App
  constructor: ->
    @parser = new Parser
    @plotting = new Plotting
    @params = new Params
    @loader = new Loader

    $('.js-load-gist').click ->
      gist_id = $('input[name=gist-id]').val()
      window.location.href = Arg.url gist: gist_id


  run: ->
    @params.init()

    if @params.src()
      @set_mode 'plot'
      @load_data()
    else
      @set_mode 'intro'


  set_mode: (mode) ->
    switch mode
      when 'intro'
        $('.intro').show()
#        $('.params').hide()
        $('#plotly').hide()
      when 'plot'
        $('.intro').hide()
#        $('.params').show()
        $('#plotly').show()


  load_data: ->
    raw_data = @loader.load @params.src()
    data = @parser.parse_multiple raw_data

    @plotting.plot('#plotly', data)


$ ->
  window.app = new App
  window.app.run()
