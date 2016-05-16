# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'DbFolder' do
  describe 'object' do
    let(:db_folder) { DbFolder.new }
    specify { expect(db_folder).to respond_to(:name) }
    specify { expect(db_folder).to respond_to(:description) }
    specify { expect(db_folder).to respond_to(:subfolders) }
    specify { expect(db_folder).to respond_to(:files) }
  end
end
