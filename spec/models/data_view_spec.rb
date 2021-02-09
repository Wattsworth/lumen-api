require 'rails_helper'

RSpec.describe DataView, type: :model do
  let(:data_view) { DataView.new }
  specify { expect(data_view).to respond_to(:name) }
  specify { expect(data_view).to respond_to(:description) }
  specify { expect(data_view).to respond_to(:image) }
  specify { expect(data_view).to respond_to(:redux_json) }
  specify { expect(data_view).to respond_to(:owner) }
  specify { expect(data_view).to respond_to(:nilms) }
  specify { expect(data_view).to respond_to(:visibility) }

  it 'is deleted when nilm is destroyed' do
      nilm1 = create(:nilm)
      nilm2 = create(:nilm)
      owner = create(:user)
      dv = create(:data_view, owner: owner)
      dv.nilms = [nilm1, nilm2]
      expect(DataView.count).to eq 1
      expect(DataViewsNilm.count).to eq 2
      nilm1.destroy
      expect(DataView.count).to eq 0
      expect(DataViewsNilm.count).to eq 0
  end

  it 'does not delete nilm when destroyed' do
    nilm1 = create(:nilm)
    nilm2 = create(:nilm)
    owner = create(:user)
    dv1 = create(:data_view, owner: owner)
    dv2 = create(:data_view, owner: owner)
    dv1.nilms = [nilm1, nilm2]
    dv2.nilms = [nilm1 , nilm2]
    expect(DataView.count).to eq 2
    expect(DataViewsNilm.count).to eq 4
    dv1.destroy
    expect(DataView.count).to eq 1
    expect(DataViewsNilm.count).to eq 2
    expect(Nilm.count).to eq 2
  end
end
