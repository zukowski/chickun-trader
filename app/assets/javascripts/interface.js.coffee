$ ->
  #@depth_table = new DepthTable("btce","ltc_usd")
  @chart = new TradeChart("chart",1)
  window.chart = @chart
  
  $("#chart").mousemove (e) ->
    offset = $(this).offset()
    rel_x = e.pageX - offset.left
    rel_y = e.pageY - offset.top
    $(this).css("cursor","none")
    $(this).find("line.cross-x").attr("y1",rel_y).attr("y2",rel_y)
    $(this).find("line.cross-y").attr("x1",rel_x).attr("x2",rel_x)
    console.log(window.chart.x(rel_x) + "," + window.chart.y(rel_y))
 
  window.appendToData = (x) ->
    @chart.appendToData(x)
  
  t1 = new Ticker("btce","ltc_usd")
  t2 = new Ticker("btce","btc_usd")
  #t3 = new Ticker("mtgox","btc_usd")
  #t4 = new Ticker("bitstamp","btc_usd")
  #t5 = new Ticker("btcchina","btc_usd")
  #t6 = new Ticker("okcoin","ltc_cny")

  setInterval ->
    t1.fetch_data()
    t2.fetch_data()
    #t3.fetch_data()
    #t4.fetch_data()
    #t5.fetch_data()
    #t6.fetch_data()
  , 2000

  
