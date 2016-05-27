# encoding: utf-8
describe TimeBoots::Jump do
  [Time, DateTime].each do |t|
    describe "with #{t}" do
      let(:tm){t.parse('2015-03-01 15:45')}

      [:sec, :min, :hour, :day, :month, :year].each do |step|
        describe "Jump(#{step})" do
          let(:boot){TimeBoots::Boot.get(step)}

          context 'when positive' do
            let(:jump){described_class.new(step, 4)}

            it 'should advance forvards and backwards' do
              expect(jump.from(tm)).to eq boot.advance(tm, 4)
              expect(jump.after(tm)).to eq boot.advance(tm, 4)

              expect(jump.before(tm)).to eq boot.decrease(tm, 4)
              expect(jump.ago(tm)).to eq boot.decrease(tm, 4)
            end

            it 'should assume Time.now as defaults' do
              expect(Time).to receive(:now).exactly(2).times.and_return(tm)
              expect(jump.ago).to eq boot.decrease(Time.now, 4)
            end
          end

          context 'when negative' do
            let(:jump){described_class.new(step, -4)}

            it 'should advance forvards and backwards' do
              expect(jump.from(tm)).to eq boot.decrease(tm, 4)
              expect(jump.after(tm)).to eq boot.decrease(tm, 4)

              expect(jump.before(tm)).to eq boot.advance(tm, 4)
              expect(jump.ago(tm)).to eq boot.advance(tm, 4)
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
  end
end
