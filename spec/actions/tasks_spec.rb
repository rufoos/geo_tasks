require File.expand_path '../../spec_helper.rb', __FILE__
require 'json'

describe ApplicationGeoTasks do
  
  context 'manager' do
    before do
      @manager = User.create(auth_token: '--manager-token--', role: 'manager', name: 'Budd')
    end

    let(:headers){ { 'AUTH_TOKEN' => '--manager-token--' } }

    it 'does manager available access for create task' do
      post '/task', { task: { pickup_coord: { lat: 1.1, lng: 1.1 }, delivery_coord: { lat: 2.2, lng: 2.2 }, title: 'Hatory Hanzo sword' } }, headers
      expect(last_response).to be_ok
    end

    it 'does can create a task' do
      post '/task', { task: { pickup_coord: { lat: 1.1, lng: 1.1 }, delivery_coord: { lat: 2.2, lng: 2.2 }, title: 'Hatory Hanzo sword' } }, headers
      task = Task.last
      expect(task.title).to eq('Hatory Hanzo sword')
    end

    it 'does can delete a task' do
      FactoryGirl.create(:task)
      last_new_task_id = Task.newest.last.id
      delete '/task', { task: { id: last_new_task_id } }, headers
      expect(Task.find(last_new_task_id)).to be_falsey
    end

    it 'does get error if no params then delete task' do
      delete '/task', {}, headers
      expect(last_response.status).to eq(400)
      expect(last_response.body).to include('missing some parameter')
    end

    it 'does get error if no ID in params then delete task' do
      delete '/task', { task: {} }, headers
      expect(last_response.status).to eq(400)
      expect(last_response.body).to include('missing some parameter')
    end

    it 'does cannot change task status' do
      FactoryGirl.create(:task)
      last_new_task_id = Task.newest.last.id
      put '/delivered', { task: { id: last_new_task_id } }, headers
      expect(last_response.status).to eq(403)
    end

  end

  context 'driver' do
    before do
      @driver = User.create(auth_token: '--driver-token--', role: 'driver', name: 'Elle')
    end

    let(:headers){ { 'AUTH_TOKEN' => '--driver-token--' } }

    it 'does can pickup task' do
      FactoryGirl.create(:task)
      new_task = Task.newest.last
      get '/pickup', { task: { id: new_task.id } }, headers
      assigned_task = Task.find(new_task.id)
      expect(assigned_task.driver).to eq(@driver)
    end

    it 'does finish task' do
      FactoryGirl.create(:task, :assigned, driver: @driver)
      assigned_task = Task.assigned_for_driver(@driver).last
      put '/delivered', { task: { id: assigned_task.id } }, headers
      finished_task = Task.find(assigned_task.id)
      expect(finished_task.status).to eq('done')
    end

    it 'does can get nearby task list' do
      tasks = FactoryGirl.create_list(:task, 10)
      Task.create_indexes
      get '/nearby', { coord: { lat: 60.050182, lng: 30.443045 } }, headers
      res_tasks = JSON.parse(last_response.body)
      expect(res_tasks.count).to eq(1)
      expect(res_tasks.first['id']).to eq(tasks.first.id.to_s)
    end

    it 'does cannot create task' do
      post '/task', { task: { pickup_coord: { lat: 2.2, lng: 2.5 }, delivery_coord: { lat: 3.3, lng: 4.4 }, title: 'Something' } }, headers
      expect(last_response.status).to eq(403)
    end

    it 'does cannot delete task' do
      FactoryGirl.create(:task)
      last_new_task_id = Task.newest.last.id
      delete '/task', { task: { id: last_new_task_id } }, headers
      expect(last_response.status).to eq(403)
    end
  end

end