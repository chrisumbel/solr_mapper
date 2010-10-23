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

include SolrMapper

describe SolrDocument do
  before(:all) do
    url = Thing::base_url
    resource = RestClient::Resource.new("#{url}/update")
    resource.post("<delete><query>id:[* TO *]</query></delete>", {:content_type => 'text/xml'})
    resource.post("<commit/>", {:content_type => 'text/xml'})

    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add60', :name => 'A', :content => 'sample content 1'})
    thing.save
  end

  it "should match its ID to to_param" do
    thing = Thing.first()
    thing._id.should == thing.to_param()
  end
end