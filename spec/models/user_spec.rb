require 'spec_helper'

describe User, :adapter => :postgresql do
  it "is found by name" do
    create(User).with_name!('Jack Johnson')

    User.filtered('Jack Johnson').should have(1).result
  end

  it "may not be found" do
    create(User).with_name!('Sigmund Freud')

    User.filtered('Jack Johnson').should be_empty
  end
end
