module SQLBuilder
  class TableField
    include Helper::Quoting

    attr_reader :db_type, :table, :name

    def initialize(table, name)
      @table = table
      @name = name
      @db_type = table.db_type
    end

    %w[> >= < <=].each do |name|
      define_method name, ->(argument) {
        tables = Helper.collect_tables([@table], argument)
        Expression.new(tables, self, argument, name)
      }
    end

    def ==(argument)
      tables = Helper.collect_tables([@table], argument)
      Expression.new(tables, self, argument, argument.nil? ? 'IS' : '=')
    end

    def !=(argument)
      tables = Helper.collect_tables([@table], argument)
      Expression.new(tables, self, argument, argument.nil? ? 'IS NOT' : '<>')
    end

    def tables
      [self.table]
    end

    def to_s
      if @name.to_s == '*'
        "#@table.*"
      else
        "%s.%s" % [@table, quote_identifier(@name)]
      end
    end
  end
end
