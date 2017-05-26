module SQLBuilder
  class Table
    include Helper::Quoting

    attr_reader :db_type, :joins

    def initialize(name, as, db_type: 'Standard')
      @name = name
      @alias = as
      @db_type = db_type
      @fields = {}
      @joins = []
    end

    def join(*tables)
      setup_join(nil, *tables)
    end

    %w[inner outer left right
       left_outer right_outer
       natural natural_inner natural_left natural_right
       natural_left_outer natural_right_outer
       cross straight
    ].each do |name|
      define_method "#{name}_join", ->(*tables) { setup_join(name, *tables) }
    end

    def to_s
      quote_identifier(@alias ? @alias : @name)
    end

    def as_from_form
      joins = @joins.map(&:to_s).join(' ')
      table_name = to_s unless @alias
      table_name ||= "%s AS %s" % [@name, @alias].map {|s| quote_identifier(s) }

      [table_name, joins].reject(&:empty?).join(' ')
    end

    def call(name, as: nil)
      @fields[name] ||= TableField.new(self, name, as: as).tap do |field|
        self.singleton_class.instance_eval {
          define_method name, -> { field }
        } unless respond_to?(name)
      end
    end

    def method_missing(name, *args, &block)
      if args.empty? and not block_given?
        self.(name)
      elsif args.size == 1
        anm = args.first.is_a?(Hash) && args.first[:as]
        anm ||= args.first
        self.(name, as: anm)
      else
        super
      end
    end

    private

    def setup_join(type, *tables)
      join_type = type ? type.to_s.upcase.sub(/_/, ' ') : nil
      TableJoin.new(self, join_type, *tables).tap {|j| @joins << j }
    end
  end
end
