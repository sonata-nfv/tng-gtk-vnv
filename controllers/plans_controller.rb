## SONATA - Gatekeeper
##
## Copyright (c) 2015 SONATA-NFV [, ANY ADDITIONAL AFFILIATION]
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
## Neither the name of the SONATA-NFV [, ANY ADDITIONAL AFFILIATION]
## nor the names of its contributors may be used to endorse or promote 
## products derived from this software without specific prior written 
## permission.
## 
## This work has been performed in the framework of the SONATA project,
## funded by the European Commission under Grant number 671517 through 
## the Horizon 2020 and 5G-PPP programmes. The authors would like to 
## acknowledge the contributions of their colleagues of the SONATA 
## partner consortium (www.sonata-nfv.eu).
# frozen_string_literal: true
# encoding: utf-8
require 'sinatra'
require 'json'
require 'securerandom'
require 'tng/gtk/utils/logger'
require 'tng/gtk/utils/application_controller'

class PlansController < Tng::Gtk::Utils::ApplicationController
  LOGGER=Tng::Gtk::Utils::Logger
  LOGGED_COMPONENT=self.name
  @@began_at = Time.now.utc
  LOGGER.info(component:LOGGED_COMPONENT, operation:'initializing', start_stop: 'START', message:"Started at #{@@began_at}")

  ERROR_PLAN_NOT_FOUND="No plan with UUID '%s' was found"
  ERROR_EMPTY_BODY = <<-eos 
  The request was missing a body with (either):
     \tservice_uuid: the UUID of the service to be tested
     \ttest_uuid: the UUID of the test to be executed
  eos
  ERROR_MISSING_PARAMS = "Both 'confirmation_required' and 'test_uuid' must be present as query parameters"
  
  get '/?' do 
    msg='.'+__method__.to_s+' (many)'
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"params=#{params}")
    captures=params.delete('captures') if params.key? 'captures'
    result = FetchTestPlansService.call(symbolized_hash(params))
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"result=#{result}")
    halt 404, {}, {error: "No test plans fiting the provided parameters ('#{params}') were found"}.to_json if result.to_s.empty?
    halt 200, {}, result.to_json
  end
  
  get '/:plan_uuid/?' do 
    msg='.'+__method__.to_s+' (single)'
    captures=params.delete('captures') if params.key? 'captures'
    unless uuid_valid?(params['plan_uuid'])
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:"UUID '#{params['plan_uuid']} not valid", status: '400')
      halt_with_code_body(400, "UUID '#{params['plan_uuid']} not valid") 
    end
    result = FetchTestPlansService.call(uuid: params['plan_uuid'])
    halt_with_code_body(404, {error:"No test plans fiting the provided parameters ('#{params}') were found"}.to_json) if result == {}
    halt_with_code_body(200, result.to_json) 
  end

  options '/?' do
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET,DELETE'      
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With'
    halt 200
  end
  
  post '/?' do
    msg='.'+__method__.to_s

    body = request.body.read
    if body.empty?
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:ERROR_EMPTY_BODY.to_json, status: '400')
      halt_with_code_body(400, ERROR_EMPTY_BODY.to_json) 
    end
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"body=#{body}")
    
    begin
      params = JSON.parse(body, quirks_mode: true, symbolize_names: true)
      unless valid_parameters?(params)
        LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:"Parameters #{params} are not valid", status: '400')
        halt_with_code_body(400, {error: "Parameters #{params} are not valid"}.to_json) 
      end
      saved_request = CreateTestPlansService.call(params)
      if saved_request.nil? 
        LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:"Error creating the test plan")
        halt_with_code_body(400, {error: "Error creating the test plan"}.to_json) 
      end
      if (saved_request && saved_request.is_a?(Hash) && saved_request.key?(:error))
        LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:saved_request[:error])
        halt_with_code_body(404, {error: saved_request[:error]}.to_json) 
      end
      LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:saved_request.to_json, status: '201')
      halt_with_code_body(201, saved_request.to_json)
    rescue JSON::ParserError => e
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:"Error parsing params #{params}")
      halt_with_code_body(400, {error: "Error parsing params #{params}"}.to_json)
    end
  end
  
  post '/tests/?' do
    msg='.'+__method__.to_s
    # …/api/v3/tests/plans/tests?confirm_required=true&test_uuid=526bb462-736f-44ff-9ca3-ee393ca71567
    # .../api/v1/test-plans/tests
    
    if (params.fetch(:confirm_required).empty? || params.fetch(:test_uuid).empty?)
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:ERROR_MISSING_PARAMS, status: '400')
      halt_with_code_body(400, ERROR_MISSING_PARAMS.to_json) 
    end
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"params=#{params}")
    
    begin
      saved_request = CreateTestPlansService.call_with_params(params)
      if saved_request.nil? 
        LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:"Error creating the test plan")
        halt_with_code_body(400, {error: "Error creating the test plan"}.to_json) 
      end
      if (saved_request && saved_request.is_a?(Hash) && saved_request.key?(:error))
        LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:saved_request[:error])
        halt_with_code_body(404, {error: saved_request[:error]}.to_json) 
      end
      LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:saved_request.to_json, status: '201')
      halt_with_code_body(201, saved_request.to_json)
    rescue JSON::ParserError => e
      LOGGER.error(component:LOGGED_COMPONENT, operation:msg, message:"Error parsing params #{params}")
      halt_with_code_body(400, {error: "Error parsing params #{params}"}.to_json)
    end
  end
    
  private
  def uuid_valid?(uuid)
    return true if (uuid =~ /[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}/) == 0
    false
  end
  
  def symbolized_hash(hash)
    Hash[hash.map{|(k,v)| [k.to_sym,v]}]
  end
  
  def halt_with_code_body(code, body)
    halt code, {'Content-Type'=>'application/json', 'Content-Length'=>body.length.to_s}, body
  end
  
  def valid_parameters?(params)
    params.key?(:service_uuid) || params.key?(:test_uuid)
  end
  LOGGER.info(component:LOGGED_COMPONENT, operation:'initializing', start_stop: 'STOP', message:"Ended at #{Time.now.utc}", time_elapsed:"#{Time.now.utc-began_at}")
end
