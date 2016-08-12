require File.expand_path '../../spec_helper.rb', __FILE__

describe Task do
  let(:task) { Task.create(pickup_coord: [1.1, 2.2], delivery_coord: [2.2, 3.3], title: 'Pussy Wagon car') }
  
  it 'new task does have status :new' do
    expect(task.status).to eq('new')
  end

end