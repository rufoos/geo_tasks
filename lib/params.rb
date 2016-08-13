module Sinatra
  module Parameters
    class ParameterMissing < IndexError
      def initialize(key)
        "[Parameters] Missing parameter with key: #{key}"
      end
    end

    class StrongParameters
      attr_accessor :params, :permitted_params
      attr_reader :is_hash
      def initialize(params)
        @params = params
        @permitted_params = {}
        @is_hash = false
      end

      # collection_type - тип коллекции, Hash or Array
      def required(key, collection_type = nil)
        @is_hash = collection_type.is_a?(Hash)
        if params.has_key?(key.to_s)
          @params = params[key.to_s]
          self
        else
          raise(ParameterMissing.new(key))
        end
      end

      def permit(*filters)
        if is_hash
          params.each_key do |key|
            param = params[key]
            filters.each do |filter|
              permitted =
                if filter.is_a?(Hash)
                  if param[filter.keys.first].is_a?(filter.values.first.class)
                    { filter => param[filter.keys.first] }
                  end
                elsif (filter.is_a?(String) || filter.is_a?(Symbol)) && !param[filter.to_s].nil?
                  { filter => param[filter.to_s] }
                end
              if permitted
                if permitted_params.key?(key)
                  permitted_params[key].merge!(permitted)
                else
                  permitted_params.merge!(key => permitted)
                end
              end
            end
          end
        else
          filters.each do |filter|
            permitted =
              if filter.is_a?(Hash)
                { filter => params[filter.keys.first] } if params[filter.keys.first].is_a?(filter.values.first.class)
              elsif (filter.is_a?(String) || filter.is_a?(Symbol)) && !params[filter.to_s].nil?
                { filter => params[filter.to_s] }
              end
            permitted_params.merge!(permitted) if permitted
          end
        end
        permitted_params
      end
    end

    def parameters
      StrongParameters.new(params)
    end
  end
end