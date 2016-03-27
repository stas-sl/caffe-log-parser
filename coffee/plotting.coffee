class @Plotting
  @colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22',
    '#17becf']

  plot: (placeholder, data) ->
    graph_data = @group_data_by_plot data

    $placeholder = $(placeholder)
    $placeholder.empty()

    for key of graph_data
      id = "plotly_#{key}"
      $placeholder.append "<div id='#{id}' class='plotly-wrap'></div>"
      Plotly.newPlot "#{id}", graph_data[key],
        title: key
        font:
          family: '"Roboto", "Helvetica Neue", Helvetica, Arial, sans-serif'
          size: 14
#          color: '#7f7f7f'
        showlegend: true
        margin:
          pad: 10
          t: 40
          l: 70
          r: 40
          b: 70
        legend:
          xanchor: "left"
          yanchor: "top"
          x: 0.03
          y: 1
        xaxis:
          title: 'iterations'
#          showline: true
#          linecolor: "rgb(227, 227, 227)"
#          mirror: true
          zeroline: false
#          showgrid: false
#          ticks: "outside"
#          ticklen: 11
#          tickcolor: "rgb(227, 227, 227)"

        yaxis:
          title: key
#          showline: true
#          linecolor: "rgb(227, 0, 227)"
#          mirror: true
          zeroline: false
#          showgrid: false
#          ticks: "outside"
#          ticklen: 11
#          tickcolor: "rgb(227, 227, 227)"
      ,
        displaylogo: false

  group_data_by_plot: (data) ->
    graph_data = {}
    for run of data
      stages = _(data[run]).map('stage').uniq().value()
      #      stages = ['train']
      for stage in stages
        run_stage_data = _.filter data[run], stage: stage
        keys = _.keys run_stage_data[0]
        keys = _.without keys, 'iteration', 'stage'
#        keys = ['total_confidence', 'total_accuracy']
#        keys = ['loss', 'lr', 'total_confidence', 'total_accuracy',
#          'loss3/accuracy01', 'loss3/accuracy02', 'loss3/accuracy03', 'loss3/accuracy04',
#          'loss3/accuracy05', 'loss3/accuracy06']
        for key, index in keys
          @add_trace graph_data, run, stage, key, index, run_stage_data

    graph_data

  add_trace: (graph_data, run, stage, key, key_index, run_stage_data) ->
    unless graph_data[key]
      graph_data[key] = []

    y = _.map run_stage_data, key
    if _.find y
      x = _.map run_stage_data, 'iteration'
      [x_smooth, y_smooth] = @smooth x, y, 50
      color = @constructor.colors[graph_data[key].length % @constructor.colors.length]
      graph_data[key].push
        x: x_smooth
        y: y_smooth
        type: 'scatter'
        mode: 'line'
        name: "#{run} - #{stage} - smooth"
        opacity: 0.9
        line:
          width: 3
          color: color
#          dash: 'longdash'
#          shape: 'spline'
#          smoothing: 1.3

      graph_data[key].push
        x: x
        y: y
        type: 'scatter'
        mode: 'line'
        name: "#{run} - #{stage}"
        opacity: 0.6
        line:
          width: 2
          color: color
#          dash: 'dot'
#          shape: 'spline'


  smooth: (x, y, k) ->
    n = Math.floor x.length / k
    x_smooth = _(x).chunk(n).map(0).value()
    y_smooth = _(y).chunk(n).map((y) -> _.sum(y) / y.length).value()

    [x_smooth, y_smooth]
