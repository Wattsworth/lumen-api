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

  describe 'validation' do
    it 'forbids an empty name' do
      element = DbElement.new(name: '')
      element.validate
      expect(element.errors[:name].any?).to be true
    end
    it 'name is unique in stream' do
      stream = DbStream.create(name: 'parent')
      elem1 = DbElement.create(name: 'shared', db_stream: stream)
      elem2 = DbElement.new(name: 'shared', db_stream: stream)
      elem2.validate
      expect(elem2.errors[:name].any?).to be true
      # but if element is in a different stream its ok
      stream2 = DbStream.create(name: 'other_parent')
      stream2.db_elements << elem2
      elem2.validate
      expect(elem2.errors[:name].any?).to be false
    end
  end

end
