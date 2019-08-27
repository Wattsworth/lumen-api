class RefactorJouleApp < ActiveRecord::Migration[5.2]
  def change
    rename_column :interface_auth_tokens, :joule_module_id, :data_app_id
    rename_column :data_apps, :url, :joule_id
  end
end
