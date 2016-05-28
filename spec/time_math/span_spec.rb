describe TimeMath::Span do
  def s(u, n)
    described_class.new(u, n)
  end

  it 'should be comparable for equality' do
    expect(s(:year, 5)).to eq s(:year, 5)
    expect(s(:year, 5)).not_to eq s(:year, 4)
    expect(s(:year, 5)).not_to eq s(:month, 5)
  end

  it 'should be inspectable' do
    expect(s(:year, 5).inspect).to eq "#<TimeMath::Span(year): +5>"
  end

  [Time, DateTime].each do |t|
    describe "with #{t}" do
      let(:tm){t.parse('2015-03-01 15:45')}

      [:sec, :min, :hour, :day, :month, :year].each do |name|
        describe "Span(#{name})" do
          let(:unit){TimeMath[name]}

          context 'when positive' do
            let(:span){s(name, 4)}

            it 'should advance forvards and backwards' do
              expect(span.from(tm)).to eq unit.advance(tm, 4)
              expect(span.after(tm)).to eq unit.advance(tm, 4)

              expect(span.before(tm)).to eq unit.decrease(tm, 4)
              expect(span.ago(tm)).to eq unit.decrease(tm, 4)
            end

            it 'should assume Time.now as defaults' do
              expect(Time).to receive(:now).and_return(tm)
              expect(span.ago).to eq unit.decrease(tm, 4)
            end
          end

          context 'when negative' do
            let(:span){s(name, -4)}

            it 'should advance forvards and backwards' do
              expect(span.from(tm)).to eq unit.decrease(tm, 4)
              expect(span.after(tm)).to eq unit.decrease(tm, 4)

              expect(span.before(tm)).to eq unit.advance(tm, 4)
              expect(span.ago(tm)).to eq unit.advance(tm, 4)
            end
          end
        end
      end
    end
  end
end
