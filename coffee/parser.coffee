class @Parser
  @iteration_regex = /Iteration (\d+), (Testing)?(loss = ([\.\deE+-]+))?(lr = ([\.\deE+-]+))?/
  @output_line_regex = /(Train|Test) net output #(\d+): (\S+) = ([\.\deE+-]+)/
  @test_loss_regex = /Test loss: ([\.\deE+-]+)/

  parse: (raw_data) ->
    lines = _.split raw_data, '\n'

    rows = []

    row = {}
    iteration_offset = 0
    prev_iteration = -1

    for line in lines
      iteration_match = line.match @constructor.iteration_regex
      if iteration_match
        iteration = _.parseInt iteration_match[1]
        stage = if iteration_match[2] then 'test' else 'train'
        if iteration != prev_iteration or row.stage != stage
          if row.iteration?
            rows.push row

            # if multiple log files where concatenated into one,
            # then at some point iteration number may restart from zero,
            # but we want to continue numbering
            if iteration < prev_iteration
              iteration_offset += prev_iteration

          row =
            iteration: iteration + iteration_offset, stage: stage
          prev_iteration = iteration

        row.loss = parseFloat iteration_match[4] if iteration_match[4]
        row.lr = parseFloat iteration_match[6] if iteration_match[6]
      continue if iteration is null

      test_loss_match = line.match @constructor.test_loss_regex
      if test_loss_match
        row.loss = parseFloat test_loss_match[1]

      output_line_match = line.match @constructor.output_line_regex
      if output_line_match
        row[output_line_match[3]] = parseFloat output_line_match[4]

    rows

  parse_multiple: (raw_data_multiple) ->
    data_multiple = {}
    for name, raw_data of raw_data_multiple
      data_multiple[name] = @parse raw_data

    data_multiple

