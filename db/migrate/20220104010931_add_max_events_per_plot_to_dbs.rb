class AddMaxEventsPerPlotToDbs < ActiveRecord::Migration[6.0]
  def change
    add_column :dbs, :max_events_per_plot, :integer, default: 200
  end
end
