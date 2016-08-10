require File.expand_path '../../spec_helper.rb', __FILE__

describe ApplicationGeoTasks do
  it "does disallow accessing the index page" do
    get '/'
    expect(last_response.status).to eq(403)
  end

  it 'does allow 404 page' do
    get '/404page'
    expect(last_response.status).to eq(404)
  end
end