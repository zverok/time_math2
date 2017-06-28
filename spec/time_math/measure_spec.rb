describe TimeMath::Measure do
  [Time, DateTime].each do |t|
    describe "with #{t}" do
      let(:from) { t.parse('2013-03-01 14:40:53') }
      let(:options) { {} }

      subject { described_class.measure(from, to, options) }

      context 'when long period' do
        let(:to) { t.parse('2015-02-25 10:18:47') }

        it { is_expected.to eq(years: 1, months: 11, weeks: 3, days: 2, hours: 19, minutes: 37, seconds: 54) }

        context ':upto limit' do
          let(:options) { {upto: :day} }

          it { is_expected.to eq(days: 725, hours: 19, minutes: 37, seconds: 54) }
        end

        context 'weeks: false' do
          let(:options) { {weeks: false} }

          it { is_expected.to eq(years: 1, months: 11, days: 23, hours: 19, minutes: 37, seconds: 54) }
        end
      end

      context 'when short period', pending: true do
        context 'show_empty: false' do
        end
      end
    end
  end
end
