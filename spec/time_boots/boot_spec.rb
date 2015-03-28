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

      #context 'several steps' do
      #end

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

      # describe negative
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
