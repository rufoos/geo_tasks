require File.expand_path '../../spec_helper.rb', __FILE__

describe ApplicationGeoTasks do
  before do
    @user = User.create(auth_token: '--token--', name: 'Elle', role: 'driver')
  end
  
  it 'does authenticate user by token in header' do
    headers = {
      'AUTH_TOKEN' => '--token--'
    }
    get '/', {}, headers
    expect(current_user.name).to eq(@user.name)
  end

  it 'does authenticate user by token in params' do
    get '/', token: '--token--'
    expect(current_user.name).to eq(@user.name)
  end

  it 'does not authenticate user by wrong token' do
    headers = {
      'AUTH_TOKEN' => '--wrong-token--'
    }
    get '/', {}, headers
    expect(current_user).to be_nil
    expect(last_response.status).to eq(403)
  end

end