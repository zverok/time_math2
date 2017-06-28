describe TimeMath do
  subject { described_class }

  describe 'basics' do
    its(:units) { is_expected.to eq %i[sec min hour day week month year] }
  end

  describe '#<unit name>' do
    described_class.units.each do |u|
      its(u) { is_expected.to eq(TimeMath::Units.get(u)) }
    end
  end

  describe '#[]' do
    described_class.units.each do |u|
      its([u]) { is_expected.to eq(TimeMath::Units.get(u)) }
    end

    it { expect { described_class[:age] }.to raise_error ArgumentError, /age/ }
  end

  describe '#()' do
    let(:tm) { Time.parse('2013-03-01 14:40:53') }

    it { expect(TimeMath()).to eq TimeMath::Op.new }
    it { expect(TimeMath(tm)).to eq TimeMath::Op.new(tm) }
  end

  describe '#measure' do
    let(:from) { Time.parse('2013-03-01 14:40:53') }
    let(:to) { Time.parse('2015-02-25 10:18:47') }

    it 'delegates' do
      expect(described_class.measure(from, to)).to eq TimeMath::Measure.measure(from, to)
    end
  end
end
