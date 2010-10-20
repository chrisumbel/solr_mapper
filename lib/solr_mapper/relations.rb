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
    module ClassMethods
      attr_accessor :has_many_relationships

      def has_one(target, opts = {})
        class_name, field_name, variable_name, id_field = determine_names(target, opts)
        id_field = "#{id_field}_id"

        class_eval do
          define_method field_name do
            val = instance_variable_get(variable_name)

            unless val
              id = instance_variable_get(id_field)              
              val = Object::const_get(class_name).find(id) if id
            end

            val
          end

          define_method "#{field_name}=" do |val|
            instance_variable_set("@#{field_name}", val)
          end
        end
      end

      def has_many(target, opts = {})
        class_name, field_name, variable_name, id_field = determine_names(target, opts)
        id_field = "#{id_field}_id"

        has_many_relationships[field_name.to_s] = id_field

        class_eval do
          define_method field_name do
            val = instance_variable_get(variable_name)

            unless val
              ids = instance_variable_get(id_field)
              val = []

              val.instance_variable_set("@owner", self)
              val.instance_variable_set("@field_name", field_name.to_s)

              if ids
                ids.each do |id|
                  val << Object::const_get(class_name).find(id)
                end
              end

              class << val
                alias :super_push :push
                alias :super_delete :delete

                def << val
                  val.save
                  push val
                  @owner.save()
                end

                def push val
                  super_push val
                  @owner.refresh_relation(instance_variable_get("@field_name"))
                end

                def destroy val
                  val.destroy
                  delete val
                end

                def delete val
                  super_delete val
                  @owner.refresh_relation(instance_variable_get("@field_name"))
                end
              end

              instance_variable_set(variable_name, val)
            end

            val
          end

          define_method "#{field_name}=" do |vals|
            ids = []

            if self.class.instance_variable_get('@solr_fields').include?(field_name)
              self.class.instance_variable_get('@solr_fields') << field_name
            end

            if vals
              vals.each do |obj|
                ids << obj._id
              end
            end

            instance_variable_set(id_field, ids)
            instance_variable_set("@#{field_name}", val)
          end
        end
      end

      def belongs_to(target, opts = {})
        puts "belongs to #{target}"
      end

      protected

      def connect_array

      end

      def determine_names(target, opts = {})
        class_name = opts[:class_name]
        class_name ||= classify(target)
        field_name = target
        variable_name = "@#{field_name}"
        id_field_prefix = "@#{singularize(target)}"

        return class_name, field_name, variable_name, id_field_prefix
      end
    end

    def refresh_relation(field_name)
      ids = instance_variable_get(self.class.has_many_relationships[field_name])
      ids.clear

      instance_variable_get("@#{field_name}").each do |child|
        ids << child._id
      end
    end
  end
end

