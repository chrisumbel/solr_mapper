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

      # send a read REST command to Solr
      def execute_read(opts)
        eval(RestClient.get(build_url('select', opts.merge(:wt => 'ruby'))))
      end

      # send a write REST command to SOlr
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

      # create a querystring from a hash
      def build_qs(opts)
        uri = ''

        if opts
          opts.each_pair do |k, v|
            uri << "#{k}=#{v}&"
          end
        end

        uri.chop
      end

      def search(values, opts = {})
        puts "Warning, the search method is deprecated and will be removed in a future release."
        puts "Instead use 'query' which can accept a string."

        query(values, opts)
      end

      # main interface by which consumers search solr via SolrMapper
      def query(values, opts = {})
        results, _ = query_counted(values, opts)
        results
      end

      # execute  solr query and return the count as well as the results
      def query_counted(values, opts = {})
        if values.kind_of?(Hash)
          search_string = ''

          values.each_pair do |k, v|
            search_string << "#{k}:#{v} "
          end

          search_string = search_string.chop
        else
          search_string = values.to_s
        end

        response = execute_read(opts.merge(:q => search_string))
        return map(response), response['response']['numFound']
      end

      # look up an object by primary key
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
          results, count = query_counted(search_query, opts)

          if results
            results.compact!

            pager.total_entries = count
            pager.replace(results)
            return pager
          end          
        end
      end

      protected
      # map values returned from Solr into ruby objects
      def map(docs)
        objs = []

        docs['response']['docs'].each do |doc|
          obj = self.new
          obj.send(:before_load) if obj.respond_to?(:before_load)

          doc.each_pair do |k, v|
            k = '_id' if k.to_s == 'id'

            class_eval { attr_accessor k } unless obj.respond_to?("#{k}=")
            self.solr_fields << k unless self.solr_fields.include?(k)

            obj.send("#{k}=", v)
          end

          obj.send(:after_load) if obj.respond_to?(:after_load)

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
      send(:before_save) if respond_to?(:before_save)

      self.class.execute_write(to_solr_xml, {:overwrite => true})

      send(:after_save) if respond_to?(:after_save)      
    end

    # remove an object from the index
    def destroy
      # make an xml delete message that Solr will be happy with
      delete_message = ''
      builder = Builder::XmlMarkup.new(:target => delete_message, :indent => 2)

      builder.delete do |delete|
        delete.id(_id)
      end

      self.class.execute_write(delete_message)
    end

    # convert a ruby object to xml compliant with a Solr update REST command
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

    # handle rails building a url from us
    def to_param
      instance_variable_get('@_id').to_s
    end

    def initialize(data = {})
      update_attributes_values(data)
    end
  end
end
