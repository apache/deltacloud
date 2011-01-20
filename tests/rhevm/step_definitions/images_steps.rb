Then /^each ([A-Za-z_]+) should have properties set to$/ do |object, table|
  table.raw.each do |property|
    (xml/"*/#{object}/#{property[0]}").each do |element|
      element.text.should == property[1]
    end
  end
end

Then /^attribute ([a-z_]+) should be set to ([0-9A-Za-z_-]+)$/ do |property, value|
  (xml/"/#{@current_collection.gsub(/s$/, '')}").first[property.to_sym] == value
end

