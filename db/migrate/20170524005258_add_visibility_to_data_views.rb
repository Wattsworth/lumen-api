class AddVisibilityToDataViews < ActiveRecord::Migration[5.1]
  def change
    add_column :data_views, :visibility, :string
  end
end
