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
require 'rake'
require 'echoe'

Echoe.new('solr_mapper', '0.1.9') do |p|
  p.description    = "Object Document Mapper for the Apache Foundation's Solr search platform"
  p.url            = "http://github.com/skunkworx/solr_mapper"
  p.author         = "Chris Umbel"
  p.email          = "chrisu@dvdempire.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.runtime_dependencies = ['rest-client', 'uuid', 'will_paginate', 'activesupport']
  p.development_dependencies = ["rspec >=2.0"]
end