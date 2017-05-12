# frozen_string_literal: true

# Create a Data View
class CreateDataView
  include ServiceStatus
  attr_reader :data_view

  def run(data_view_params, stream_ids, user)
    #retrieve nilms for every stream
    begin
      db_ids = DbStream
        .find(stream_ids)
        .pluck(:db_id)
        .uniq
      nilm_ids = Db
        .find(db_ids)
        .pluck(:nilm_id)
    rescue ActiveRecord::RecordNotFound
      self.add_errors(['invalid stream_ids'])
      return self
    end

    @data_view = DataView.create(data_view_params)
    @data_view.nilm_ids = nilm_ids
    @data_view.owner = user
    unless @data_view.save
      self.add_errors(@data_view.errors.full_messages)
      return self
    end
    self.set_notice('created data view')
    self
  end
end
