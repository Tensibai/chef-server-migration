#!/opt/opscode/embedded/bin/ruby
require 'optparse'
require 'pp'
require 'json'

options = {}
options[:log] = "0"
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on('-d', '--directory NAME', 'Cookbooks path name') { |v| options[:dir] = File.absolute_path(v) }
  opts.on('-l', '--loglevel [LEVEL]', 'Log level 0 (default) or 1 to see candidates cookbook when constraint fail') { |v| options[:log] = v || "1" }

end.parse!

raise("No directory specified") if options[:dir].nil?

puts "Scanning #{options[:dir]} for cookbooks dependencies"

cookbooks = Hash.new { Array.new } 
tobeworkedon = Hash.new { Hash.new { Hash.new { { "constraints" => nil, "other_versions" => Array.new } } } }
Dir.glob("#{options[:dir]}/[^.]*/").each do |d|
  name,version= File.basename(d).scan(/(.*)-((?:\d+[.]?)+)$/).first
  if(!name.nil?) then
    cookbooks.merge!( name => cookbooks[name].concat([version]))
  else
    puts "Problem with #{d}, unparseable cookbook name"
  end
end
Dir.glob("#{options[:dir]}/**/metadata.rb") do |m|
  cookbook,constraint = File.read(m).scan(/^depends\s*['"]([^'"]+)['"]\s*,\s*['"]([~><=]{1,2} (?:\d+[.]?)+)['"]/).first
  next if(cookbook.nil?)
  
  found=false
  cookbooks[cookbook].each do |v|
    break if (found = Gem::Dependency.new('',constraint).match?('',v) == true) 
  end

  if (!found) then 
    invalidck,version = File.basename(File.dirname(m)).scan(/(.*)-((?:\d+[.]?)+)$/).first
    tobeworkedon.merge!( 
      invalidck => tobeworkedon[invalidck].merge!( 
                     version => tobeworkedon[invalidck][version].merge!( 
                                  { 
                                    cookbook => { 
                                      "constraint" => constraint, 
                                      "other_versions" => cookbooks[cookbook] 
                                    } 
                                  }
                                )
                   )
    )
  end
end
tobeworkedon.sort.each do |c,vs|
  puts "#{c} in versions #{tobeworkedon[c].keys} 
  Others available versions: #{cookbooks[c].reject { |v| tobeworkedon[c].keys.include?(v) }}"
  if( options[:log] > "0") then
    vs.each do |_,constraints|
      puts "  Constraints:"
      constraints.each do |name,props|
        puts "#{props['constraint']} #{name} unsatified. Other versions: #{props['other_versions'].join}"
      end
    end
  end
  puts " "
end

#pp tobeworkedon
