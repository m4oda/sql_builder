module SQLBuilder
  class Expression
    attr_reader :tables

    def initialize(tables, expression, argument, operator)
      @tables = tables
      @expression = expression
      @argument = argument.is_a?(Builder) ? NestedBuilder.new(argument) : argument
      @operator = operator
    end

    def &(argument)
      tables = Helper.collect_tables(@tables, argument)
      self.class.new(tables, self, argument, 'AND')
    end

    def |(argument)
      tables = Helper.collect_tables(@tables, argument)
      self.class.new(tables, self, argument, 'OR')
    end

    def and
      self.method(:&)
    end

    def or
      self.method(:|)
    end

    def call(command)
      case command.to_sym
      when :and
        self.method(:&)
      when :or
        self.method(:|)
      else
        raise "Unknown: #{command}"
      end
    end

    def to_s
      [@expression, @argument].map {|v|
        case v
        when self.class, StatementBuilder
          "(#{v})"
        when String
          s = v.gsub('\\', '\&\&').gsub("'", "''")
          "'#{s}'"
        when nil
          "NULL"
        else
          v
        end
      }.insert(1, @operator).join(' ')
    end
  end
end
