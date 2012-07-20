require 'net/http'
require 'net/https'
require 'rubygems'
require 'json'

class Leftronic
  ALLOWED_COLORS = [:red, :yellow, :green, :blue, :purple]
  attr_accessor :key

  def url=(url)
    @url = URI(url.to_s)
  end

  def url
    @url.to_s
  end

  def initialize(key, url='https://www.leftronic.com/customSend/')
    @key     = key
    self.url = url
  end

  # Push anything to a widget
  def push(stream, object)
    post stream, 'point' => object
  end

  # Push a Number to a widget
  def push_number(stream, point)
    push stream, point
  end

  # Push a geographic location (latitude and longitude) to a Map widget
  def push_geo(stream, lat, long, color=nil)
    push stream, { 'latitude' => lat, 'longitude' => long, 'color' => color }
  end

  def clear(stream)
    post stream, 'command' => 'clear'
  end

  # Push a title and message to a Text Feed widget
  def push_text(stream, title, message)
    push stream, 'title' => title, 'msg' => message
  end

  # Push a array to a Leaderboard widget
  def push_leaderboard(stream, array)
    push stream, { 'leaderboard' => array }
  end

  # Push an array to a List widget
  def push_list(stream, *array)
    push stream, { 'list' => array.flatten.map { |item| { 'listItem' => item } } }
  end

  protected

  def post(stream, params)
    request    = build_request(stream, params)
    connection = build_connection
    connection.start { |http| http.request request }
    params
  end

  def build_request(stream, params)
    request                 = Net::HTTP::Post.new @url.request_uri
    request['Accept']       = 'application/json'
    request['Content-Type'] = 'application/json'
    request.body            = {
        'accessKey'  => @key,
        'streamName' => stream
    }.merge!(params.to_hash).to_json
    request
  end

  def build_connection # NOTE: Does not open the connection
    connection = Net::HTTP.new @url.host, @url.port
    if @url.scheme == 'https'
      connection.use_ssl     = true
      connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    connection
  end
end
