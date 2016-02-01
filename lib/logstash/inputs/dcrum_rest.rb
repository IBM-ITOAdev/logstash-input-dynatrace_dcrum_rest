# encoding: utf-8                                                               
########################################################
#
# 
# Logstash mediation input for Dynatrace DC RUM REST API
#
########################################################
require "logstash/inputs/base"
require "logstash/namespace"
require "pathname"
require "stud/interval"
require "json"

class LogStash::Inputs::DCRUM_REST< LogStash::Inputs::Base
  config_name "dcrum_rest"
  milestone 1

  default :codec, "plain"

  config :hostname, :validate => :string, :required => true
  config :port, :validate => :number, :default => 80
  config :username, :validate => :string, :required => true
  config :password, :validate => :string, :required => true
  config :interval, :validate => :number, :default => 60
  config :input_file, :validate => :string, :required => true


  public
  def register 
    @cmd = "curl -H 'Content-Type: application/json' --user #@username:#@password -d\@#@input_file -X POST http://#@hostname:#@port/rest/dmiquery/getDMIData3"
  end

  public
  def call_api(queue)
    puts @cmd
    resp = `#@cmd`
    j = JSON.parse(resp)
    header = j["columnHeaderName"]
    # this part of error handling is still not reliable
    error = j["dmiServiceError"][0]["error"]
    if error == true
      puts "Error message received - " + error
      return
    end

    j["formattedData"].each { |record|
      event = LogStash::Event.new()
      event["type"] = "dcrum-rest"
      i = 0
      record.each { |c|
        event[header[i]] = c
        i = i + 1
      }
      decorate(event)
      queue << event
    }
  end

  public
  def run(queue)
    loop do
      call_api(queue)
      sleep @interval
    end
  end
  
  public
  def teardown
  end
  
end # class LogStash::Inputs::DCRUM_REST
