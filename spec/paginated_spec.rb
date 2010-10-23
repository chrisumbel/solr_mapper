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

    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add60', :content => 'sample content 1'})
    thing.save
    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add61', :content => 'sample content 2'})
    thing.save
    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add62', :content => 'sample content 3'})
    thing.save
    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add63', :content => 'sample content 4'})
    thing.save
    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add64', :content => 'sample content 5'})
    thing.save
    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add65', :content => 'sample content 6'})
    thing.save
    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add66', :content => 'sample content 7'})
    thing.save
    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add67', :content => 'sample content 8'})
    thing.save
    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add68', :content => 'sample content 9'})
    thing.save
    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add69', :content => 'sample content 10'})
    thing.save
    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add70', :content => 'sample content 11'})
    thing.save
    thing = Thing.new({:_id => '04787560-bc23-012d-817c-60334b2add11', :content => 'sample content 12'})
    thing.save
  end

  it "should have correct default counts" do
    page = Thing.paginate('*:*')
    page.per_page.should == 10
    page.total_entries.should == 12
    page.total_pages.should == 2
    page.current_page.should == 1
  end

  it "should have correct specified counts by search string" do
    page1 = Thing.paginate('*:*', :rows => 5)
    page2 = Thing.paginate('*:*', :rows => 5, :page => 2)
    page3 = Thing.paginate('*:*', :rows => 5, :page => 3)

    page1.total_pages.should == 3
    page2.total_pages.should == 3
    page3.total_pages.should == 3
    page1.count.should == 5
    page2.count.should == 5
    page3.count.should == 2
  end

  it "should have correct specified counts by query" do
    page1 = Thing.paginate({'*' => '*'}, {:rows => 5})
    page2 = Thing.paginate({'*' => '*'}, {:rows => 5, :page => 2})
    page3 = Thing.paginate({'*' => '*'}, {:rows => 5, :page => 3})

    page1.total_pages.should == 3
    page2.total_pages.should == 3
    page3.total_pages.should == 3
    page1.count.should == 5
    page2.count.should == 5
    page3.count.should == 2
  end

  it "should have a small page 2 bisect a page 1 twice its size by search string" do
    big_page1 = Thing.paginate('*:*')
    small_page2 = Thing.paginate('*:*', :rows => 5, :page => 2)

    big_page1[5]._id.should == small_page2[0]._id
  end

  it "should have a small page 2 bisect a page 1 twice its size by query" do
    big_page1 = Thing.paginate('*' => '*')
    small_page2 = Thing.paginate({'*' => '*'}, {:rows => 5, :page => 2})

    big_page1[5]._id.should == small_page2[0]._id
  end
end

