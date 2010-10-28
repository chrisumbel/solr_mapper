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

require File.dirname(__FILE__) + '/base'
require 'rest_client'

describe SolrMapper::SolrDocument do
  before(:all) do
    url = Thing::base_url
    resource = RestClient::Resource.new("#{url}/update")
    resource.post("<delete><query>id:[* TO *]</query></delete>", {:content_type => 'text/xml'})
    resource.post("<commit/>", {:content_type => 'text/xml'})

    url = Stuff::base_url
    resource = RestClient::Resource.new("#{url}/update")
    resource.post("<delete><query>id:[* TO *]</query></delete>", {:content_type => 'text/xml'})
    resource.post("<commit/>", {:content_type => 'text/xml'})

    stuff = Stuff.new({:_id => '04787560-bc23-012d-817c-60334b2add63', :name => 'stuff 1'})
    stuff.save

    stuff = Stuff.new({:_id => '04787560-bc23-012d-817c-60334b2add64', :name => 'stuff 2'})
    stuff.save

    stuff = Stuff.new({:_id => '04787560-bc23-012d-817c-60334b2add65', :name => 'stuff 3'})
    stuff.save

    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add60', :content => 'A',
            :stuff_id => ['04787560-bc23-012d-817c-60334b2add63', '04787560-bc23-012d-817c-60334b2add64']})
    thing.save

    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add61', :content => 'A',
            :stuff_id => ['04787560-bc23-012d-817c-60334b2add63']})
    thing.save

    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add62', :content => 'B',
            :stuff_id => ['04787560-bc23-012d-817c-60334b2add65']})
    thing.save
  end

  it "should lookup related object by facet" do
    Thing.stuffs_facet('*:*').each_pair do |stuff, count|
      puts "#{stuff.name} had a count of #{count}"
    end
  end
end

