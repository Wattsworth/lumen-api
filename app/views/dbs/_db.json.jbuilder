json.extract! db, :id, :url, :size_total, :size_db,
                  :size_other, :version, :max_points_per_plot,
                  :available
json.contents do
  json.partial! "db_folders/db_folder", db_folder: @db.root_folder,
                                        shallow: false
end
