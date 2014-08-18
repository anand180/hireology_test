describe Organization  do
  before(:all) do
  end

  context 'associations' do
    it "has appropriate associations" do
      expect( should have_many(:users).through(:roles) ).to be_truthy
      expect( should have_many(:roles) ).to be_truthy
      expect( should have_many(:organizations) ).to be_truthy
      expect( should belong_to(:parent_organization) ).to be_truthy
    end
  end

  context 'when granting roles' do
    before(:each) do
      @org = Organization.new
      @user = User.new
      @user.id = 1
      @org.id = 2
    end

    it 'should add the requested role to a user' do
      expect(Role).to receive(:create!).exactly(:once).and_return(true)

      @org.grant_role('admin', @user)
    end
  end

  context 'when finding roles' do
    before(:each) do
      @user = User.create!(:name => 'user', :id => 1234)
      @root_org = Organization.create!(:id => 1, :organization_type => 'root')

      @org1 = Organization.create!(:id => 100, :organization_type => 'organization', :parent_organization_id => 1) # User Role
      allow(@org1).to receive(:parent_organization).and_return(@root_org)

      @child_org1 = Organization.create!(:id => 200, :organization_type => 'child_organization', :parent_organization_id => 100) # Denied
      @child_org2 = Organization.create!(:id => 201, :organization_type => 'child_organization', :parent_organization_id => 100) # Admin
      allow(@child_org1).to receive(:parent_organization).and_return(@org1)
      allow(@child_org2).to receive(:parent_organization).and_return(@org1)

      allow(@org1).to receive(:organizations).and_return([@child_org1, @child_org2])
      allow(@root_org).to receive(:organizations).and_return([@org1, @org2])
    end

    it 'should find role from parent' do
      role = double(Role, :user_id => 1234, :denied? => false)
      allow(@org1).to receive(:roles).exactly(:once).and_return([role])
      allow(@child_org2).to receive(:roles).exactly(:once).and_return([])

      expect(@child_org2.role_for(@user)).to eq(role)
    end

    it 'should override parent role with child role' do
      user_role = double(Role, :user_id => 1234, :denied? => false, :role_type => 'user')
      admin_role = double(Role, :user_id => 1234, :denied? => false, :role_type => 'admin')

      allow(@org1).to receive(:roles).exactly(:once).and_return([user_role])
      allow(@child_org2).to receive(:roles).exactly(:once).and_return([admin_role])

      expect(@child_org2.role_for(@user)).to eq(admin_role)
    end

    it 'should find role from root if parent and no parent role' do
      admin_role = double(Role, :user_id => 1234, :denied? => false, :role_type => 'admin')

      allow(@root_org).to receive(:roles).exactly(:once).and_return([admin_role])
      allow(@org1).to receive(:roles).exactly(:once).and_return([])
      allow(@child_org2).to receive(:roles).exactly(:once).and_return([])

      expect(@child_org2.role_for(@user)).to eq(admin_role)
    end

    it 'should allow sibling organization access when finding a denied role' do
      admin_role = double(Role, :user_id => 1234, :denied? => false, :role_type => 'admin')
      denied_role = double(Role, :user_id => 1234, :denied? => true, :role_type => 'denied')

      allow(@root_org).to receive(:roles).exactly(:once).and_return([admin_role])
      allow(@org1).to receive(:roles).exactly(:once).and_return([])
      allow(@child_org2).to receive(:roles).exactly(:once).and_return([denied_role])
      allow(@child_org1).to receive(:roles).exactly(:once).and_return([])

      expect(@child_org1.role_for(@user)).to eq(admin_role)
    end
  end
end