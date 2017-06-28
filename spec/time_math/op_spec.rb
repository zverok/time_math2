describe TimeMath::Op do
  describe 'default' do
    subject(:op) {
      described_class.new.floor(:month).advance(:day, 3).decrease(:min, 20)
    }

    context 'validation' do
      it 'should fail on unknown units' do
        expect { op.decrease(:ages, 2) }.to raise_error(ArgumentError, /ages/)
      end
    end

    context '#operations' do
      its(:operations) { is_expected.to eq([
        [:floor, :month, []],
        [:advance, :day, [3]],
        [:decrease, :min, [20]]
      ])
      }

      context 'bang' do
        subject!(:ceiled) { op.ceil!(:hour) }
        its(:operations) { is_expected.to include([:ceil, :hour, []]) }
        it { expect(op.operations).to include([:ceil, :hour, []]) }
      end

      context 'non-bang' do
        subject!(:ceiled) { op.ceil(:hour) }
        its(:operations) { is_expected.to include([:ceil, :hour, []]) }
        it { expect(op.operations).not_to include([:ceil, :hour, []]) }
      end
    end

    context '#==' do
      let(:tm) { Time.parse('2016-05-14 13:40') }

      it 'is equal when is equal' do
        expect(described_class.new.floor(:month).advance(:day, 3))
          .to eq described_class.new.floor(:month).advance(:day, 3)

        expect(described_class.new(tm).floor(:month).advance(:day, 3))
          .to eq described_class.new(tm).floor(:month).advance(:day, 3)
      end

      it 'is not equal on different ops or params' do
        expect(described_class.new.floor(:month).advance(:day, 3))
          .not_to eq described_class.new.ceil(:month).advance(:day, 3)

        expect(described_class.new.floor(:month).advance(:day, 3))
          .not_to eq described_class.new.floor(:month).advance(:day, 2)
      end

      it 'considers op order' do
        expect(described_class.new.floor(:month).advance(:day, 3))
          .not_to eq described_class.new.advance(:day, 3).floor(:month)
      end

      it 'considers arguments' do
        expect(described_class.new.floor(:month).advance(:day, 3))
          .not_to eq described_class.new(tm).floor(:month).advance(:day, 3)
      end
    end

    context '#call' do
      context 'single argument' do
        subject { op.call(Time.parse('2016-05-14 13:40')) }
        it { is_expected.to eq Time.parse('2016-05-03 23:40') }
      end

      context 'multiple arguments' do
        subject { op.call(Time.parse('2016-05-14 13:40'), Time.parse('2016-07-02 12:10')) }
        it { is_expected.to eq [Time.parse('2016-05-03 23:40'), Time.parse('2016-07-03 23:40')] }
      end

      context 'array of arguments' do
        subject { op.call([Time.parse('2016-05-14 13:40'), Time.parse('2016-07-02 12:10')]) }
        it { is_expected.to eq [Time.parse('2016-05-03 23:40'), Time.parse('2016-07-03 23:40')] }
      end

      context 'no-op' do
        subject { described_class.new.call(Time.parse('2016-05-14 13:40')) }
        it { is_expected.to eq Time.parse('2016-05-14 13:40') }
      end

      context 'pre-set arguments' do
        subject(:op) {
          described_class.new(Time.parse('2016-05-14 13:40'))
            .floor(:month).advance(:day, 3).decrease(:min, 20)
        }

        context 'without args' do
          subject { op.call }
          it { is_expected.to eq Time.parse('2016-05-03 23:40') }
        end

        it 'fails without args' do
          expect { op.call(Time.parse('2016-05-14 13:40')) }
            .to raise_error(ArgumentError, /already/)
        end
      end
    end

    context '#to_proc' do
      let(:tm1) { Time.parse('2016-05-14 13:40') }
      let(:tm2) { Time.parse('2016-06-14 13:40') }

      subject { [tm1, tm2].map(&op) }
      it { is_expected.to eq [op.call(tm1), op.call(tm2)] }
    end

    context '#inspect' do
      its(:inspect) { is_expected.to eq '#<TimeMath::Op floor(:month).advance(:day, 3).decrease(:min, 20)>' }

      context 'with preset arg' do
        let(:tm1) { Time.parse('2016-05-14 13:40') }
        let(:tm2) { Time.parse('2016-06-14 13:40') }

        context 'one arg' do
          subject(:op) {
            described_class.new(tm1)
              .floor(:month).advance(:day, 3).decrease(:min, 20)
          }

          its(:inspect) { is_expected.to eq "#<TimeMath::Op(#{tm1.inspect}).floor(:month).advance(:day, 3).decrease(:min, 20)>" }
        end

        context 'multiple arg' do
          subject(:op) {
            described_class.new(tm1, tm2)
              .floor(:month).advance(:day, 3).decrease(:min, 20)
          }

          its(:inspect) { is_expected.to eq "#<TimeMath::Op(#{tm1.inspect}, #{tm2.inspect}).floor(:month).advance(:day, 3).decrease(:min, 20)>" }
        end

        context 'array of args' do
          let(:tm) { Time.parse('2016-05-14 13:40') }

          subject(:op) {
            described_class.new([tm1, tm2])
              .floor(:month).advance(:day, 3).decrease(:min, 20)
          }

          its(:inspect) { is_expected.to eq "#<TimeMath::Op(#{[tm1, tm2].inspect}).floor(:month).advance(:day, 3).decrease(:min, 20)>" }
        end
      end
    end
  end
end
