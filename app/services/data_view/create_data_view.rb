# frozen_string_literal: true

# Create a Data View
class CreateDataView
  include ServiceStatus
  attr_reader :data_view

  def run(data_view_params, stream_ids, user, home_view=false)



    # normal data view
    @data_view = DataView.new(data_view_params.merge({owner: user}))

    #resize thumbnail because client can upload any dimension
    if(!@data_view.image.nil? && !@data_view.image.empty?)
      metadata = "data:image/png;base64,"
      base64_string = @data_view.image[metadata.size..-1]
      blob = Base64.decode64(base64_string)
      image = MiniMagick::Image.read(blob)
      image.resize('200x100!')
      image.format 'png'
      scaled_image_bytes = image.to_blob
      @data_view.image = metadata+Base64.strict_encode64(scaled_image_bytes)
    end

    # build nilm associations for permissions
    begin
      #retrieve nilms for every stream in this view
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
    unless @data_view.save
      self.add_errors(@data_view.errors.full_messages)
      return self
    end
    @data_view.nilm_ids = nilm_ids
    user.update(home_data_view: @data_view) if home_view
    self.set_notice('created data view')
    self
  end
end
