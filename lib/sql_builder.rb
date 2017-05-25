require 'sql_builder/builder'
require 'sql_builder/expression'
require 'sql_builder/helper'
require 'sql_builder/keyword'
require 'sql_builder/nested_builder'
require 'sql_builder/select_statement_builder'
require 'sql_builder/statement_builder'
require 'sql_builder/table_field'
require 'sql_builder/table_join'
require 'sql_builder/table'

module SQLBuilder
  def self.for(database_type)
    BuilderGenerator.generate(database_type)
  end

  def self.string(&block)
    BuilderGenerator.generate.string(&block)
  end

  class BuilderGenerator
    def self.generate(database_type = 'Standard')
      new(database_type)
    end

    def initialize(db)
      @db = db
    end

    def string(&block)
      builder = Builder.new(block.binding.receiver, database_type: @db)
      builder.instance_eval(&block).to_s
    end
  end
end
