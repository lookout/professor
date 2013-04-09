require 'tempfile'
require 'stringio'
require 'rake'
require 'rake/tasklib'

RSpec.configure do |config|

  def capture_stdout &block
    real_stdout, $stdout = $stdout, StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = real_stdout
  end
end

# Keep a reference to all tempfiles so they are not garbage collected until the
# process exits.
$tempfiles = []

def make_file(content)
  tempfile = Tempfile.new('cane')
  $tempfiles << tempfile
  tempfile.print(content)
  tempfile.flush
  tempfile.path
end

def in_tmp_dir(&block)
  Dir.mktmpdir do |dir|
    Dir.chdir(dir, &block)
  end
end

RSpec::Matchers.define :have_violation do |label|
  match do |check|
    violations = check.violations
    violations.length.should == 1
    violations[0][:label].should == label
  end
end

RSpec::Matchers.define :have_no_violations do |label|
  match do |check|
    violations = check.violations
    violations.length.should == 0
  end
end