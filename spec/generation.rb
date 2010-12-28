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
    class Thing
      auto_generate_id
    end

    url = Thing::base_url
    resource = RestClient::Resource.new("#{url}/update")
    resource.post("<delete><query>id:[* TO *]</query></delete>", {:content_type => 'text/xml'})
    resource.post("<commit/>", {:content_type => 'text/xml'})

    thing = Thing.new({:name => 'A', :content => 'sample content 1'})
    thing.save
  end

  it "should have an auto generated id" do
    thing = Thing.first()
    thing._id.should_not be(nil)
  end

  it "shouldn't let the id change after successive saves" do
    thing = Thing.first()
    old_id = thing._id
    thing.save()
    thing._id.should == old_id
  end

  after(:all) do
    Thing.class_eval("@auto_generate_id = false")
  end
end
