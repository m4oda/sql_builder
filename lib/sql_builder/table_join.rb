module SQLBuilder
  class TableJoin
    include Helper::Quoting

    attr_reader :db_type, :tables

    def initialize(left_table, type, *tables)
      @type = type.nil? || type.empty? ? nil : type
      @db_type = left_table.db_type
      @tables = tables
    end

    def on(condition)
      @on = condition
      self
    end

    def using(*arguments)
      @using = arguments.map {|s|
        s = s.name if s.is_a?(TableField)
        quote_identifier(s)
      }.join(', ')
      self
    end

    def to_s
      join_keyword = [@type, 'JOIN'].compact.join(' ')
      table_refs = @tables.map {|table|
        if table.is_a?(String) or table.is_a?(Symbol)
          table.to_s =~ /;/ ? quote_identifier(table) : table
        elsif table.joins.empty?
          table.as_from_form
        else
          "(#{table.as_from_form})"
        end
      }.join(', ')

      "%<join>s %<table_clause>s%<on>s%<use>s" % {
        join: join_keyword,
        table_clause: table_refs,
        on: @on ? " ON #@on" : "",
        use: @using ? " USING (#@using)" : "",
      }
    end
  end
end
