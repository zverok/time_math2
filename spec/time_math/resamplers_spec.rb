describe TimeMath::ArrayResampler do
  fixture = load_fixture(:resample)
  fixture.each do |f|
    context "with #{f[:unit]}" do
      let(:source) { f[:source].map(&Time.method(:parse)) }
      let(:target) { f[:target].map(&Time.method(:parse)) }

      subject { described_class.new(f[:unit], source).call }

      it { is_expected.to eq target }
    end
  end
end

describe TimeMath::HashResampler do
  let(:hash) {
    {
      Date.parse('Wed, 01 Jun 2016') => 1,
      Date.parse('Tue, 07 Jun 2016') => 3,
      Date.parse('Thu, 09 Jun 2016') => 1
    }
  }

  let(:resampler) { described_class.new(unit, hash) }

  context 'without block' do
    subject { resampler.call }

    context 'one in group' do
      let(:unit) { :day }

      it { is_expected.to eq(
        Date.parse('Wed, 01 Jun 2016') => [1],
        Date.parse('Wed, 02 Jun 2016') => [],
        Date.parse('Wed, 03 Jun 2016') => [],
        Date.parse('Wed, 04 Jun 2016') => [],
        Date.parse('Wed, 05 Jun 2016') => [],
        Date.parse('Wed, 06 Jun 2016') => [],
        Date.parse('Tue, 07 Jun 2016') => [3],
        Date.parse('Wed, 08 Jun 2016') => [],
        Date.parse('Thu, 09 Jun 2016') => [1]
      )
      }
    end

    context 'several in group' do
      let(:unit) { :week }

      it { is_expected.to eq(
        Date.parse('Wed, 30 May 2016') => [1],
        Date.parse('Wed, 06 Jun 2016') => [3, 1]
      )
      }
    end
  end

  context 'with block' do
    subject { resampler.call { |v| v.inject(:+) } }

    context 'one in group' do
      let(:unit) { :day }

      it { is_expected.to eq(
        Date.parse('Wed, 01 Jun 2016') => 1,
        Date.parse('Wed, 02 Jun 2016') => nil,
        Date.parse('Wed, 03 Jun 2016') => nil,
        Date.parse('Wed, 04 Jun 2016') => nil,
        Date.parse('Wed, 05 Jun 2016') => nil,
        Date.parse('Wed, 06 Jun 2016') => nil,
        Date.parse('Tue, 07 Jun 2016') => 3,
        Date.parse('Wed, 08 Jun 2016') => nil,
        Date.parse('Thu, 09 Jun 2016') => 1
      )
      }
    end

    context 'several in group' do
      let(:unit) { :week }

      it { is_expected.to eq(
        Date.parse('Wed, 30 May 2016') => 1,
        Date.parse('Wed, 06 Jun 2016') => 4
      )
      }
    end
  end

  context 'with symbol' do
    subject { resampler.call(:first) }

    context 'one in group' do
      let(:unit) { :day }

      it { is_expected.to eq(
        Date.parse('Wed, 01 Jun 2016') => 1,
        Date.parse('Wed, 02 Jun 2016') => nil,
        Date.parse('Wed, 03 Jun 2016') => nil,
        Date.parse('Wed, 04 Jun 2016') => nil,
        Date.parse('Wed, 05 Jun 2016') => nil,
        Date.parse('Wed, 06 Jun 2016') => nil,
        Date.parse('Tue, 07 Jun 2016') => 3,
        Date.parse('Wed, 08 Jun 2016') => nil,
        Date.parse('Thu, 09 Jun 2016') => 1
      )
      }
    end

    context 'several in group' do
      let(:unit) { :week }

      it { is_expected.to eq(
        Date.parse('Wed, 30 May 2016') => 1,
        Date.parse('Wed, 06 Jun 2016') => 3
      )
      }
    end
  end
end
