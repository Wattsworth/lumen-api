# frozen_string_literal: true

# Service class for DbFolders
class DbFolderService
  attr_accessor :error_msg

  def initialize(db_service:, db_builder:)
    @db_service = db_service
    @db_builder = db_builder
  end

  def insert_file(folder:, file:)
    @error_msg = ''
    return false unless __put_file_in_folder(file: file, folder: folder)
    return false unless __make_path_for_file(file: file, folder: folder)
    return false unless __create_file_on_db(file: file)
    file.save!
  end

  def __put_file_in_folder(file:, folder:)
    return true if folder.insert_file(file: file)
    @error_msg = "could not add file to folder #{folder.name}"
    false
  end

  def __make_path_for_file(file:, folder:)
    file.path = @db_builder.build_path(folder_path: folder.path,
                                       file_name: file.name)
    true
  end

  def __create_file_on_db(file:)
    return true if @db_service.create_file(file)
    @error_msg = "from db_service: #{db_service.error_msg}"
    file.path = ''
    file.folder = nil
    false
  end
end
