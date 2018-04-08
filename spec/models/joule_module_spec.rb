require 'rails_helper'

RSpec.describe JouleModule, type: :model do

  describe 'object' do
    let(:joule_module) {JouleModule.new}
    specify { expect(joule_module).to respond_to(:name) }
    specify { expect(joule_module).to respond_to(:description) }
    specify { expect(joule_module).to respond_to(:exec_cmd) }
    specify { expect(joule_module).to respond_to(:web_interface) }
    specify { expect(joule_module).to respond_to(:status) }
    specify { expect(joule_module).to respond_to(:joule_id) }
  end

  it 'removes pipes when destroyed' do
    @joule_module = JouleModule.create
    @joule_module.joule_pipes << JoulePipe.create(
      db_stream: DbStream.create,
      direction: 'output')
    expect(JouleModule.find_by_id(@joule_module.id).pipes.count).to equal 1
    @joule_module.destroy
    expect(JouleModule.count).to equal 0
    # deletes associated pipes
    expect(JoulePipe.count).to equal 0
    # does not delete the streams
    expect(DbStream.count).to equal 2

  end


  end
