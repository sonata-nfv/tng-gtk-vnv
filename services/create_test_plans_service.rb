## Copyright (c) 2015 SONATA-NFV, 2017 5GTANGO [, ANY ADDITIONAL AFFILIATION]
## ALL RIGHTS RESERVED.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##
## Neither the name of the SONATA-NFV, 5GTANGO [, ANY ADDITIONAL AFFILIATION]
## nor the names of its contributors may be used to endorse or promote
## products derived from this software without specific prior written
## permission.
##
## This work has been performed in the framework of the SONATA project,
## funded by the European Commission under Grant number 671517 through
## the Horizon 2020 and 5G-PPP programmes. The authors would like to
## acknowledge the contributions of their colleagues of the SONATA
## partner consortium (www.sonata-nfv.eu).
##
## This work has been performed in the framework of the 5GTANGO project,
## funded by the European Commission under Grant number 761493 through
## the Horizon 2020 and 5G-PPP programmes. The authors would like to
## acknowledge the contributions of their colleagues of the 5GTANGO
## partner consortium (www.5gtango.eu).
# encoding: utf-8
require 'net/http'
require 'uri'
require 'json'
require 'tng/gtk/utils/logger'

class CreateTestPlansService 
  LOGGER=Tng::Gtk::Utils::Logger
  LOGGED_COMPONENT=self.name
  NO_PLANNER_URL_DEFINED_ERROR='The PLANNER_URL ENV variable needs to be defined and pointing to the V&V Planner component, where to request new test plans'
  PLANNER_URL = ENV.fetch('PLANNER_URL', '')
  if PLANNER_URL == ''
    LOGGER.error(component:LOGGED_COMPONENT, operation:'initializing', message: NO_PLANNER_URL_DEFINED_ERROR)
    raise ArgumentError.new(NO_PLANNER_URL_DEFINED_ERROR) 
  end
  @@site=PLANNER_URL #+'/test-plans'
  LOGGER.error(component:LOGGED_COMPONENT, operation:'initializing', message: "@@site=#{@@site}")
  
  # POST /api/v1/schedulers/services, with body {"test_uuid": “0101”}
  # POST /api/v1/schedulers/tests, with body {"service_uuid": “9101”}

  def self.call(params)
    msg='.'+__method__.to_s
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message: "params=#{params}")
    uri = URI.parse(params.key?(:service_uuid) ? @@site+'/services' : @@site+'/tests')

    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri, {'Content-Type': 'text/json'})
    request.body = params.to_json

    # Send the request
    begin
      response = http.request(request)
      LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message: "response=#{response}")
      case response
      when Net::HTTPSuccess, Net::HTTPCreated
        body = response.body
        LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message: "#{response.code} body=#{body}")
        return JSON.parse(body, quirks_mode: true, symbolize_names: true)
      else
        LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message: "#{response.message}")
        return {error: "#{response.message}"}
      end
    rescue Exception => e
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message: e.message)
      STDERR.puts "%s - %s: %s" % [Time.now.utc.to_s, msg, ]
    end
    nil
  end

  def self.call_with_params(params)
    msg='.'+__method__.to_s
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message: "params=#{params}")
    uri = URI.parse(@@site+'/tests')

    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.path.concat("?confirmRequired=#{params[:confirm_required]}&test_uuid=#{params[:test_uuid]}"))
    request['Content-Type'] = 'application/json'

    # Send the request
    begin
      response = http.request(request)
      LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message: "response=#{response}")
      case response
      when Net::HTTPSuccess, Net::HTTPCreated
        body = response.body
        LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message: "#{response.code} body=#{body}")
        return JSON.parse(body, quirks_mode: true, symbolize_names: true)
      else
        LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message: "#{response.message}")
        return {error: "#{response.message}"}
      end
    rescue Exception => e
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message: e.message)
      STDERR.puts "%s - %s: %s" % [Time.now.utc.to_s, msg, ]
    end
    nil
  end
  
  # PUT /api/v1/test-plans/{uuid}
  def self.update(params)
    msg='.'+__method__.to_s
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message: "params=#{params}")
    uri = URI.parse(@@site+"/#{params['plan_uuid']}")

    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Put.new(uri.path.concat("?status=#{params['status']}"))
    STDERR.puts ">>>>> uri=#{uri.inspect} #{uri.path.concat("?status=#{params['status']}")}"
    request['Content-Type'] = 'application/json'

    # Send the request
    begin
      response = http.request(request)
      LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message: "response=#{response}")
      case response
      when Net::HTTPSuccess, Net::HTTPCreated
        body = response.body
        LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message: "#{response.code} body=#{body}")
        return JSON.parse(body, quirks_mode: true, symbolize_names: true)
      else
        LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message: "#{response.message}")
        return {error: "#{response.message}"}
      end
    rescue Exception => e
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message: e.message)
    end
    nil
  end
end


