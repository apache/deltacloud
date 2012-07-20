Then /^([a-z_]+) should have ([a-z_]+) set to$/ do |item, property, table|
  (xml/"/#{item}/#{property}").first.text.should == table.raw.flatten.first
end

