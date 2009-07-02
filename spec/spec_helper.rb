require 'rubygems'

tokyo_path = File.expand_path("#{File.dirname(__FILE__)}/..")
$LOAD_PATH.unshift tokyo_path unless $LOAD_PATH.include?(tokyo_path)

require 'tokyo_model'

Dir.glob(File.join(tokyo_path, "spec", "**", "*_examples.rb")).each do |example_file|
  require example_file
end

### Test Setup Stuff ###

$testing_cabinets = %w(/tmp/tokyo_model_table.tct /tmp/tokyo_model_cabinet.tdb)

def start_tyrants
  $testing_cabinets.each do |db|
    `/usr/local/bin/ttserver -host #{db}_sock -port 0 -dmn -pid #{db}_pid  #{db}`
  end
end

class Modell < TokyoModel::Base
  tokyo_store :pool => ["/tmp/tokyo_model_table.tct_sock"]
end

class Robot < TokyoModel::Base
  tokyo_store :filter_fields => [:zagreb, :split, :venice]
end

Spec::Runner.configure do |config|
  config.after(:all) do
    $testing_cabinets.each do |db|
      File.exist?("#{db}_pid") && Process.kill(9, File.read("#{db}_pid").strip.to_i)
      FileUtils.rm_f("#{db}_pid")
      FileUtils.rm_f("#{db}_sock")
    end
  end
end
