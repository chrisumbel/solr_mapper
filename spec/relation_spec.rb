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


    url = Widget::base_url
    resource = RestClient::Resource.new("#{url}/update")
    resource.post("<delete><query>id:[* TO *]</query></delete>", {:content_type => 'text/xml'})
    resource.post("<commit/>", {:content_type => 'text/xml'})

    
    stuff = Stuff.new({:_id => '04787560-bc23-012d-817c-60334b2add63', :name => 'stuff 1'})
    stuff.save

    stuff = Stuff.new({:_id => '04787560-bc23-012d-817c-60334b2add64', :name => 'stuff 2'})
    stuff.save

    stuff = Stuff.new({:_id => '04787560-bc23-012d-817c-60334b2add65', :name => 'stuff 3'})
    stuff.save

    widget = Widget.new({:_id => '04787560-bc23-012d-817c-60334b2add66', :name => 'widget 1'})
    widget.save

    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add60', :content => 'sample content 1',
            :stuff_id => ['04787560-bc23-012d-817c-60334b2add63', '04787560-bc23-012d-817c-60334b2add64'],
            :widget_id => '04787560-bc23-012d-817c-60334b2add66'})
    thing.save

    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add61', :content => 'sample content 2',
            :stuff_id => ['04787560-bc23-012d-817c-60334b2add65']})
    thing.save


  end

  it "should recall has_many relations" do
    thing = Thing.find('04787560-bc23-012d-817c-60334b2add60')

    thing.stuffs.count.should == 2
    thing.stuffs[0].name.should == 'stuff 1'
    thing.stuffs[1].name.should == 'stuff 2'

    thing = Thing.find('04787560-bc23-012d-817c-60334b2add61')

    thing.stuffs.count.should == 1
    thing.stuffs[0].name.should == 'stuff 3'
  end

  it "should recall has_one relations" do
    thing = Thing.find('04787560-bc23-012d-817c-60334b2add60')
    thing.widget.should_not be(nil)
    thing.widget.name.should == 'widget 1'
  end

  it "should store has_many relations by object by direct assignment" do
    thing = Thing.find('04787560-bc23-012d-817c-60334b2add60')

    stuff1 = Stuff.new({:_id => '04787560-bc23-012d-817c-60334b2add80', :name => 'brand new stuff 1'})
    stuff1.save

    stuff2 = Stuff.new({:_id => '04787560-bc23-012d-817c-60334b2add81', :name => 'brand new stuff 2'})
    stuff2.save

    sleep 0.1

    thing.stuffs = [stuff1, stuff2]

    thing.save()

    sleep 0.1

    thing = Thing.find('04787560-bc23-012d-817c-60334b2add60')

    thing.stuffs.count.should == 2
    thing.stuffs[0]._id.should == '04787560-bc23-012d-817c-60334b2add80'
    thing.stuffs[1]._id.should == '04787560-bc23-012d-817c-60334b2add81'
  end

  it "should store has_many relations by object by left shift" do
    thing = Thing.find('04787560-bc23-012d-817c-60334b2add61')

    stuff = Stuff.new({:_id => '04787560-bc23-012d-817c-60334b2add81', :name => 'brand new stuff'})
    stuff.save()

    sleep 0.1

    thing.stuffs << stuff
    thing.save()

    sleep 0.1

    thing = Thing.find('04787560-bc23-012d-817c-60334b2add61')
    thing.stuffs.count.should == 2
  end

  it "should be able to delete from a relation" do
    thing = Thing.find('04787560-bc23-012d-817c-60334b2add61')

    ct = thing.stuffs.count
    
    thing.stuffs.delete(thing.stuffs[0])    
    thing.save()

    sleep 0.1

    thing = Thing.find('04787560-bc23-012d-817c-60334b2add61')
    thing.stuffs.count.should == ct - 1
  end

  it "shouldn't destroy a child when deleting it" do
    thing = Thing.find('04787560-bc23-012d-817c-60334b2add61')

    stuff = Stuff.new({:_id => '04787560-bc23-012d-817c-60334b2add80', :name => 'brand new stuff 1'})
    stuff.save

    thing.stuffs << stuff

    stuff_id = stuff._id

    thing.stuffs.delete(stuff)
    thing.save()

    sleep 0.1

    stuff = Stuff.find(stuff_id)
    stuff.should_not be(nil)
  end

  it "should be able to destroy a relation" do
    thing = Thing.find('04787560-bc23-012d-817c-60334b2add61')

    stuff = Stuff.new({:_id => '04787560-bc23-012d-817c-60334b2add80', :name => 'brand new stuff 1'})
    stuff.save

    thing.stuffs << stuff

    stuff_id = stuff._id

    thing.stuffs.destroy(stuff)
    thing.save()

    sleep 0.1

    stuff = Stuff.find(stuff_id)
    stuff.should be(nil)
  end
end
