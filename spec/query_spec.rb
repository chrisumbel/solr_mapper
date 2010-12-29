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

    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add60', :content => 'sample content 1', :name => 'sample item 1'})
    thing.save

    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add61', :content => 'sample content 2', :name => 'sample item 2'})

    thing.save
  end

  it "should return results" do
    Thing.query("*:*").count.should > 0
  end

  it "should have identical query and search methods until search is removed" do
    Thing.query("*:*").count.should == Thing.search("*:*").count
    Thing.query("name:content").count.should == Thing.search("name:content").count
  end  

  it "should save new and recall" do
    id = UUID.new().generate()

    thing = Thing.new
    thing._id = id
    thing.content = 'sample content'

    thing.save()

    saved_thing = Thing.find(id)
    saved_thing.content.should == thing.content
  end

  it "should be able to change data" do
    id = '04787560-bc23-012d-817c-60334b2add60'

    thing = Thing.find(id)
    thing.content << ' additional content'
    thing.save()

    saved_thing = Thing.find(id)
    saved_thing.content.should == thing.content
  end

   it "should be able to delete" do
    id = '04787560-bc23-012d-817c-60334b2add61'

    thing = Thing.find(id)
    thing.destroy

    deleted_thing = Thing.find(id)
    deleted_thing.should be(nil)
   end

  it "should be able to update a subset of attributes" do
    id = '04787560-bc23-012d-817c-60334b2add60'
    new_content = 'changed content'

    thing = Thing.find(id)
    name = thing.name
    thing.update_attributes({:content => new_content})

    saved_thing = Thing.find(id)
    saved_thing.content.should == new_content # make sure the content HAS changed
    saved_thing.name.should == name # make sure the name HASN'T changed
  end
end

