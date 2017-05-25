RSpec.describe SQLBuilder::Table do
  describe '#to_s' do
    let(:instance) { described_class.new(table_name, alias_name) }

    context 'without an alias' do
      let(:table_name) { 'table' }
      let(:alias_name) { nil }

      it 'returns a quoted table name' do
        expect(instance.to_s).to eq '"table"'
      end
    end

    context 'with an alias' do
      let(:table_name) { 'table' }
      let(:alias_name) { 'tbl' }

      it 'returns a quoted alias name' do
        expect(instance.to_s).to eq '"tbl"'
      end
    end
  end

  describe 'as_from_form' do
    context 'without an alias nor any join clauses' do
      let(:instance) { described_class.new('table', nil) }

      it 'returns a quoted table name' do
        expect(instance.as_from_form).to eq '"table"'
      end
    end

    context 'with an alias and no join clauses' do
      let(:instance) { described_class.new('table', 'tbl') }

      it 'returns a quoted table name with a quoted alias name' do
        expect(instance.as_from_form).to eq '"table" AS "tbl"'
      end
    end

    context 'with no alias but a join clause' do
      let(:instance) { described_class.new('table1', nil) }
      let(:another_table) { described_class.new('table2', nil) }
      before { instance.join(another_table) }

      it 'returns a quoted table name with a join clause' do
        expect(instance.as_from_form).to eq '"table1" JOIN "table2"'
      end
    end

    context 'with an alias and a join clause' do
      let(:instance) { described_class.new('table1', 't1') }
      let(:another_table) { 'table2 AS t2' }
      before { instance.join(another_table) }

      it 'returns a quoted table name with a quoted alias and a join clause' do
        expect(instance.as_from_form).to eq '"table1" AS "t1" JOIN table2 AS t2'
      end
    end
  end
end
