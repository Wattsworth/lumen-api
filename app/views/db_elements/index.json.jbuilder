
  json.array! @elements do |element|
    json.extract! element, *DbElement.json_keys
    json.path element.name_path
  end
