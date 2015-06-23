require "csv"

class AnalysisSearch

  def parse_csv
    searches = {}

    CSV.foreach("searches.csv") do |row|
      name = "#{row[0]} to #{row[1]}"
      hours, minutes, seconds = row[2].split(":")
      duration_in_seconds = hours.to_i * 60*60 + minutes.to_i * 60 + seconds.to_f

      if existing = searches[name]
        existing[:sum] += duration_in_seconds
        existing[:count] += 1
        existing[:min] = duration_in_seconds if existing[:min] > duration_in_seconds  
        existing[:max] = duration_in_seconds if existing[:max] < duration_in_seconds
      else
        searches[name] = {
          sum: duration_in_seconds,
          count: 1,
          min: duration_in_seconds,
          max: duration_in_seconds
        }
      end
    end
    return searches
  end

  def output

    puts <<-HTML
    <html>
      <head>
        <meta charset='utf-8'>
      </head>
      <body>
        <table>
          <tr>
            <th>Search</th>
            <th>Count</th>
            <th>Mean duration</th>
            <th>Min duration</th>
            <th>Max duration</th>
          </tr>
    HTML

    parse_csv.sort_by { |name, data| data[:count] }.reverse.each do |name, data|
      puts "<tr>"
      puts "<td>#{name}</td>"
      puts "<td>#{data[:count]}</td>"
      puts "<td>#{(data[:sum] / data[:count]).round(1)}s</td>"
      puts "<td>#{data[:min].round(1)}s</td>"
      puts "<td>#{data[:max].round(1)}s</td>"
      puts "</tr>"
    end

    puts "</table></body></html>"
  end

end

as = AnalysisSearch.new
as.output
