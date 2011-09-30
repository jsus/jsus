ROOT = File.expand_path(File.dirname(__FILE__) + "/../../")
DATA_DIR = ROOT + "/features/data"
TMP_DIR = DATA_DIR + "/tmp"
JSUS_CLI_PATH = ROOT + "/bin/jsus"
require 'rspec/expectations'
require 'fileutils'
After do
  # FileUtils.rm_rf(TMP_DIR)
end
