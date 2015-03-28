# encoding: utf-8
describe TimeBoots::Boot do
  
  describe 'basics' do
  end

  describe 'math' do
    describe '#floor' do
      let(:fixture){load_fixture(:floor)}
      let(:source){t(fixture[:source])}

      it 'should round down to step' do
        fixture[:targets].each do |step, val|
          expect(described_class.get(step).floor(source)).to eq t(val)
        end
      end
    end

    describe '#ceil' do
      let(:fixture){load_fixture(:ceil)}
      let(:source){t(fixture[:source])}

      it 'should round up to step' do
        fixture[:targets].each do |step, val|
          expect(described_class.get(step).ceil(source)).to eq t(val)
        end
      end
    end

    describe '#round' do
    end

    describe '#advance' do
      context 'one step' do
        let(:fixture){load_fixture(:advance)}
        let(:source){t(fixture[:source])}

        it 'should advance one step exactly' do
          fixture[:targets].each do |step, val|
            expect(described_class.get(step).advance(source)).to eq t(val)
          end
        end
      end

      context 'several steps' do
        let(:tm){t('2015-03-27 11:40:20')}
        
        [:sec, :min, :hour, :day, :month, :year].each do |step|
          [3, 100, 1000].each do |amount|
            context "when advanced #{amount} #{step}s" do
              let(:boot){described_class.get(step)}
              subject{boot.advance(tm, amount)}
              let(:correct){amount.times.inject(tm){|t| boot.advance(t)}}

              it{should == correct}
            end
          end
        end
      end

      context 'negative advance' do
        let(:tm){t('2015-03-27 11:40:20')}

        [:sec, :min, :hour, :day, :month, :year].each do |step|
          context "when step=#{step}" do
            let(:boot){described_class.get(step)}

            it "should treat negative advance as decrease" do
              expect(boot.advance(tm, -13)).to eq(boot.decrease(tm, 13))
            end
          end
        end
      end

      context 'zero advance' do
        let(:tm){t('2015-03-27 11:40:20')}

        [:sec, :min, :hour, :day, :month, :year].each do |step|
          context "when step=#{step}" do
            let(:boot){described_class.get(step)}

            it "should do nothing on zero advance" do
              expect(boot.advance(tm, 0)).to eq tm
            end
          end
        end
      end

      #describe 'month edge cases' do
      #end

      #describe 'year edge cases' do
      #end

      # DST edge cases: 2015-03-28->29

      # describe negative
    end

    describe '#decrease' do
      context 'one step' do
        let(:fixture){load_fixture(:decrease)}
        let(:source){t(fixture[:source])}

        it 'should descrease' do
          fixture[:targets].each do |step, val|
            expect(described_class.get(step).decrease(source)).to eq t(val)
          end
        end
      end

      context 'several steps' do
        let(:tm){t('2015-03-27 11:40:20')}
        
        [:sec, :min, :hour, :day, :month, :year].each do |step|
          [3, 100, 1000].each do |amount|
            context "when decreased #{amount} #{step}s" do
              let(:boot){described_class.get(step)}
              subject{boot.decrease(tm, amount)}
              let(:correct){amount.times.inject(tm){|t| boot.decrease(t)}}

              it{should == correct}
            end
          end
        end
      end

      context 'negative decrease' do
        let(:tm){t('2015-03-27 11:40:20')}

        [:sec, :min, :hour, :day, :month, :year].each do |step|
          context "when step=#{step}" do
            let(:boot){described_class.get(step)}

            it "should treat negative decrease as advance" do
              expect(boot.decrease(tm, -13)).to eq(boot.advance(tm, 13))
            end
          end
        end
      end

      context 'zero decrease' do
        let(:tm){t('2015-03-27 11:40:20')}

        [:sec, :min, :hour, :day, :month, :year].each do |step|
          context "when step=#{step}" do
            let(:boot){described_class.get(step)}

            it "should do nothing on zero decrease" do
              expect(boot.decrease(tm, 0)).to eq tm
            end
          end
        end
      end
    end

    describe '#beginning?' do
      let(:fixture){load_fixture(:beginning)}

      it 'should determine, if tm is beginning of step' do
        fixture.each do |step, vals|
          expect( described_class.get(step).beginning?(t(vals[:true])) ).to \
            be_truthy

          expect( described_class.get(step).beginning?(t(vals[:false])) ).to \
            be_falsy
        end
      end
    end

    #describe '#measure' do
    #end

    #describe '#measure_rem' end
    #end
  end
end
