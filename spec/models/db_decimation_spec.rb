# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'DbDecimation' do
  describe 'object' do
    let(:db_decimation) { DbDecimation.new }
    specify { expect(db_decimation).to respond_to(:level) }
    specify { expect(db_decimation).to respond_to(:start_time) }
    specify { expect(db_decimation).to respond_to(:end_time) }
    specify { expect(db_decimation).to respond_to(:total_rows) }
    specify { expect(db_decimation).to respond_to(:total_time) }
  end
end
