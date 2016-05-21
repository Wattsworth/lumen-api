# frozen_string_literal: true

# Helpers to produce database schemas that
# are usually returned by DbAdapter.schema
class DbSchemaHelper
  # schema data
  def entry(path, type: 'uint8_1', metadata: {})
    { path: path, type: type,
      start_time: 0, end_time: 0,
      total_rows: 0, total_time: 0,
      metadata: metadata
    }
  end
end
