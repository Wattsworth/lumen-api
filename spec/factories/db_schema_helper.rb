# frozen_string_literal: true

# Helpers to produce database schemas that
# are usually returned by DbAdapter.schema
class DbSchemaHelper
  # schema data
  # rubocop:disable Metrics/MethodLength
  def entry(path, type: 'uint8_1', metadata: {}, stream_count: 0)
    data = {
      path: path,
      attributes: {
        data_type: type,
        start_time: 0,
        end_time: 0,
        total_rows: 0,
        total_time: 0 }.merge(metadata),
      streams: __build_streams(stream_count)
    }

  end
  # rubocop:enable Metrics/MethodLength

  # build stream hash for a file
  def __build_streams(count)
    return {} unless count > 0
    streams = []
    (0..(count - 1)).each do |i|
      streams <<
        { 'name': "stream#{i}",
          'units':  'unit',
          'column': i }
    end
    streams
  end
end
