require 'net/http'

class DataController < ApplicationController
  def index
  end

  def depth
    uri = URI.parse("https://btc-e.com/api/2/#{params[:pair]}/depth")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.path, {'Content-Type' =>'application/json'})
    response = http.request(request)

    render json: response.body
  end

  def ticker
    case params[:exchange]
    when "btce"
      uri = URI.parse("https://btc-e.com/api/2/#{params[:pair]}/ticker")
    when "mtgox"
      uri = URI.parse("https://data.mtgox.com/api/2/BTCUSD/money/ticker_fast")
    when "bitstamp"
      uri = URI.parse("https://www.bitstamp.net/api/ticker")
    when "btcchina" 
      uri = URI.parse("https://data.btcchina.com/data/ticker")
    when "okcoin"
      uri = URI.parse("https://www.okcoin.com/api/ticker.do?symbol=#{params[:pair]}")
    else
      # no excahnge
    end
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri.path, {'Content-Type' =>'application/json'})
    response = http.request(request) 

    json = JSON.parse(response.body)

    case params[:exchange]
    when "btce"
      last = json["ticker"]["last"]
      buy  = json["ticker"]["buy"]
      sell = json["ticker"]["sell"]
    when "mtgox"
      last = json["data"]["last_local"]["value"]
      buy  = json["data"]["buy"]["value"]
      sell = json["data"]["sell"]["value"]
    when "bitstamp"
      last = json["last"]
      buy  = json["bid"]
      sell  = json["last"]
    when "btcchina"
      last = json["ticker"]["last"]
      buy  = json["ticker"]["buy"]
      sell = json["ticker"]["sell"]
    when "okcoin"
      last = json["ticker"]["last"]
      buy  = json["ticker"]["buy"]
      sell = json["ticker"]["sell"]
    else
      #no exchange
    end

    render json: { last: last, buy: buy, sell: sell }
  end
end
