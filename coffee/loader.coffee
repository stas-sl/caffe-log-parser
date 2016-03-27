class @Loader
  @gist_url_regex = /https:\/\/gist.github.com\/([^\/]+\/[0-9a-f]+)/
  @gist_id_regex = /[0-9a-f]+/
  @gist_api_url = 'https://api.github.com/gists/'

  load: (src) ->
    if src.gist?
      return @load_gist src.gist

  load_gist: (gist) ->
    data = {}

    gist_url_match = gist.match @constructor.gist_url_regex
    if gist_url_match
      gist_id = gist_url_match[1]
    else
      gist_id_match = gist.match @constructor.gist_id_regex
      if gist_id_match
        gist_id = gist_id_match[0]

    if gist_id?
      $.ajax
        url: "#{@constructor.gist_api_url}#{gist_id}"
        dataType: 'json'
        async: false
        success: (res) ->
          for filename, fileattrs of res.files
            if fileattrs.truncated
              $.get
                url: fileattrs.raw_url
                async: false
                success: (file_contents) ->
                  data[filename] = file_contents
            else
              data[filename] = fileattrs.content

    data