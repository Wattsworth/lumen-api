# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'DbElement' do
  describe 'object' do
    let(:db_element) { DbElement.new }
    specify { expect(db_element).to respond_to(:name) }
    specify { expect(db_element).to respond_to(:units) }
    specify { expect(db_element).to respond_to(:column) }
    specify { expect(db_element).to respond_to(:default_max) }
    specify { expect(db_element).to respond_to(:default_min) }
    specify { expect(db_element).to respond_to(:scale_factor) }
    specify { expect(db_element).to respond_to(:offset) }
    specify { expect(db_element).to respond_to(:plottable) }
    specify { expect(db_element).to respond_to(:discrete) }
  end
end
