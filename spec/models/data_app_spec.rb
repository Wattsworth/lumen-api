require 'rails_helper'

RSpec.describe DataApp, type: :model do
  let(:data_app) { DataApp.new }
  specify { expect(data_app).to respond_to(:name) }
  specify { expect(data_app).to respond_to(:joule_id) }
  specify { expect(data_app).to respond_to(:nilm) }

  it 'creates app url' do
    nilm = create(:nilm, url:"http://nilm/joule")
    app = create(:data_app, joule_id: 4, nilm: nilm)
    expect(app.url).to eq "http://nilm/joule/app/4/"
  end
end
