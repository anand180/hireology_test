describe User do
  context 'associations' do
    it "has appropriate associations" do
      expect( should have_many(:roles) ).to be_truthy
      expect( should have_many(:organizations).through(:roles) ).to be_truthy
    end
  end
end