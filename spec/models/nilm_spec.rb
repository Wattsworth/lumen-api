# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Nilm' do
  describe 'object' do
    let(:nilm) { Nilm.new }
    specify { expect(nilm).to respond_to(:name) }
    specify { expect(nilm).to respond_to(:description) }
    specify { expect(nilm).to respond_to(:url) }
    specify { expect(nilm).to respond_to(:db) }
  end
end
