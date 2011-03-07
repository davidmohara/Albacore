require 'albacore/albacoretask'
require 'albacore/config/msdeployconfig'

class MSDeploy
  include Albacore::Task
  include Albacore::RunCommand
  include Configuration::MSDeploy

  attr_accessor :verb, :temp_agent, :dry_run
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

  def add_source(source, type = nil, options = {})
    @source = add_target('source', source, type, options)
  end

  def add_destination(target, type, options = {})
    @destination = add_target('dest', target, type, options)
  end

  def attach_user(user, pwd)
    @user_creds = ",userName=#{user},password=#{pwd}"
  end

  def skip_dir(dir)
    skips << { :objectName => 'dirPath', :absolutePath => dir }
  end

  def skip_file(file)
    skips << { :objectName => 'filePath', :absolutePath => file }
  end

  def check_values
    fail_with_message 'verb cannot be nil' if @verb.nil?
  end

  def build_params
    params = []
    params << '-whatif' if @dry_run
    params << "-verb:#{@verb}"
    params << @source
    params << @destination unless @destination.nil?
    params << @user_creds unless @user_creds.nil?
    last = params.pop
    last = last + ',tempAgent=true' unless @temp_agent.nil?
    params << last

    skips.each{|hash|
      skip = hash.flatten
      params << "-skip:#{skip[0]}=#{skip[1]},#{skip[2]}=\"#{skip[3]}\""
    }
    params
  end

  protected
  def add_target(type, target, target_type, options = {})
    if target_type.nil?
      response = "-#{type}:#{target}"
    else
      response = "-#{type}:#{target_type}=\"#{target}\""
    end
    options.each do |opt|
      response = response + ",#{opt[0]}=#{opt[1]}"
    end
    response
  end
end
