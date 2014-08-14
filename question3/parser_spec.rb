require './parser.rb'

describe Parser do
  context 'when parsing' do
    it 'should return the appropriate JSON for the string passed' do
      desired_result = {
        :feature => "TXT MESSAGING - 250",
        :date_range => "09/29 - 10/28",
        :price => 4.99
      }.to_json

      Parse.new.parse("$4.99 TXT MESSAGING - 250 09/29 - 10/29 4.99").should == desired_result
    end
  end
end