require File.expand_path '../../spec_helper.rb', __FILE__

describe ApplicationGeoTasks do
  it "does allow accessing the index page" do
    get '/'
    expect(last_response).to be_ok
  end

  it 'does allow 404 page' do
    get '/404page'
    expect(last_response.status).to eq(404)
  end
end