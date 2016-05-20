# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'DbStream' do
  describe 'object' do
    let(:db) { Db.new }
    specify { expect(db).to respond_to(:url) }
    specify { expect(db).to respond_to(:root_folder) }
  end
end
