describe Role do
  context 'associations' do
    it "has appropriate associations" do
      expect(should belong_to(:user)).to be_truthy
      expect(should belong_to(:organization)).to be_truthy
    end
  end

  context 'role types' do
    it "denied? should be true when role_type is 'denied'" do
      role = Role.new
      allow(role).to receive(:role_type).and_return('denied')

      expect(role.denied?).to eq(true)
    end

    it "should not return true for denied? when role_type is not 'denied'" do
      role = Role.new
      allow(role).to receive(:role_type).and_return('admin')

      expect(role.denied?).to eq(false)
    end
  end
end