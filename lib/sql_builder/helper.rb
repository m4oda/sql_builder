module SQLBuilder
  module Helper
    def self.collect_tables(tables, object)
      [].tap do |array|
        array.concat(tables)
        array.concat(object.tables) if object.respond_to?(:tables)
      end
    end

    module Quoting
      def quote_identifier(identifier)
        @quoting ||= Helper.const_get("#{self.db_type.to_s}Quoting")
        @quoting.quote_identifier(identifier)
      end
    end

    module StandardQuoting
      def self.quote_identifier(identifier)
        name = identifier.to_s.gsub(/"/, '""')
        %Q("#{name}")
      end
    end

    module MySQLQuoting
      def self.quote_identifier(identifier)
        name = identifier.to_s.gsub(/`/, '``')
        %Q(`#{name}`)
      end
    end
  end
end
