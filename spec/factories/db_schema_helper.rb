# frozen_string_literal: true

# Helpers to produce database schemas that
# are usually returned by DbAdapter.schema
class DbSchemaHelper
  # schema data
  def entry(path, metadata: {}, element_count: 1)
    {
      path: path,
      attributes: {
        data_type: "float32_#{element_count}",
        start_time: 0,
        end_time: 0,
        total_rows: 0,
        total_time: 0
      }.merge(metadata),
      elements: __build_elements(element_count)
    }
  end

  # build element hash for a file
  def __build_elements(count)
    return {} unless count.positive?
    elements = []
    (0..(count - 1)).each do |i|
      elements <<
        {
          'name': "element#{i}",
          'units':  'unit',
          'column': i
        }
    end
    elements
  end
end
