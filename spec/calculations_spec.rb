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
  before(:each) do
    url = Thing::base_url
    resource = RestClient::Resource.new("#{url}/update")
    resource.post("<delete><query>id:[* TO *]</query></delete>", {:content_type => 'text/xml'})
    resource.post("<commit/>", {:content_type => 'text/xml'})

    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add60', :content => 'sample content 1'})
    thing.save

    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add61', :content => 'sample content 2'})
    thing.save
  end

  it "should count all records" do
    Thing.count.should == 2

    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add62', :content => 'sample content 2'})
    thing.save

    Thing.count.should == 3
  end

  it "should count records by query" do
    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add62', :content => 'test'})
    thing.save

    Thing.count('test').should == 1
    Thing.count('sample').should == 2
  end
end
