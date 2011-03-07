require 'albacore/msdeploy'

class MSDeployTestData
  
  attr_accessor :source, :source_type, :msdeploybuild_path, :verb, :destination, :destination_type
  
  def initialize()
    @source_type = 'contentPath'
    @source = File.join(File.dirname(__FILE__), "zip")
    @msdeploy_path = "C:\\Windows/Microsoft.NET/Framework/v4.0.30319/MSDeploy.exe"
    
    setup_output
  end
  
  def setup_output
    @destination_type = 'package'
    @destination = File.join(File.dirname(__FILE__), "TestSolution", "TestSolution", "bin", "#{@config_mode}", "deploy.zip")
    File.delete @destination if File.exist? @destination
  end
  
  def msdeploy(path_to_msdeploy=nil)
    @msdeploy = MSDeploy.new
    
    if (path_to_msdeploy)
      @msdeploy_path = path_to_msdeploy
      @msdeploy.command = path_to_msdeploy
    end
    
    @msdeploy.extend(SystemPatch)
    @msdeploy
  end
  
end
