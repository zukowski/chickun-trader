String.prototype.format = ->
  formatted = this
  for a,i in arguments
    regexp = new RegExp('\\{'+i+'\\}', 'gi')
    formatted = formatted.replace(regexp, a)

class @Ticker
  constructor: (@exchange, @pair) ->
    @uri = "/data/#{@exchange}/#{@pair}/ticker"
    @init()

  init: ->
    @fetch_data()
 
  fetch_data: ->
    $.ajax @uri,
      { dataType: "json" }
    .done (data) =>
      @update(data)

  update: (data) ->
    $(".last.#{@exchange}.#{@pair}, #depth.#{@exchange}.#{@pair} .last").html(data.last)
    if data.last == data.buy
      d3.select(".last.#{@exchange}.#{@pair}, #depth.#{@exchange}.#{@pair} .last").attr("class","last buy")
    else
      d3.select(".last.#{@exchange}.#{@pair}, #depth.#{@exchange}.#{@pair} .last").attr("class","last sell")

class @DepthTable
  constructor: (@exchange, @pair) ->
    @uri =
      "btce": "/data/#{@exchange}/#{@pair}/depth"
    @exchange_names =
      "btce": "BTC-e"
    @pair_names =
      "ltc_usd": "LTC/USD"
    @data = []
    @init()

  init: ->
    $("#depth").attr("class","#{@exchange} #{@pair}")
    $("#depth h1").html("#{@exchange_names[@exchange]} #{@pair_names[@pair]}")
    @asks_table = d3.select("#depth").select("#asks")
    @bids_table = d3.select("#depth").select("#bids")
    @fetch_data()

  fetch_data: ->
    $.ajax @uri[@exchange],
      { dataType: "json" }
    .done (data) =>
      @asks = data.asks.slice(0,15).reverse()
      @bids = data.bids.slice(0,15)
      @update_rows(@asks,"asks")
      @update_rows(@bids,"bids")
      @fetch_data()

  update_rows: (data, type) ->
    @rows = d3.select("body > div#depth > div##{type}").selectAll("div.row").data(data, (d) -> d[0])
    delay = 75
    @rows.enter().append("div").classed("row",true)
      .transition().delay( (d,i) -> i*delay ).duration(300).style("opacity",1)
      .transition().style("color","rgb(255,255,255)")
      .transition().styleTween("background-color", -> d3.interpolateRgb("rgb(100,100,100)","rgb(0,0,0)"))
    @rows.order()
    @cells =
      @rows.selectAll("div.cell")
        .data (d) =>
          [{column: 'Rate', value: d[0]}, {column: 'Amount', value: d[1] }]
    @cells.exit().remove()
    @rows.exit().remove()
    @cells.enter().append("div").classed("cell",true)
    @cells.html (d) ->
      parts = d.value.toString().split(".")
      output = "<span class='number'>#{parts[0]}.</span>"
      if parts.length > 1
        output += "<span class='fraction'>#{parts[1]}</span>"
      else
        output += "<span class='fraction'>000000</span>"
        
  set_data: (data) ->
    @update_rows()

  pad: (str, len) ->
    if str.length < len
      @pad(" " + str, len)
    else
      str

class @Candle
  constructor: ->
    @trades = []
    @init()

  init: ->
    @now = new Date()
    @now_utc = new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), now.getUTCHours(), now.getUTCMinutes(), now.getUTCSeconds())
    @start_time = @now.utc - (@now.utc % 60)
    

class @TradeChart
  constructor: (@id, @hour_range) ->
    @uri = "/data/#{@pair}/trades"
    @start = new Date("2013-09-01").getTime() / 1000
    @end = new Date("2013-12-05").getTime() / 1000
    @data = []
    @width = $(window).width() - 200
    @height = $(window).height() * 0.75
    @margin = 30
    @y
    @x
    @chart = d3.select("##{@id}")
               .append("svg:svg")
               .attr("class", "chart")
               .attr("width", @width)
               .attr("height", @height)
    @init()

  init: ->
    @fetchData()
 
  min: (a, b) ->
    if a < b
      a
    else
      b

  max: (a, b) ->
    if a > b
      a
    else
      b

  
  build_chart: (data) ->
    @y = d3.scale.linear()
           .domain([d3.min(data.map( (d) -> d.Low)), d3.max(data.map( (d) -> d.High))])
           .range([@height-@margin, @margin])
    @x = d3.scale.linear()
           .domain([@start,@end])
           .range([@margin,@width-@margin])
    
    @chart.on "mousemove", =>
      console.log(@x(d3.event.x) + "," + @y(d3.event.y))
 
    @chart.append("svg:line")
          .attr("class","cross-x")
          .attr("x1", 0)
          .attr("x2", @width)
          .attr("y1", 0)
          .attr("y2", 0)
          .attr("stroke", "#777")
          .attr("fill", "none")
          .attr("stroke-width", "1")

    @chart.append("svg:line")
          .attr("class","cross-y")
          .attr("x1", 0)
          .attr("x2", 0)
          .attr("y1", 0)
          .attr("y2", @height)
          .attr("stroke", "#777")
          .attr("stroke-width", "1px")
          .attr("vector-effect","non-scaling-stroke")
 
    @chart.selectAll("line.x")
        .data(@x.ticks(20))
        .enter().append("svg:line")
        .attr("class", "x")
        .attr("x1", @x)
        .attr("x2", @x)
        .attr("y1", @height - @margin)
        .attr("y2", @height - @margin - 10)
        .attr("stroke", "#666")

    @chart.selectAll("line.y")
        .data(@y.ticks(10))
        .enter().append("svg:line")
        .attr("class", "y")
        .attr("x1", @width - @margin - 20)
        .attr("x2", @width - 40)
        .attr("y1", @y)
        .attr("y2", @y)
        .attr("stroke", "#666")

    @chart.selectAll("text.xrule")
        .data(@x.ticks(10))
        .enter().append("svg:text")
        .attr("class", "xrule")
        .attr("x", @x)
        .attr("y", @height - @margin)
        .attr("dy", 20)
        .attr("text-anchor", "middle")
        .attr("fill", "#fff")
        .text( (d) -> date = new Date(d * 1000); (date.getMonth() + 1)+"/"+date.getDate())
 
    @chart.selectAll("text.yrule")
        .data(@y.ticks(10))
        .enter().append("svg:text")
        .attr("class", "yrule")
        .attr("x", @width - @margin)
        .attr("y", @y)
        .attr("dy", 3)
        .attr("dx", 20)
        .attr("text-anchor", "middle")
        .attr("fill", "#fff")
        .text(String)
   
    @chart.selectAll("line.stem")
        .data(data)
        .enter().append("svg:line")
        .attr("class", "stem")
        .attr("x1", (d) => @x(d.timestamp) + 0.25 * (@width - 2 * @margin) / data.length)
        .attr("x2", (d) => @x(d.timestamp) + 0.25 * (@width - 2 * @margin) / data.length)
        .attr("y1", (d) => @y(d.High))
        .attr("y2", (d) => @y(d.Low))
        .attr("stroke", (d) ->
                          if d.Open > d.Close
                            "rgb(255,40,40)"
                          else
                            "rgb(100,255,100)")

    @chart.selectAll("rect")
        .data(data)
        .enter().append("svg:rect")
        .attr("x", (d) => @x(d.timestamp) + 4 )
        .attr("y", (d) => @y(d3.max([d.Open, d.Close])))
        .attr("height", (d) => (@y(d3.min([d.Open, d.Close]))-@y(d3.max([d.Open, d.Close]))))
        .attr("width", (d) => 4)
        .attr("stroke", (d) ->
                          if d.Open > d.Close
                            "rgb(255,40,40)"
                          else
                            "rgb(100,255,100")
        .attr("fill", (d) ->
                        if d.Open > d.Close
                          "rgb(100,0,0)"
                        else
                          "rgb(0,70,0)")
    
    @chart.selectAll("*").attr("shape-rendering","crispEdges")

  appendToData: (x) ->
    if @data.length > 0
      return
    
    @data = x.query.results.quote
      
    for d,i in @data
      d.timestamp = (new Date(d.Date).getTime() / 1000)
  
    @data = @data.sort (x, y) -> (x.timestamp - y.timestamp)
    @build_chart(@data)

  buildQuery: ->
      symbol = window.location.hash
      if symbol == ""
        symbol = "AMZN"

      symbol = symbol.replace("#", "")
      base = "select * from yahoo.finance.historicaldata where symbol = \"{0}\" and startDate = \"{1}\" and endDate = \"{2}\""
      getDateString = d3.time.format("%Y-%m-%d")
      query = base.format(symbol, getDateString(@start), getDateString(@end))
      query = encodeURIComponent(query)
      #url = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.historicaldata%20where%20symbol%20in%20('YHOO')%20and%20startDate%20%3D%20'2009-09-11'%20and%20endDate%20%3D%20'2010-03-10'&diagnostics=true&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
      url = "https://query.yahooapis.com/v1/public/yql?q={0}&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=appendToData".format(query)
      url

  fetchData: ->
    url = "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.historicaldata%20where%20symbol%20in%20('AMZN')%20and%20startDate%20%3D%20'2013-09-01'%20and%20endDate%20%3D%20'2013-12-05'&diagnostics=true&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
    $.ajax url,
      { dataType: "json" }
    .done (data) =>
      console.log(data)
      @appendToData(data)
 
    return
    url = @buildQuery()
    scriptElement = document.createElement("SCRIPT")
    scriptElement.type = "text/javascript"
    # i add to the url the call back function
    scriptElement.src = url
    document.getElementsByTagName("HEAD")[0].appendChild(scriptElement)
