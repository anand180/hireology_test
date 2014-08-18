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

  context 'when creating organizations' do
    before(:each) do
    end

    it 'should only allow one root organization to exist' do
      testing_org = Organization.new

      allow(testing_org).to receive(:organization_type).and_return('root')
      allow(Organization).to receive(:find_by_organization_type).with('root').and_return(double(Organization))

      expect { (testing_org.save!) }.to raise_error(RuntimeError, 'There can be only one root org')
    end

    it 'should ensure organizations of organization_type == organization have the root org as their parent' do
      testing_org = Organization.new

      allow(testing_org).to receive(:organization_type).and_return('organization')
      allow(testing_org).to receive(:parent_organization_id).and_return(1234)

      allow(Organization).to receive(:find_by_organization_type_and_id).with('root', 1234).and_return(nil)
      expect { (testing_org.save!) }.to raise_error(RuntimeError, 'All organizations must have the root organization as their parent')

      allow(Organization).to receive(:find_by_organization_type_and_id).with('root', 1234).and_return(double(Organization))
      expect { (testing_org.save!) }.to_not raise_error
    end

    it 'should not allow an organization to have a child_organization as a parent' do
      child_org = Organization.new
      testing_org = Organization.new

      allow(child_org).to receive(:organization_type).and_return('child_organization')
      allow(testing_org).to receive(:parent_organization).and_return(child_org)

      expect { (testing_org.save!) }.to raise_error(RuntimeError, 'Child organizations cannot have children')
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
       allow_any_instance_of(Organization).to receive(:check_tiers).and_return(nil)
       @user = User.create!(:name => 'user', :id => 1234)
       @root_org = Organization.create!(:id => 1, :organization_type => 'root')

       @org1 = Organization.create!(:id => 100, :organization_type => 'organization', :parent_organization_id => 1)
       allow(@org1).to receive(:parent_organization).and_return(@root_org)

       @child_org1 = Organization.create!(:id => 200, :organization_type => 'child_organization', :parent_organization_id => 100)
       @child_org2 = Organization.create!(:id => 201, :organization_type => 'child_organization', :parent_organization_id => 100)
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