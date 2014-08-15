require './parser.rb'
require 'json'

describe Parser do
  before(:each) do
    @parser = Parser.new
  end

  context 'when parsing lines' do
    it 'should return the appropriate JSON for the string passed' do
      desired_result = {
        :feature => "TXT MESSAGING - 250",
        :date_range => "09/29 - 10/28",
        :price => 4.99
      }.to_json

      expect(@parser.parse_line("$4.99 TXT MESSAGING - 250 09/29 - 10/28 4.99")).to eq(desired_result)
    end

    it 'should parse dollar amounts of any size' do
      desired_result = {
        :feature => "TXT MESSAGING - 250",
        :date_range => "09/29 - 10/28",
        :price => 103.97
      }.to_json

      expect(@parser.parse_line("$103.97 TXT MESSAGING - 250 09/29 - 10/28 103.97")).to eq(desired_result)
    end

    it 'should handle arbitrary dates in format mm/yy' do
      desired_result = {
        :feature => "TXT MESSAGING - 250",
        :date_range => "01/19 - 05/01",
        :price => 100.00
      }.to_json

      expect(@parser.parse_line("$100.00 TXT MESSAGING - 250 01/19 - 05/01 100.00")).to eq(desired_result)
    end

    it 'should raise an exception if the formatting of a line is incorrect' do
      expect { (@parser.parse_line("$100.00 TXTMESSAGING - 250 01/19 - 05/01 100.00")) }.to raise_error(RuntimeError, 'Incorrectly formatted line')
    end
  end

  context 'when parsing files' do
    before(:each) do
      @file = double('file')
      allow(@file).to receive(:each_line).and_yield('line1').and_yield('line2').and_yield('line3')
      allow(File).to receive(:open).and_yield(@file)
    end

    it 'should call parse_line for each line in the file' do
      expect(@parser).to receive(:parse_line).exactly(3).times

      @parser.parse_file('this_file_not_real')
    end
  end
end