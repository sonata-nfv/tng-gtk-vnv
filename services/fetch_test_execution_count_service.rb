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
require 'ostruct'
require 'json'
require 'tng/gtk/utils/logger'
require 'tng/gtk/utils/fetch'

class FetchTestExecutionCountService < Tng::Gtk::Utils::Fetch
  LOGGER=Tng::Gtk::Utils::Logger
  LOGGED_COMPONENT=self.name
  NO_REPOSITORY_URL_DEFINED_ERROR='The REPOSITORY_URL ENV variable needs to be defined and pointing to the Repository where to fetch test results'
  REPOSITORY_URL = ENV.fetch('REPOSITORY_URL', '')
  if REPOSITORY_URL == ''
    LOGGER.error(component:LOGGED_COMPONENT, operation:'initializing', message: NO_REPOSITORY_URL_DEFINED_ERROR)
    raise ArgumentError.new(NO_REPOSITORY_URL_DEFINED_ERROR) 
  end
  # /trr/test-suite-results/counter/:test_uuid
  self.site=REPOSITORY_URL+'/trr/test-suite-results/count'
  LOGGER.debug(component:LOGGED_COMPONENT, operation:'initializing', message: "self.site=#{self.site}")
  
  def self.call(params)
    msg='.'+__method__.to_s
    original_params = params.dup
    begin
      if params.key?(:uuid)
        uuid = params.delete :uuid
        uri = URI.parse("#{self.site}/#{uuid}")
        # mind that there cany be more params, so we might need to pass params as well
      else
        uri = URI.parse(self.site)
        uri.query = URI.encode_www_form(sanitize(params))
      end
      request = Net::HTTP::Get.new(uri)
      request['content-type'] = 'application/json'
      response = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(request)}
      case response
      when Net::HTTPSuccess
        body = response.read_body
        result = JSON.parse(body, quirks_mode: true, symbolize_names: true)
        return result
      when Net::HTTPNotFound
        return {} unless uuid.nil?
        return []
      else
         LOGGER.error(start_stop: 'STOP', component:self.name, operation:msg, message:"#{response.message}", status:'404')
        return nil
      end
    rescue Exception => e
    end
    nil
  end
  
end
