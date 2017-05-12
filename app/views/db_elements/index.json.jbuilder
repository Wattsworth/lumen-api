
  json.array! @elements do |element|
    json.extract! element, *DbElement.json_keys
  end
