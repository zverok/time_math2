describe TimeMath::Sequence do
  [Time, Date, DateTime].each do |t|
    describe "with #{t}" do
      let(:from) { t.parse('2014-03-10') }
      let(:floor_from) { TimeMath.month.floor(from) }
      let(:to) { t.parse('2014-11-10') }
      let(:floor_to) { TimeMath.month.decrease(TimeMath.month.floor(to)) }
      let(:ceil_to) { TimeMath.month.floor(to) }

      subject(:sequence) { described_class.new(:month, from...to) }

      describe 'creation' do
        context 'exclude end' do
          its(:from) { is_expected.to eq floor_from }
          its(:to) { is_expected.to eq floor_to }
        end

        context 'include end' do
          subject(:sequence) { described_class.new(:month, from..to) }

          its(:from) { is_expected.to eq floor_from }
          its(:to) { is_expected.to eq ceil_to }
        end
      end

      describe '#inspect' do
        its(:inspect) { is_expected.to eq "#<TimeMath::Sequence month (#{floor_from} - #{floor_to})>" }
      end

      describe '#==' do
        it 'works' do
          expect(sequence).to eq described_class.new(:month, from...to)
          expect(sequence).not_to eq described_class.new(:day, from...to)
          expect(sequence).not_to eq described_class.new(:month, from...TimeMath.month.advance(to))
          expect(sequence.advance(:min)).not_to eq sequence
        end
      end

      describe 'operations' do
        subject(:seq) { sequence.advance(:hour, 2).decrease(:sec, 3).floor(:min) }

        it { is_expected.to be_a described_class }
        its(:methods) { is_expected.to include(*TimeMath::Op::OPERATIONS) }
        its(:op) { is_expected.to eq TimeMath::Op.new.advance(:hour, 2).decrease(:sec, 3).floor(:min) }
        its(:inspect) { is_expected.to eq "#<TimeMath::Sequence month (#{floor_from} - #{floor_to}).advance(:hour, 2).decrease(:sec, 3).floor(:min)>" }

        context 'bang' do
          subject!(:ceiled) { seq.ceil!(:hour) }
          its(:op) { is_expected.to eq TimeMath().advance(:hour, 2).decrease(:sec, 3).floor(:min).ceil(:hour) }
          it { expect(seq.op).to eq TimeMath().advance(:hour, 2).decrease(:sec, 3).floor(:min).ceil(:hour) }
        end

        context 'non-bang' do
          subject!(:ceiled) { seq.ceil(:hour) }
          its(:op) { is_expected.to eq TimeMath().advance(:hour, 2).decrease(:sec, 3).floor(:min).ceil(:hour) }
          it { expect(seq.op).to eq TimeMath().advance(:hour, 2).decrease(:sec, 3).floor(:min) }
        end
      end

      describe '#to_a' do
        let(:fixture) { load_fixture(:sequence_to_a) }

        let(:from) { t.parse(fixture[:from]) }
        let(:to) { t.parse(fixture[:to]) }

        let(:sequence) { described_class.new(fixture[:step], from...to) }

        let(:expected) { fixture[:sequence].map(&t.method(:parse)) }

        subject { sequence.to_a }

        it { is_expected.to eq expected }

        context 'when include end' do
          let(:sequence) { described_class.new(fixture[:step], from..to) }
          let(:expected) { fixture[:sequence_include_end].map(&t.method(:parse)) }

          it { is_expected.to eq expected }
        end

        context 'with operations' do
          let(:sequence) {
            described_class
              .new(fixture[:step], from...to)
              .advance(:hour, 2).decrease(:sec, 3).floor(:min)
          }
          let(:op) { TimeMath().advance(:hour, 2).decrease(:sec, 3).floor(:min) }

          let(:expected) { fixture[:sequence].map(&t.method(:parse)).map(&op) }

          it { is_expected.to eq expected }
        end
      end

      describe '#pairs' do
        let(:fixture) { load_fixture(:sequence_pairs) }
        let(:from) { t.parse(fixture[:from]) }
        let(:to) { t.parse(fixture[:to]) }

        let(:lace) { described_class.new(fixture[:step], from, to, options) }

        let(:expected) { fixture[:sequence].map { |b, e| [t.parse(b), t.parse(e)] } }

        subject { sequence.pairs }

        it { is_expected.to eq expected }

        describe '#ranges' do
          subject { sequence.ranges }

          let(:expected) {
            fixture[:sequence].map { |b, e| (t.parse(b)...t.parse(e)) }
          }

          it { is_expected.to eq expected }
        end
      end
    end
  end
end
