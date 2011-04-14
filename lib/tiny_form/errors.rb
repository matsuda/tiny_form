module TinyForm
  # Generic TinyForm exception class.
  class TinyFormError < StandardError
  end

  # Raised when an error occurred while doing a mass assignment to an attribute through the
  # <tt>attributes=</tt> method. The exception has an +attribute+ property that is the name of the
  # offending attribute.
  class AttributeAssignmentError < TinyFormError
    attr_reader :exception, :attribute
    def initialize(message, exception, attribute)
      @exception = exception
      @attribute = attribute
      @message = message
    end
  end

  # Raised when there are multiple errors while doing a mass assignment through the +attributes+
  # method. The exception has an +errors+ property that contains an array of AttributeAssignmentError
  # objects, each corresponding to the error while assigning to an attribute.
  class MultiparameterAssignmentErrors < TinyFormError
    attr_reader :errors
    def initialize(errors)
      @errors = errors
    end
  end
end
