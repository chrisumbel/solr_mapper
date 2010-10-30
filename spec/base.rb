# Copyright 2010 The Skunkworx.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rubygems'
require 'uuid'
require 'rest_client'
require File.dirname(__FILE__) + '/../lib/solr_mapper'

include SolrMapper

class Stuff
  include SolrDocument
  bind_service_url 'http://localhost:8080/solr_stuff'
  limit_page_size 10

  belongs_to :thing
end

class Widget
  include SolrDocument
  bind_service_url 'http://localhost:8080/solr_widget'
  limit_page_size 10

  belongs_to :thing
end

class Thing
  include SolrDocument
  bind_service_url 'http://localhost:8080/solr_thing'
  limit_page_size 10

  has_many :stuffs
  has_one :widget
end
