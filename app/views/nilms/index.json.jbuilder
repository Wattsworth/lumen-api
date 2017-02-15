json.admin do
  json.array! @nilms[:admin],  partial: 'nilms/nilm', as: :nilm
end
json.owner do
  json.array! @nilms[:owner],  partial: 'nilms/nilm', as: :nilm
end
json.viewer do
  json.array! @nilms[:viewer], partial: 'nilms/nilm', as: :nilm
end
