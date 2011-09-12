require 'rubygems'
require 'rspec'
# require 'ruby-debug'

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), ".."))
require 'lib/jsus'
Dir["spec/shared/*.rb"].each {|f| require f}

# cleanup compiled stuff
def cleanup
  `rm -rf spec/data/Basic/public`
  `rm -rf spec/data/OutsideDependencies/public`
  `rm -rf spec/tmp/`
end
