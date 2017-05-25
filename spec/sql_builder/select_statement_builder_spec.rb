RSpec.describe SQLBuilder::SelectStatementBuilder do
  describe '#order_expression' do
    let(:root_builder) { SQLBuilder::Builder.new(double, database_type: 'Standard') }
    let(:builder) { SQLBuilder::StatementBuilder.new(root_builder, 'Standard') }

    let(:instance) { described_class.new(builder) }

    context 'with only one string item' do
      before { builder.order_by('id') }

      it 'returns the item string as it is' do
        expect(instance.order_expression).to eq 'id'
      end
    end

    context 'with 2 strig items' do
      before { builder.order_by('category_id', 'id') }

      it 'returns a comma separated item list' do
        expect(instance.order_expression).to eq 'category_id, id'
      end
    end

    context 'with only one TableField item' do
      before do
        t = root_builder.instance_eval { table :table1 }
        builder.order_by(t.id)
      end

      it 'returns an item string that expresses the item itself' do
        expect(instance.order_expression).to eq '"table1"."id"'
      end
    end

    context 'with 2 TableField items' do
      before do
        t = root_builder.instance_eval { table :table2 }
        builder.order_by(t.name, t.created_at)
      end

      it 'returns a comma separated item list' do
        expect(instance.order_expression).
          to eq '"table2"."name", "table2"."created_at"'
      end
    end

    context "with 2 items and 1 `DESC' keyword" do
      before do
        t = root_builder.instance_eval { table :t3 }
        desc = root_builder.instance_eval { keyword :desc }
        builder.order_by(t.name, t.status, desc)
      end

      it 'returns an item list in ORDER BY format' do
        expect(instance.order_expression).
          to eq '"t3"."name", "t3"."status" DESC'
      end
    end

    context "with an item list that contains `DESC' and `ASC'" do
      before do
        desc = root_builder.instance_eval { keyword :desc }
        asc = root_builder.instance_eval { keyword :asc }
        t = root_builder.instance_eval { table :t4 }
        builder.order_by(t.col1, t.col2, desc, t.col3, t.col4, asc)
      end

      it 'returns an item list in ORDER BY format' do
        expect(instance.order_expression).
          to eq '"t4"."col1", "t4"."col2" DESC, "t4"."col3", "t4"."col4" ASC'
      end
    end
  end
end
