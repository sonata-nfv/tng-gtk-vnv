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
require 'logger'
require 'securerandom'

class PlansController < ApplicationController

  ERROR_PLAN_NOT_FOUND="No plan with UUID '%s' was found"
  ERROR_EMPTY_BODY = <<-eos 
  The request was missing a body with (either):
     \tservice_uuid: the UUID of the service to be tested
     \ttest_uuid: the UUID of the test to be executed
  eos

  @@began_at = Time.now.utc
  settings.logger.info(self.name) {"Started at #{@@began_at}"}
  before { content_type :json}
  
  get '/?' do 
    msg='PlansController.get /plans (many)'
    captures=params.delete('captures') if params.key? 'captures'
    STDERR.puts "#{msg}: params=#{params}"
    result = FetchTestPlansService.call(symbolized_hash(params))
    STDERR.puts "#{msg}: result=#{result}"
    halt 404, {}, {error: "No test plans fiting the provided parameters ('#{params}') were found"}.to_json if result.to_s.empty? # covers nil
    halt 200, {}, result.to_json
  end
  
  get '/:plan_uuid/?' do 
    msg='PlansController.get /plans (single)'
    captures=params.delete('captures') if params.key? 'captures'
    STDERR.puts "#{msg}: params['plan_uuid']='#{params['plan_uuid']}'"
    result = FetchTestPlansService.call(uuid: params['plan_uuid'])
    STDERR.puts "#{msg}: result=#{result}"
    halt 404, {}, {error: ERROR_PLAN_NOT_FOUND % params['plan_uuid']}.to_json if result == {}
    halt 200, {}, result.to_json
  end

  options '/?' do
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET,DELETE'      
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With'
    halt 200
  end
  
  post '/?' do
    msg='PlansController.post /plans'

    body = request.body.read
    halt_with_code_body(400, ERROR_EMPTY_BODY.to_json) if body.empty?
    
    begin
      params = JSON.parse(body, quirks_mode: true, symbolize_names: true)
      halt_with_code_body(400, ERROR_EMPTY_BODY.to_json) unless valid_parameters?(params)
      saved_request = CreateTestPlansService.call(params)
      STDERR.puts "#{msg}: saved_request='#{saved_request.inspect}'"
      halt_with_code_body(400, {error: "Error creating the test plan"}.to_json) if saved_request.nil? 
      halt_with_code_body(404, {error: saved_request[:error]}.to_json) if (saved_request && saved_request.is_a?(Hash) && saved_request.key?(:error))
      halt_with_code_body(201, saved_request.to_json)
    rescue JSON::ParserError => e
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
end
