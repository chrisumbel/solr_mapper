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

describe SolrMapper::SolrDocument do
  before(:all) do
    url = Thing::base_url
    resource = RestClient::Resource.new("#{url}/update")
    resource.post("<delete><query>id:[* TO *]</query></delete>", {:content_type => 'text/xml'})
    resource.post("<commit/>", {:content_type => 'text/xml'})

    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add60', :name => 'A', :content => 'sample content 1'})
    thing.save
    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add61', :name => 'B', :content => 'sample content 2'})
    thing.save
  end

  it "should return the first item with no query" do
    thing = Thing.first()
    thing.content.should_not be(nil)
  end

  it "should return the first item with a search string" do
    thing = Thing.first('*:*', {:sort => 'name desc'})
    thing.content.should_not be(nil)
    thing.content.should == 'sample content 2'
  end
end
