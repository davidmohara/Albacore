require 'spec_helper'
require 'albacore/curl'

Albacore.configure do |config|
  config.log_level = :verbose
end

describe Curl, 'when supplying a source & target' do
  let :curl do
    curl = Curl.new
    curl.extend(SystemPatch)
    curl.disable_system = true
    curl.source = 'http://localhost/foo'
    curl.target = '/c/temp'
    curl.execute
    curl
  end

  it "should include source" do
    curl.system_command.should include("http://localhost/foo")
    curl.system_command.should include(" -o \"/c/temp\"")
  end
end

describe Curl, 'when supplying username & password' do
  let :curl do
    curl = Curl.new
    curl.extend(SystemPatch)
    curl.disable_system = true
    curl.source = ''
    curl.user = 'TestUser'
    curl.password = 'Password'
    curl.execute
    curl
  end

  it 'should include username & password' do
    curl.system_command.should include('-u TestUser:Password')
  end
end
