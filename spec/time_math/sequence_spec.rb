describe TimeMath::Sequence do
  [Time, Date, DateTime].each do |t|
    describe "with #{t}" do
      let(:from){t.parse('2014-03-10')}
      let(:to){t.parse('2014-11-10')}
      let(:options) { {} }

      subject(:sequence){described_class.new(:month, from...to, options)}

      describe 'creation' do
        context 'exclude end' do
          subject(:sequence){described_class.new(:month, from...to, options)}
          its(:from){should == from}
          its(:to){should == to}
          its(:exclude_end?) { is_expected.to be_truthy }
        end

        context 'include end' do
          subject(:sequence){described_class.new(:month, from..to, options)}
          its(:from){should == from}
          its(:to){should == to}
          its(:exclude_end?) { is_expected.to be_falsy }
        end
      end

      describe '#inspect' do
        its(:inspect) { should == "#<TimeMath::Sequence(:month, #{from}...#{to})>" }
        context 'include end' do
          subject(:sequence){described_class.new(:month, from..to, options)}
          its(:inspect) { should == "#<TimeMath::Sequence(:month, #{from}..#{to})>" }
        end
      end

      describe '#==' do
        it 'should work' do
          expect(sequence).to eq described_class.new(:month, from...to)
          expect(sequence).not_to eq described_class.new(:day, from...to)
          expect(sequence).not_to eq described_class.new(:month, from...to+1)
          expect(sequence).not_to eq described_class.new(:month, from..to)
        end
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
        let(:options) { {expand: true} }

        its(:from){should == TimeMath.month.floor(from)}
        its(:to){should == TimeMath.month.ceil(to)}
      end

      describe 'operations' do
        subject(:seq) { sequence.advance(:hour, 2).decrease(:sec, 3).floor(:min) }

        it { is_expected.to be_a described_class }
        its(:methods) { is_expected.to include(*TimeMath::Op::OPERATIONS) }
        its(:op) { is_expected.to eq TimeMath::Op.new.advance(:hour, 2).decrease(:sec, 3).floor(:min) }
        its(:inspect) { is_expected.to eq "#<TimeMath::Sequence(:month, #{from}...#{to}).advance(:hour, 2).decrease(:sec, 3).floor(:min)>" }

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
        let(:fixture){load_fixture(:sequence_to_a)}

        let(:from){t.parse(fixture[:from])}
        let(:to){t.parse(fixture[:to])}

        let(:sequence){described_class.new(fixture[:step], from...to, options)}

        let(:expected){fixture[:sequence].map(&t.method(:parse))}

        subject{sequence.to_a}

        it{should == expected}

        context 'when include end' do
          let(:sequence){described_class.new(fixture[:step], from..to, options)}
          let(:expected){fixture[:sequence_include_end].map(&t.method(:parse))}

          it{should == expected}
        end

        context 'with operations' do
          let(:sequence) {
            described_class
              .new(fixture[:step], from...to, options)
              .advance(:hour, 2).decrease(:sec, 3).floor(:min)
          }
          let(:op) { TimeMath().advance(:hour, 2).decrease(:sec, 3).floor(:min) }

          let(:expected){fixture[:sequence].map(&t.method(:parse)).map(&op)}

          it{is_expected.to eq expected}
        end
      end

      describe '#pairs' do
        let(:fixture){load_fixture(:sequence_pairs)}
        let(:from){t.parse(fixture[:from])}
        let(:to){t.parse(fixture[:to])}

        let(:lace){described_class.new(fixture[:step], from, to, options)}

        let(:expected){fixture[:sequence].map{|b,e | [t.parse(b), t.parse(e)]}}

        subject{sequence.pairs}

        it{should == expected}

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
