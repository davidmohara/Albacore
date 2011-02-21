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
    @msdeploy.source_type = @testdata.source_type
    @msdeploy.source = @testdata.source
    @msdeploy.target_type = @testdata.target_type
    @msdeploy.target = @testdata.target
  end
end
describe MSDeploy, 'when supplying values for deployment' do
  it_should_behave_like 'prepping deployment'
  it_should_behave_like 'include testdata'

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
    @msdeploy.system_command.should include("-dest:#{@testdata.target_type}=\"#{@testdata.target}\"")
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

describe MSDeploy, 'when adding skips' do
  it_should_behave_like 'prepping deployment'
  it_should_behave_like 'include testdata'

  before :all do
    @msdeploy.skips << {:objectName => 'dirPath', :absolutePath => 'Client'}
    @msdeploy.skips << {:objectName => 'dirPath', :absolutePath => 'Runtime'}
    @msdeploy.execute
  end

  it 'should include skip for deploy' do
    @msdeploy.system_command.should include("-skip:objectName=dirPath,absolutePath=\"Client\"")
  end
end

