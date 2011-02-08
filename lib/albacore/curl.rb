require 'albacore/albacoretask'

class Curl
  include Albacore::Task
  include Albacore::RunCommand

  attr_accessor :source, :target, :user, :password

  def initialize
    @command = 'curl'
    super()
  end

  def execute
    fail_with_message 'Source cannot be empty' if @source.nil?
    command_parameters = []
    command_parameters << @source
    command_parameters << "-o \"#{@target}\""
    command_parameters << "-u #{@user}:#{@password}" unless @user.nil? || @password.nil?

    result = run_command 'Curl', command_parameters.join(' ')
    fail_with_message 'Curl task failed. See Build Log for Detail.' if !result
  end
end
