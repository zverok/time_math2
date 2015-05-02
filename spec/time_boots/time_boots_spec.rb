# encoding: utf-8
describe TimeBoots do
  subject{described_class}

  describe 'basics' do
    its(:steps){should == [:sec, :min, :hour, :day, :week, :month, :year]}
  end

  describe 'boots shortcuts' do
    described_class.steps.each do |step|
      it 'should provide step' do
        expect(subject.send(step)).to eq(TimeBoots::Boot.get(step))
      end
    end
  end

  describe 'method shortucts' do
    let(:tm){t('2015-03-27 11:40:20')}

    described_class.steps.each do |step|
      context "when #{step}" do
        let(:boot){TimeBoots::Boot.get(step)}
        
        it 'should support fast calls' do
          expect(described_class.floor(step, tm)).to eq(boot.floor(tm))
          expect(described_class.ceil(step, tm)).to eq(boot.ceil(tm))
          expect(described_class.round(step, tm)).to eq(boot.round(tm))

          # and so on...
          [:round?, :range, :range_back, :advance, :decrease, :jump, :lace, :measure].each do |m|
            expect(described_class).to respond_to(m)
          end
        end
      end
    end
  end

  describe 'module including' do
    let(:klass){Class.new{include TimeBoots}}
    subject{klass.new}
    its(:hour){should == TimeBoots.hour}
  end
end
