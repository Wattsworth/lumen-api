require 'rails_helper'

RSpec.describe 'DbStream' do
  describe 'object' do
    let(:db_stream) { DbStream.new }
    specify { expect(db_stream).to respond_to(:name) }
    specify { expect(db_stream).to respond_to(:units) }
    specify { expect(db_stream).to respond_to(:column) }
    specify { expect(db_stream).to respond_to(:default_max) }
    specify { expect(db_stream).to respond_to(:default_min) }
    specify { expect(db_stream).to respond_to(:scale) }
    specify { expect(db_stream).to respond_to(:offset) }
  end
end
