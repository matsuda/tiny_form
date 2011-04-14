module TinyForm
  class Base
    # ActiveModels
    # extend ActiveModel::Translation
    # extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    class_inheritable_accessor :attribute_definition, :instance_writer => false
    self.attribute_definition = {}

    class_inheritable_accessor :target_klass, :instance_writer => false
    self.target_klass = nil

    def initialize(new_attributes = {})
      return unless new_attributes.is_a?(Hash)
      attributes = new_attributes.stringify_keys
      multi_parameter_attributes = []

      attributes.each_pair{ |k, v|
        if k.include?("(")
          multi_parameter_attributes << [ k, v ]
        else
          # respond_to?(:"#{k}=") ? send(:"#{k}=", v) : raise(UnknownAttributeError, "unknown attribute: #{k}")
          send(:"#{k}=", v) if respond_to?(:"#{k}=")
        end
      }
      assign_multiparameter_attributes(multi_parameter_attributes)
    end

    def scoped
      self.target_klass.scoped
    end

    private
    def persisted?
      false
    end

    def assign_multiparameter_attributes(pairs)
      execute_callstack_for_multiparameter_attributes(
        extract_callstack_for_multiparameter_attributes(pairs)
      )
    end

    def instantiate_time_object(name, values)
      # if self.class.send(:create_time_zone_conversion_attribute?, name, column_for_attribute(name))
      #   Time.zone.local(*values)
      # else
      #   Time.time_with_datetime_fallback(@@default_timezone, *values)
      # end
      if default_timezone = Rails::Application.config.time_zone
        Time.time_with_datetime_fallback(default_timezone, *values)
      else
        Time.zone.local(*values)
      end
    end

    def execute_callstack_for_multiparameter_attributes(callstack)
      errors = []
      callstack.each do |name, values_with_empty_parameters|
        begin
          # klass = (self.class.reflect_on_aggregation(name.to_sym) || column_for_attribute(name)).klass
          klass = self.class.attribute_definition[name.to_sym]
          next unless klass
          # in order to allow a date to be set without a year, we must keep the empty values.
          # Otherwise, we wouldn't be able to distinguish it from a date with an empty day.
          values = values_with_empty_parameters.reject { |v| v.nil? }

          if values.empty?
            send(name + "=", nil)
          else

            value = if :time == klass || :datetime == klass
              instantiate_time_object(name, values)
            elsif :date == klass
              begin
                values = values_with_empty_parameters.collect do |v| v.nil? ? 1 : v end
                Date.new(*values)
              rescue ArgumentError => ex # if Date.new raises an exception on an invalid date
                instantiate_time_object(name, values).to_date # we instantiate Time object and convert it back to a date thus using Time's logic in handling invalid dates
              end
            # else
            #   klass.new(*values)
            end

            send(name + "=", value)
          end
        rescue => ex
          errors << TinyForm::AttributeAssignmentError.new("error on assignment #{values.inspect} to #{name}", ex, name)
        end
      end
      unless errors.empty?
        raise TinyForm::MultiparameterAssignmentErrors.new(errors), "#{errors.size} error(s) on assignment of multiparameter attributes"
      end
    end

    def extract_callstack_for_multiparameter_attributes(pairs)
      attributes = { }

      for pair in pairs
        multiparameter_name, value = pair
        attribute_name = multiparameter_name.split("(").first
        attributes[attribute_name] = [] unless attributes.include?(attribute_name)

        parameter_value = value.empty? ? nil : type_cast_attribute_value(multiparameter_name, value)
        attributes[attribute_name] << [ find_parameter_position(multiparameter_name), parameter_value ]
      end

      attributes.each { |name, values| attributes[name] = values.sort_by{ |v| v.first }.collect { |v| v.last } }
    end

    def type_cast_attribute_value(multiparameter_name, value)
      multiparameter_name =~ /\([0-9]*([if])\)/ ? value.send("to_" + $1) : value
    end

    def find_parameter_position(multiparameter_name)
      multiparameter_name.scan(/\(([0-9]*).*\)/).first.first
    end

    # 
    # ClassMethods
    # 

    class << self
      def define_attribute(*attrs)
        options = attrs.extract_options!
        type = options[:type]
        attr_accessor *attrs
        attrs.each do |attr|
          self.attribute_definition.update(attr => type)
        end
      end
      alias_method :def_attr, :define_attribute

      private
      def inherited(subclass)
        super
        kind = subclass.name.split('::').last.underscore.sub(/_form$/, '')#.to_sym
        subclass.target_klass = kind.camelize.constantize
      end
    end
  end
end
