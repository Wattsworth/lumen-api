# frozen_string_literal: true
# NOTE: This file is out of date!!
# Agent class for DbFolders
class InsertStream
  attr_accessor :error_msg

  def initialize(db_service:, db_builder:)
    @db_service = db_service
    @db_builder = db_builder
  end

  def insert_stream(folder:, stream:)
    @error_msg = ''
    return false unless __put_stream_in_folder(stream: stream, folder: folder)
    return false unless __make_path_for_stream(stream: stream, folder: folder)
    return false unless __create_stream_on_db(stream: stream)
    stream.save!
  end

  def __put_stream_in_folder(stream:, folder:)
    return true if folder.insert_stream(stream: stream)
    @error_msg = "could not add stream to folder #{folder.name}"
    false
  end

  def __make_path_for_stream(stream:, folder:)
    stream.path = @db_builder.build_path(folder_path: folder.path,
                                         stream_name: stream.name)
    true
  end

  def __create_stream_on_db(stream:)
    return true if @db_service.create_stream(stream)
    @error_msg = "from db_service: #{db_service.error_msg}"
    stream.path = '' # clear out the stream settings
    stream.folder = nil
    false
  end
end
