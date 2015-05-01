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

  describe 'including' do
  end
end
