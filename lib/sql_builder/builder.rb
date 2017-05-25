module SQLBuilder
  class Builder
    def initialize(context, database_type:)
      @context = context
      @db_type = database_type
      @tables = {}
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
        StatementBuilder.new(self, @db_type).tap do |builder|
          builder.instance_variable_set("@#{nm}", arguments)
        end
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

    private

    def table(name, as: nil)
      nm = as ? as : name
      raise unless nm.to_s =~ /\A[a-zA-Z]\w*\z/

      @tables[nm] ||= Table.new(name, as, db_type: @db_type).tap do |tbl|
        self.singleton_class.instance_eval {
          define_method nm, -> { tbl }
        } unless respond_to?(nm)
      end
    end

    def keyword(name)
      Keyword.new(name)
    end
    alias kw keyword

    def method_missing(name, *args, &block)
      @context.__send__(name, *args, &block)
    end
  end
end
