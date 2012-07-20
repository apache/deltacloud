Then /^([a-z]+) properties should be$/ do |type, table|
  properties = table.raw.flatten
  (xml/"hardware_profiles/hardware_profile/property[@kind='#{type}']").each do |name|
    properties.delete(name[:name])
  end
  properties.should be_empty
end