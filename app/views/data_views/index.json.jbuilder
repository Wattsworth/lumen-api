
  json.array! @data_views do |view|
    json.extract! view, *DataView.json_keys
    json.owner current_user==view.owner
    json.home current_user.home_data_view_id == view.id
  end
