require File.expand_path '../../spec_helper.rb', __FILE__
require 'json'

describe ApplicationGeoTasks do
  
  context 'statistics' do
    before do
      @manager = User.create(auth_token: '--manager-token--', role: 'manager', name: 'Budd')
      @driver = User.create(auth_token: '--driver-token--', role: 'driver', name: 'Elle')
      FactoryGirl.create_list(:task, 10)
      FactoryGirl.create_list(:task, 10, :assigned, driver: @driver)
      FactoryGirl.create_list(:task, 10, :done, driver: @driver)
      Task.create_indexes
    end

    let(:headers_with_token){
      {
        'CONTENT_TYPE' => 'application/json',
        'ACCEPT' => 'application/json',
        'AUTH_TOKEN' => '--manager-token--'
      }
    }

    it 'does available statistics for manager' do
      post '/stat', {}, headers_with_token
      expect(last_response).to be_ok
    end

    it 'does show stat by drivers' do
      post "/stat", {}, headers_with_token
      res_stats = JSON.parse(last_response.body)
      expect(res_stats['by_drivers'].count).to eq(1)
    end

    it 'does show count processed tasks for drivers' do
      post "/stat", {}, headers_with_token
      res_stats = JSON.parse(last_response.body)
      expect(res_stats['by_drivers'].first['processed_tasks']).to eq(10)
    end

    it 'does show count total tasks' do
      post "/stat", {}, headers_with_token
      res_stats = JSON.parse(last_response.body)
      expect(res_stats['total']['tasks']).to eq(30)
    end

  end

end