module FrozenSynapse
  # @api private
  module LazyAttributes
    def lazy_attr_reader(attribute)
      define_method(attribute) do
        if !@populated && instance_variable_get("@#{attribute}").nil?
          populate
        end

        instance_variable_get("@#{attribute}")
      end
    end

    def lazy_initialize(values)
      values.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end
