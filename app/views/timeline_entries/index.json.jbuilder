json.array! @timeline_entries do |entry|
  json.partial! entry.post
end
