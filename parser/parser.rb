require 'json'

class Parser
  REGEX = /(^\$\d*\.\d\d)[\s](\w*\s\w*\s\D\s\d*)[\s](\d\d\/\d\d\s\W\s\d\d\W\d\d)[\s](\d*\.\d\d)/

  def parse_line(line)
    data = line.match(REGEX)
    raise 'Incorrectly formatted line' if data.nil? || [data[2], data[3], data[4]].any?(&:nil?)

    return { :feature => data[2], :date_range => data[3], :price => data[4].to_f }.to_json
  end

  def parse_file(filename)
    File.open(filename, 'r') do |file|
      file.each_line do |line|
        puts(parse_line(line))
      end
    end
  end
end