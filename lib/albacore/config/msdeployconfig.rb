require 'ostruct'
require 'albacore/config/netversion'
require 'albacore/support/openstruct'

module Configuration
  module MSDeploy
    include Albacore::Configuration
    include Configuration::NetVersion

    def self.msdeployconfig
      @msdeployconfig ||= OpenStruct.new.extend(OpenStructToHash).extend(MSDeploy)
    end

    def msdeploy
      config = MSDeploy.msdeployconfig
      yield(config) if block_given?
      config
    end

    def self.included(mod)
      self.msdeployconfig.use :net40
    end

    def use(netversion)
      self.command = File.join(get_net_version(netversion), "MSDeploy.exe")
    end
  end
end

