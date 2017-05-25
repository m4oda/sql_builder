module SQLBuilder
  class StatementBuilder
    def initialize(builder, database_type)
      @builder = builder
      @tables = @builder.instance_variable_get(:@tables)
      @db_type = database_type
    end

    def to_s
      SelectStatementBuilder.new(self).build
    end

    [
      :select,
      :order_by,
      :group_by,
    ].each do |nm|
      define_method nm, ->(*arguments) {
        instance_variable_set("@#{nm}", arguments)
        self
      }
    end

    [
      :where,
      :having,
      :limit,
      :offset,
    ].each do |nm|
      define_method nm, ->(argument) {
        instance_variable_set("@#{nm}", argument)
        self
      }
    end

    def for_update
      @for_update = true
    end
  end
end
