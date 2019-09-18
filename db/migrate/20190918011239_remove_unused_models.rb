class RemoveUnusedModels < ActiveRecord::Migration[5.2]
  def change
    drop_table :joule_modules
    drop_table :joule_pipes
  end
end
