# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DbsController, type: :controller do
  describe 'GET show' do
    it 'lists the database contents' do
      allow(Db).to receive(:find).and_return(Db.new)
      get :show, id: 1
      expect(Db).to have_received(:find)
      expect(response.header['Content-Type']).to include('application/json')
    end
  end
end
