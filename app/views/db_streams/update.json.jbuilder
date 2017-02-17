# frozen_string_literal: true
json.data do
  json.partial! 'db_streams/db_stream',
                db_stream: @db_stream
end

json.partial! 'helpers/messages', service: @service
