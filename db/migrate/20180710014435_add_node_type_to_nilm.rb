class AddNodeTypeToNilm < ActiveRecord::Migration[5.2]
  def change
    add_column :nilms, :node_type, :string, default: false, null: false
  end
end
