# encoding: utf-8
describe TimeBoots::Span do
  let(:tm){t('2015-03-01 15:45')}
  
  [:sec, :min, :hour, :day, :month, :year].each do |step|
    describe "Span(#{step})" do
      let(:boot){TimeBoots::Boot.get(step)}

      context 'when positive' do
        let(:span){described_class.new(step, 4)}

        it 'should advance forvards and backwards' do
          expect(span.from(tm)).to eq boot.advance(tm, 4)
          expect(span.after(tm)).to eq boot.advance(tm, 4)

          expect(span.before(tm)).to eq boot.decrease(tm, 4)
          expect(span.ago(tm)).to eq boot.decrease(tm, 4)
        end

        it 'should assume Time.now as defaults' do
          expect(Time).to receive(:now).exactly(2).times.and_return(tm)
          expect(span.ago).to eq boot.decrease(Time.now, 4)
        end
      end

      context 'when negative' do
        let(:span){described_class.new(step, -4)}

        it 'should advance forvards and backwards' do
          expect(span.from(tm)).to eq boot.decrease(tm, 4)
          expect(span.after(tm)).to eq boot.decrease(tm, 4)

          expect(span.before(tm)).to eq boot.advance(tm, 4)
          expect(span.ago(tm)).to eq boot.advance(tm, 4)
        end
      end

      it 'should be comparable for equality' do
        expect(described_class.new(:year, 5)).to eq described_class.new(:year, 5)
        expect(described_class.new(:year, 5)).not_to eq described_class.new(:year, 4)
        expect(described_class.new(:year, 5)).not_to eq described_class.new(:month, 5)
      end
    end
  end
end
