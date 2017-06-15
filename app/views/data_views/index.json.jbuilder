
  home_view_id = current_user.home_data_view_id
  json.array! @data_views do |view|
    json.extract! view, *DataView.json_keys
    json.owner current_user.id==view.user_id
    json.home home_view_id == view.id
  end
