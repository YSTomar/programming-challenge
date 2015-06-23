require 'nokogiri'
require 'open-uri'
require 'time_diff'

class Search
  def result
    doc = Nokogiri::XML(open('search.xml'))
    doc.xpath("//SearchResult").each do |search_result|
      puts fetch_id(search_result)
      connections = search_result.css('Connection')
      fetch_description(connections)
      puts '=============== End of connection ==============='
    end
  end

  def fetch_id(search_result)
    id = search_result.xpath('./ID').text
  end

  def fetch_description(connections)
    conn = Array.new
    connections.each_with_index do |connection, index|
      start = connection.css("Start").text
      finish = connection.css("Finish").text
      departure_time = connection.css("DepartureTime").text
      arrival_time = connection.css("ArrivalTime").text
      train_name = connection.css("TrainName").text
      duration_of_connection = Time.diff(Time.parse(arrival_time) , Time.parse(departure_time))      
      puts "start = #{start}, finish = #{finish}, departure_time = #{departure_time}, arrival_time = #{arrival_time}, train_name = #{train_name}, duration_of_connection = #{duration_of_connection[:diff]}"
      fetch_fare(connection.css('Fare'))
      conn << duration_of_connection[:hour] * 3600 + duration_of_connection[:minute] * 60 + duration_of_connection[:second]      
      puts "time the passenger has for each train change = #{Time.diff(Time.parse(connections[index  + 1].css("DepartureTime").text) , Time.parse(arrival_time))[:diff]}" if (index < connections.count - 1 )
      puts '----------------------'     
    end
    total_seconds = conn.inject(:+)
    puts "Total duration of journey = #{Time.at(total_seconds).utc.strftime("%H:%M:%S")}"
    puts "train needs to be change = #{conn.count}"
  end

  def fetch_fare(fares)
    puts '-- Fare --'
    fares.each do |fare|
      puts "Name = #{fare.css('Name').text}, Price = #{fare.css('Price').css('Value').text} GBP" 
    end
  end

end

search = Search.new
search.result

