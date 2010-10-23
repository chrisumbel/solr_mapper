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

module SolrMapper
  module SolrDocument
    def self.included(base)
      base.extend(ClassMethods)
      base.solr_fields = []
      base.has_many_relationships = {}
    end

    module ClassMethods
      attr_accessor :base_url
      attr_accessor :per_page
      attr_accessor :solr_fields

      def execute_read(opts)
        eval(RestClient.get(build_url('select', opts.merge(:wt => 'ruby'))))
      end

      def execute_write(data, opts = nil)
        send_update(data, opts)

        # make an xml commit message Solr will be happy with
        commit_message = ''
        builder = Builder::XmlMarkup.new(:target => commit_message, :indent => 2)
        builder.commit('waitFlush' => true, 'waitSearcher' => true)

        send_update(commit_message)
      end

      def build_url(path, opts = nil)
        qs = build_qs(opts)
        qs = '?' + qs unless qs.empty?

        URI::escape("#{base_url}/#{path}#{qs}")
      end

      def build_qs(opts)
        uri = ''

        if opts
          opts.each_pair do |k, v|
            uri << "#{k}=#{v}&"
          end
        end

        uri.chop
      end

      def search_counted(search_string, opts = {})
        response = execute_read(opts.merge(:q => search_string))

        return map(response), response['response']['numFound']
      end

      def search(search_string, opts = {})
        search_counted(search_string, opts)[0]
      end

      def query(values, opts = {})
        results, count = query_counted(values, opts)
        results
      end

      def query_counted(values, opts = {})
        search_string = ''

        values.each_pair do |k, v|
          search_string << "#{k}:#{v} "
        end

        search_counted(search_string.chop, opts)
      end

      def find(id)
        result = query(:id => id)
        return result[0] if result.count > 0
      end

      # return will_paginate pages for search queries
      def paginate(search_query, opts = {})
        opts[:page] ||= 1
        opts[:page] = opts[:page].to_i if opts[:page].respond_to?(:to_i)
        opts[:rows] ||= per_page || 10
        opts[:start] = (opts[:page] - 1) * opts[:rows]

        WillPaginate::Collection.create(opts[:page], opts[:rows]) do |pager|
          if search_query.kind_of?(Hash)
            results, count = query_counted(search_query, opts)
          else
            results, count = search_counted(search_query.to_s, opts)
          end

          if results
            results.compact!

            pager.total_entries = count
            pager.replace(results)
            return pager
          end          
        end
      end

      protected
      def map(docs)
        objs = []

        docs['response']['docs'].each do |doc|
          obj = self.new

          doc.each_pair do |k, v|
            k = '_id' if k.to_s == 'id'

            unless obj.class.method_defined?(k)
              class_eval { attr_accessor k }
              solr_fields << k.to_s unless solr_fields.include?(k.to_s)
            end
            
            obj.instance_variable_set("@#{k}", v)
          end

          objs << obj
        end

        objs
      end

      def send_update(data, opts = nil)
        solr_resource = RestClient::Resource.new(build_url('update', opts))
        solr_resource.post(data, {:content_type => 'text/xml'})
      end
    end

    attr_accessor :_id

    def method_missing(m, *args, &block)
      method_name = m.to_s
      assignment = method_name.match(/\=$/)
      method_name = method_name.gsub(/\=/, '') if assignment
      self.class.class_eval { attr_accessor method_name }
      send "#{method_name}=", args[0] if assignment
    end

    def save()
      self.class.execute_write(to_solr_xml, {:overwrite => true})
    end

    def destroy
      # make an xml delete message that Solr will be happy with
      delete_message = ''
      builder = Builder::XmlMarkup.new(:target => delete_message, :indent => 2)

      builder.delete do |delete|
        delete.id(_id)
      end

      self.class.execute_write(delete_message)
    end

    def to_solr_xml
      output = ''
      builder = Builder::XmlMarkup.new(:target => output, :indent => 2)

      builder.add do |add|
        add.doc do |doc|
          self.class.solr_fields.each do |field_name|
            field_name = field_name.to_s

            if field_name == '_id'
              solr_field_name = 'id'
            else
              solr_field_name = field_name
            end

            val = instance_variable_get("@#{field_name}")

            if val
              if val.kind_of? Array
                val.each do |child|
                  doc.field({:name => solr_field_name}, child)
                end
              else
                doc.field({:name => solr_field_name}, val)
              end
            end
          end
        end
      end

      output
    end

    def update_attributes_values(data)
      data.each_pair do |k, v|
        instance_variable_set("@#{k}", v)
        self.class.solr_fields << k.to_s unless self.class.solr_fields.include?(k.to_s)
      end
    end

    def update_attributes(data)
      update_attributes_values(data)
      save()
    end

    def initialize(data = {})
      update_attributes_values(data)
    end
  end

  def to_param
    _id
  end
end
