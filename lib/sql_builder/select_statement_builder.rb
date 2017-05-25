module SQLBuilder
  class SelectStatementBuilder
    attr_reader :select_expr, :where_condition

    def initialize(builder)
      @builder = builder
    end

    def build
      {
        select: select_expression,
        from: table_references,
        where: where_condition,
        group_by: group_expression,
        order_by: order_expression,
      }.each_with_object([]) {|(k, v), a|
        next unless v
        a.concat([k.to_s.upcase, v])
      }.join(' ')
    end

    def select_expression
      select_expr = @builder.instance_variable_get(:@select)

      if select_expr.nil? || select_expr.empty?
        tables.uniq.map {|t| t.(:*) }.join(', ')
      else
        keywords, expr = select_expr.each_with_object([[], []]) {|s, (kw, ex)|
          (s.is_a?(Keyword) ? kw : ex) << s
        }
        [keywords.join(' '), expr.join(', ')].reject(&:empty?).join(' ')
      end
    end

    def table_references
      tables.compact.uniq.map(&:as_from_form).join(', ')
    end

    def where_condition
      @builder.instance_variable_get(:@where)
    end

    def group_expression
      list = @builder.instance_variable_get(:@group_by)
      column_expression(list) if list
    end

    def order_expression
      list = @builder.instance_variable_get(:@order_by)
      column_expression(list) if list
    end

    def column_expression(list)
      list.inject(nil) {|str, item|
        sep = item.is_a?(Keyword) ? ' ' : ', '
        [str, item].compact.join(sep)
      }
    end

    def tables
      return @tables if @tables

      select_expr = @builder.instance_variable_get(:@select)
      s = (select_expr || []).lazy.select {|s|
        s.is_a?(TableField)
      }.map(&:table).to_a

      w = if where_condition.respond_to?(:tables) && where_condition.tables
            where_condition.tables
          else
            []
          end

      @tables = s + w - s.flat_map {|t| t.joins.flat_map(&:tables) }
    end
  end
end
