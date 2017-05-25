module SQLBuilder
  class NestedBuilder
    def initialize(builder)
      @string = builder.to_s
    end

    def to_s
      "(#@string)"
    end
  end
end
