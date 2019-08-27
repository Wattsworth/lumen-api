class CreateDataApps < ActiveRecord::Migration[5.2]
  def change
    create_table :data_apps do |t|
      t.string :name
      t.string :url
      t.belongs_to :nilm, index: true
      t.timestamps
    end
  end
end
