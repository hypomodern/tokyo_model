require 'rubygems'
require 'htmlentities'

tokyo_path = File.expand_path("#{File.dirname(__FILE__)}/..")
$LOAD_PATH.unshift tokyo_path unless $LOAD_PATH.include?(tokyo_path)

require 'tokyo_model'
require 'tokyo_tyrant'

Dir.glob(File.join(tokyo_path, "spec", "**", "*_examples.rb")).each do |example_file|
  require example_file
end

### Test Setup Stuff ###

$testing_cabinets = %w(/tmp/tokyo_model_table.tct /tmp/tokyo_model_cabinet.tdb)

def try_a_bunch(num, &blk)
  count = 0
  begin
    count += 1
    yield
  rescue
    sleep(0.5)
    retry unless count > num
  end
end

def start_tyrants
  $testing_cabinets.each do |db|
    `/usr/local/bin/ttserver -host #{db}_sock -port 0 -dmn -pid #{db}_pid  #{db}`
  end
  t = nil
  try_a_bunch(3) do 
    t = TokyoTyrant::Table.new("/tmp/tokyo_model_table.tct_sock", 0)
  end
  t.clear
  t.close
  
  try_a_bunch(3) do
    t = TokyoTyrant::DB.new("/tmp/tokyo_model_cabinet.tdb_sock", 0)
  end
  t.clear
  t.close
end

def stop_tyrants
  $testing_cabinets.each do |db|
    File.exist?("#{db}_pid") && Process.kill(9, File.read("#{db}_pid").strip.to_i)
    FileUtils.rm_f("#{db}_pid")
    FileUtils.rm_f("#{db}_sock")
  end
end

class Modell < TokyoModel::Base
  tokyo_store :pool => ["/tmp/tokyo_model_table.tct_sock"] # "127.0.0.1:12300", { "archive_1" => "/tmp/tokyo_model_table.tct_sock" }
end

class Robot < TokyoModel::Base
  tokyo_store :filter_fields => [:zagreb, :split, :venice]
end

class DataTable < TokyoModel::Base
  tokyo_store :use => :hash
end

Spec::Runner.configure do |config|
  config.after(:all) do
    stop_tyrants
  end
end
