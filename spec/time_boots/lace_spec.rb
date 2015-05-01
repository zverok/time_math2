# encoding: utf-8
describe TimeBoots::Lace do
  let(:from){t('2014-03-10')}
  let(:to){t('2014-11-10')}

  let(:lace){described_class.new(:month, from, to)}
  subject{lace}
  
  describe 'creation' do
    its(:from){should == from}
    its(:to){should == to}
  end

  describe '#expand!' do
    before{subject.expand!}

    its(:from){should == TimeBoots.month.floor(from)}
    its(:to){should == TimeBoots.month.ceil(to)}
  end

  describe '#expand' do
    let(:expanded){lace.expand}

    describe 'expanded' do
      subject{expanded}

      its(:from){should == TimeBoots.month.floor(from)}
      its(:to){should == TimeBoots.month.ceil(to)}
    end

    describe 'original' do
      subject{lace}

      its(:from){should == from}
      its(:to){should == to}
    end
  end

  describe 'creating expanded' do
    subject{described_class.new(:month, from, to, expand: true)}

    its(:from){should == TimeBoots.month.floor(from)}
    its(:to){should == TimeBoots.month.ceil(to)}
  end

  describe '#pull' do
    let(:fixture){load_fixture(:lace_pull)}
    let(:from){t(fixture[:from])}
    let(:to){t(fixture[:to])}

    let(:lace){described_class.new(fixture[:step], from, to)}

    let(:expected){fixture[:sequence].map(&method(:t))}

    subject{lace.pull}

    it{should == expected}
    
    context 'when pulling beginnings' do
      let(:expected){fixture[:sequence_beg].map(&method(:t))}

      subject{lace.pull(true)}

      it{should == expected}
    end
  end

  describe '#pull_pairs' do
    let(:fixture){load_fixture(:lace_pull_pairs)}
    let(:from){t(fixture[:from])}
    let(:to){t(fixture[:to])}

    let(:lace){described_class.new(fixture[:step], from, to)}

    let(:expected){fixture[:sequence].map{|b,e | [t(b), t(e)]}}

    subject{lace.pull_pairs}

    it{should == expected}

    context 'when pulling beginnings' do
      let(:expected){fixture[:sequence_beg].map{|b,e | [t(b), t(e)]}}

      subject{lace.pull_pairs(true)}

      it{should == expected}
    end

    describe '#pull_ranges' do
      subject{lace.pull_ranges}
      let(:expected){
        fixture[:sequence].map{|b, e| (t(b)...t(e))}
      }

      it{should == expected}
    end
  end
end
