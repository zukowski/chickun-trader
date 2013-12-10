$ ->
  @depth_table = new DepthTable("btce","ltc_usd")
  @chart = new TradeChart("chart",1)

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

  
