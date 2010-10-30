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
  it "should build a url with only opts passed in" do
    Thing.build_qs({:rows => 5, :q => '*'}).should == 'rows=5&q=*'
    Thing.build_qs({:rows => 5, :start => 10, :q => '*'}).should == 'rows=5&start=10&q=*'
    Thing.build_qs({:rows => 5, :start => 10, :sort => 'id desc', :q => '*'}).should == 'rows=5&start=10&sort=id desc&q=*'
    Thing.build_qs({:start => 10, :sort => 'id desc', :q => '*'}).should == 'start=10&sort=id desc&q=*'
  end

  it "should build a full url with the configured base, path and query string" do
    Thing.build_url("select", {:rows => 5, :q => '*'}).should == "#{Thing.base_url}/select?rows=5&q=*"
  end

  it "should build a url without a querystring" do
    Thing.build_url("update").should == "#{Thing.base_url}/update"
  end

  it "should build URLs accepting hashes for the environment" do
    ENV['RAILS_ENV'] = 'test'

    class AnotherThing
      include SolrDocument
      bind_service_url({
              :development => 'http://somehost/solr_thing',
              :test => 'http://localhost:8080/solr_thing',
              :production => 'http://somehost/solr_thing'
      })
    end

    AnotherThing.build_url('select').should == 'http://localhost:8080/solr_thing/select'
  end

  it "should build URLs accepting hashes for the environment via string keys" do
    ENV['RAILS_ENV'] = 'test'

    class AnotherThing
      include SolrDocument
      bind_service_url({
              'development' => 'http://somehost/solr_thing',
              'test' => 'http://localhost:8080/solr_thing',
              'production' => 'http://somehost/solr_thing'
      })
    end

    AnotherThing.build_url('select').should == 'http://localhost:8080/solr_thing/select'
  end
end

