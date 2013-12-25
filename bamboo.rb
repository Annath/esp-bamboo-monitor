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

  def initialize(port)
    @sp = SerialPort.new(port, 9600)
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

  @baseUrl = ""
  @user = ''
  @password = ''
  @build = ''
  @lastBuild = ''

  def initialize(settings)
    @baseUrl = settings['baseUrl']
    @user = settings['username']
    @password = settings['password']
    @build = settings['build']
  end

  def request(href)
    JSON.parse(RestClient::Request.new({:user => @user, :password => @password, :method => "get", :url => href}).execute)
  end

  def getLatestBuildInfo
    url = @baseUrl + "result/#{@build}.json?includeAllStates"
    @lastBuild = request(url)['results']['result'].first
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

# load settings
settings = JSON.parse(IO.read("config.json"))

# set up physical indicator and bamboo connection
indicator = IndicatorLed.new(settings['serial_port'])
bamboo = Bamboo.new(settings['bamboo'])

# make sure we can close gracefully
Signal.trap("SIGINT") do
  puts "Closing serial port..."
  indicator.close
  puts "Finished"
  exit
end

# set up our loop to scan
lastKey = ''
loop do
  lastBuild = bamboo.getLatestBuildInfo
  
  puts ""
  puts Time.now
  puts "Latest build is #{lastBuild['key']} with a status of #{lastBuild['state']}."
  puts "Lifecycle state is #{lastBuild['lifeCycleState']}"

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

  sleep(settings['pollPeriod'])
end