
@data = @nilms[:admin].map{|nilm| {nilm: nilm, role: 'admin'}} +
        @nilms[:owner].map{|nilm| {nilm: nilm, role: 'owner'}} +
        @nilms[:viewer].map{|nilm| {nilm: nilm, role: 'viewer'}}
# frozen_string_literal: true
json.array!(@data) do |d|
    nilm = d[:nilm]; role=d[:role]
    json.extract! nilm, *Nilm.json_keys
    json.role role
    json.available nilm.db.available
end
