class CreateDataViews < ActiveRecord::Migration[5.0]
  def change
    create_table :data_views do |t|
      t.integer :user_id
      t.string :name
      t.string :description
      t.text :image
      t.text :redux_json
      t.timestamps
    end
    create_table :data_views_nilms, id: false do |t|
      t.integer :data_view_id
      t.integer :nilm_id
    end
    add_index :data_views_nilms, :nilm_id
    add_index :data_views_nilms, :data_view_id

  end
end
