describe Role do
  context 'associations' do
    it "has appropriate associations" do
      expect( should belong_to(:user) ).to be_truthy
      expect( should belong_to(:organization) ).to be_truthy
    end
  end
end