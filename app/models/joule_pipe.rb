class JoulePipe < ApplicationRecord
  belongs_to :joule_module
  belongs_to :db_stream
end
