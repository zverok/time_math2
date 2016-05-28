describe TimeMath::Sequence do
  [Time, DateTime].each do |t|
    describe "with #{t}" do
      let(:from){t.parse('2014-03-10')}
      let(:to){t.parse('2014-11-10')}

      subject(:sequence){described_class.new(:month, from, to)}

      describe 'creation' do
        its(:from){should == from}
        its(:to){should == to}
      end

      describe '#inspect' do
        its(:inspect) { should == "#<TimeMath::Sequence(#{from} - #{to})>" }
      end

      describe '#expand!' do
        before{sequence.expand!}

        its(:from){should == TimeMath.month.floor(from)}
        its(:to){should == TimeMath.month.ceil(to)}
      end

      describe '#expand' do
        let(:expanded){sequence.expand}

        describe 'expanded' do
          subject{expanded}

          its(:from){should == TimeMath.month.floor(from)}
          its(:to){should == TimeMath.month.ceil(to)}
        end

        describe 'original' do
          its(:from){should == from}
          its(:to){should == to}
        end
      end

      describe 'creating expanded' do
        subject{described_class.new(:month, from, to, expand: true)}

        its(:from){should == TimeMath.month.floor(from)}
        its(:to){should == TimeMath.month.ceil(to)}
      end

      describe '#to_a' do
        let(:fixture){load_fixture(:sequence_to_a)}

        let(:from){t.parse(fixture[:from])}
        let(:to){t.parse(fixture[:to])}

        let(:sequence){described_class.new(fixture[:step], from, to)}

        let(:expected){fixture[:sequence].map(&t.method(:parse))}

        subject{sequence.to_a}

        it{should == expected}

        context 'when floored' do
          let(:expected){fixture[:sequence_floor].map(&t.method(:parse))}

          subject{sequence.to_a(true)}

          it{should == expected}
        end
      end

      describe '#pairs' do
        let(:fixture){load_fixture(:sequence_pairs)}
        let(:from){t.parse(fixture[:from])}
        let(:to){t.parse(fixture[:to])}

        let(:lace){described_class.new(fixture[:step], from, to)}

        let(:expected){fixture[:sequence].map{|b,e | [t.parse(b), t.parse(e)]}}

        subject{sequence.pairs}

        it{should == expected}

        context 'when floored' do
          let(:expected){fixture[:sequence_floor].map{|b,e | [t.parse(b), t.parse(e)]}}

          subject{sequence.pairs(true)}

          it{should == expected}
        end

        describe '#ranges' do
          subject{sequence.ranges}
          let(:expected){
            fixture[:sequence].map{|b, e| (t.parse(b)...t.parse(e))}
          }

          it{should == expected}
        end
      end
    end
  end
end
