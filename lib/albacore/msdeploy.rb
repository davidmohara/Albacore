require 'albacore/albacoretask'
require 'albacore/config/msdeployconfig'

class MSDeploy
  include Albacore::Task
  include Albacore::RunCommand
  include Configuration::MSDeploy

  attr_accessor :verb, :source, :source_type, :target, :target_type
  attr_array :skips

  def initialize
    super()
    @skips = []
    update_attributes msdeploy.to_hash
  end

  def execute
    check_values
    
    result = run_command "MSDeploy", build_params

    fail_with_message 'MSDeploy failed. See Build log for Detail' if !result
  end

  def check_values
    fail_with_message 'verb cannot be nil' if @verb.nil?
  end

  def build_params
    params = []
    params << "-verb:#{@verb}"
    params << "-source:#{@source_type}=\"#{@source}\""
    params << "-dest:#{@target_type}=\"#{@target}\""
    skips.each{|hash|
      skip = hash.flatten
      params << "-skip:#{skip[0]}=#{skip[1]},#{skip[2]}=\"#{skip[3]}\""
    }
    params
  end

end
