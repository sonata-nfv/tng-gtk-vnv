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

class FetchTestPlansService < Tng::Gtk::Utils::Fetch
  LOGGER=Tng::Gtk::Utils::Logger
  LOGGED_COMPONENT=self.name
  @@began_at = Time.now.utc
  LOGGER.info(component:LOGGED_COMPONENT, operation:'initializing', start_stop: 'START', message:"Started at #{@@began_at}")
  NO_PLANNER_URL_DEFINED_ERROR='The PLANNER_URL ENV variable needs to be defined and pointing to the Repository where to fetch test plans'
  PLANNER_URL = ENV.fetch('PLANNER_URL', '')
  if PLANNER_URL == ''
    LOGGER.error(component:LOGGED_COMPONENT, operation:'initializing', message: NO_PLANNER_URL_DEFINED_ERROR)
    raise ArgumentError.new(NO_PLANNER_URL_DEFINED_ERROR) 
  end
  self.site=PLANNER_URL
  LOGGER.info(component:LOGGED_COMPONENT, operation:'initializing', start_stop: 'STOP', message:"Ending at #{Time.now.utc}", time_elapsed: Time.now.utc - @@began_at)
end
