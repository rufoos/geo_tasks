require File.expand_path '../../spec_helper.rb', __FILE__

describe User do
  let(:user) { User.create(auth_token: '--token--', name: 'Elle', role: 'driver') }
  
  it '.authenticate_by_token' do
    expect(user.name).to eq(User.authenticate_by_token('--token--').name)
  end

end