require 'spec_helper'
require 'albacore/msdeploy'
require 'albacore/config/msdeployconfig'
require 'msdeploytestdata'

shared_examples_for 'prepping deployment' do
  before :all do
    @testdata = MSDeployTestData.new
    @msdeploy = @testdata.msdeploy
    @logger = StringIO.new
    @msdeploy.log_device = @logger
    @log_data = @logger.string
    @msdeploy.disable_system = true
  end
end

shared_examples_for 'include testdata' do
  before :all do
    @msdeploy.verb = :sync
    @msdeploy.add_source(@testdata.source, @testdata.source_type)
    @msdeploy.add_destination(@testdata.destination, @testdata.destination_type)
  end
end

shared_examples_for 'full setup' do
  it_should_behave_like 'prepping deployment'
  it_should_behave_like 'include testdata'
end

describe MSDeploy, 'when supplying values for deployment' do
  it_should_behave_like 'full setup'

  before :all do
    @msdeploy.execute
  end

  it 'should include verb for deploy' do
    @msdeploy.system_command.should include('-verb:sync')
  end

  it 'should include source for deploy' do
    @msdeploy.system_command.should include("-source:#{@testdata.source_type}=\"#{@testdata.source}\"")
  end

  it 'should include destination for deploy' do
    @msdeploy.system_command.should include("-dest:#{@testdata.destination_type}=\"#{@testdata.destination}\"")
  end
end

describe MSDeploy, 'when deploying with no verb' do
  it_should_behave_like 'prepping deployment'

  before :all do
    @msdeploy.extend(FailPatch)
    @msdeploy.execute
  end

  it 'should require a verb' do
    @log_data.should include('verb cannot be nil')
  end
end

describe MSDeploy, 'when adding skips for directory' do
  it_should_behave_like 'full setup'

  before :all do
    @msdeploy.skip_dir 'Client'
    @msdeploy.skip_dir 'Runtime'
  end

  it 'should add to skips collection' do
    @msdeploy.skips.length.should be(2)
  end
  
  it 'should include skip in command line' do
    @msdeploy.execute
    @msdeploy.system_command.should include("-skip:objectName=dirPath,absolutePath=\"Client\"")
  end
end

describe MSDeploy, 'when adding skips for file' do
  it_should_behave_like 'full setup'

  before :all do
    @msdeploy.skip_file 'test.bat'
  end

  it 'should add file to skips collection' do
    @msdeploy.skips.length.should be(1)
  end

  it 'should include skip in command line' do
    @msdeploy.execute
    @msdeploy.system_command.should include("-skip:objectName=filePath,absolutePath=\"test.bat\"")
  end
end

describe MSDeploy, 'when specifying a user' do
  it_should_behave_like 'full setup'

  before :all do
    @msdeploy.attach_user 'TestUser', 'Password'
    @msdeploy.execute
  end

  it 'should include user in command line' do
    @msdeploy.system_command.should include(",userName=TestUser,password=Password")
  end
end

describe MSDeploy, 'when using temp agent' do
  it_should_behave_like 'full setup'
  
  it 'should include temp agent params' do
    @msdeploy.temp_agent = true
    @msdeploy.execute
    @msdeploy.system_command.should include(',tempAgent=true')
  end
end

describe MSDeploy, 'when specifying source with no type' do
  it_should_behave_like 'prepping deployment'

  before :all do
    @msdeploy.verb = :getSystemInfo
    @msdeploy.add_source 'webServer'
    @msdeploy.execute
  end

  it 'should handle single parameter expansion' do
    @msdeploy.system_command.should include('-source:webServer')
  end
end

describe MSDeploy, 'when specifying source with options' do
  it_should_behave_like 'prepping deployment'

  before :all do
    @msdeploy.verb = :getSystemInfo
  end

  it 'should handle single option' do
    @msdeploy.add_source 'webServer', nil, { :foo => 'bar' }
    @msdeploy.execute

    @msdeploy.system_command.should include('-source:webServer,foo=bar')
  end

  it 'should handle multiple options' do
    @msdeploy.add_source 'webServer', nil, { :foo => 'bar', :baz => 'bull' }
    @msdeploy.execute

    @msdeploy.system_command.should include('-source:webServer,foo=bar,baz=bull')
  end
end

describe MSDeploy, 'when wanting to test run a command' do
  it_should_behave_like 'full setup'

  before :all do
    @msdeploy.dry_run = true
    @msdeploy.execute
  end

  it 'should include whatif parameter' do
    @msdeploy.system_command.should include('-whatif')
  end
end

describe MSDeploy, 'when grabbing info from remote web server' do
  it_should_behave_like 'prepping deployment'

  before :all do
    @msdeploy.verb = :getSystemInfo
    @msdeploy.add_source('webServer', nil, { :computerName => 'test2.localhost' })
    @msdeploy.temp_agent = true
    @msdeploy.execute
  end

  it 'should include params' do
    @msdeploy.system_command.should include('-verb:getSystemInfo -source:webServer,computerName=test2.localhost,tempAgent=true')
  end
end
