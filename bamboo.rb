# https://developer.atlassian.com/display/BAMBOODEV/Using+the+Bamboo+REST+APIs
# https://docs.atlassian.com/bamboo/REST/5.0-SNAPSHOT/
# append .json to get json
# http://172.19.1.2:8085/rest/api/latest/plan for plan list
# http://172.19.1.2:8085/rest/api/latest/plan/DOOM-BLD/branch for branch list in plan
# http://172.19.1.2:8085/rest/api/latest/result/DOOM-BLD5 for build list
# http://172.19.1.2:8085/rest/api/latest/result/DOOM-BLD5-9 for specific build details

require 'rest_client'
require 'json'
require 'serialport'

# controls the indicator. This never needs to be updated, as when I move to an LED ring it will still use the same mode command
class IndicatorLed

  def initialize
    @sp = SerialPort.new("COM31", 9600)
    # @sp.flow_control = SerialPort::NONE
  end

  def setMode(mode)
    if (mode == 'i' or mode == 'r' or mode == 'f' or mode == 's') then
      # puts "mode #{mode}"
      @sp.write("mode #{mode}\r")
    end
  end

  def close
    @sp.close
  end

end

# wraps the rest API for bamboo and removes some complexity from the other code
class Bamboo

  @@baseUrl = "http://172.19.1.2:8085/rest/api/latest/"
  @user = ''
  @password = ''
  @build = ''
  @lastBuild = ''

  def initialize(settings)
    @user = settings['bamboo_user']
    @password = settings['bamboo_password']
    @build = settings['build']
  end

  def request(href)
    JSON.parse(RestClient::Request.new({:user => @user, :password => @password, :method => "get", :url => href}).execute)
  end

  def getLatestBuild
    @lastBuild = requestRaw(@@baseUrl + "result/#{$settings['build']}.json?includeAllStates")['results']['result'].first
    @details = request(@lastBuild['link']['href'] + '.json')
    {
      'key' => @lastBuild['key'],
      'lifeCycleState' => @lastBuild['lifeCycleState'],
      'state' => @lastBuild['state'],
      'successfulTestCount' => @details['successfulTestCount'],
      'failedTestCount' => @details['failedTestCount']
    }
  end

end

# set default settings
settings = { 'serial_port' => 'COM31', 'build' => '', 'bamboo_user' => '', 'bamboo_password' => '' }

puts "Enter your username and password to start the monitor."
print "User: "
tmp = gets
if (tmp != 'tmp') then
  settings['bamboo_user']
end
print "Password: "
settings['bamboo_password'] = gets
print "Enter a build to monitor: "
settings['build'] = gets

indicator = IndicatorLed.new
bamboo = Bamboo.new(settings)

Signal.trap("SIGINT") do
  puts "Ctrl+C, stopping"
  indicator.close
  exit
end

lastKey = ''
loop do
  lastBuild = bamboo.getLatestBuild
  
  puts Time.now
  puts "Latest build is #{lastBuild['key']} with a status of #{lastBuild['state']}."
  puts "Lifecycle state is #{lastBuild['lifeCycleState']}"
  puts ""

  if (lastBuild['key'] != lastKey) then
    if (lastBuild['lifeCycleState'] == 'Finished') then
      puts "Tests Passed/Failed: #{lastBuild['successfulTestCount']}/#{lastBuild['failedTestCount']}"
      lastKey = lastBuild['key']

      if (lastBuild['state'] == "Successful") then
        puts "Build Succeeded."
        indicator.setMode('s')
      else
        puts "Build Failed. Womp womp."
        indicator.setMode('f')
      end
    elsif lastBuild['lifeCycleState'] == 'InProgress' then
      puts "Build is running"
      indicator.setMode('r')
    end
  end

  sleep(30)
end