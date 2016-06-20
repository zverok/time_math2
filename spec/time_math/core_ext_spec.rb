require 'time_math/core_ext'

describe TimeMath::CoreExt do
  let(:unit) { TimeMath.day }
  let(:tm) { Time.parse('2016-05-01 13:30') }
  let(:to) { Time.parse('2016-05-06 13:30') }

  it 'should work' do
    expect(tm.floor_to(:day)).to eq unit.floor(tm)
    expect(tm.ceil_to(:day)).to eq unit.ceil(tm)
    expect(tm.round_to(:day)).to eq unit.round(tm)
    expect(tm.next_to(:day)).to eq unit.next(tm)
    expect(tm.prev_to(:day)).to eq unit.prev(tm)
    expect(tm.round_to?(:day)).to eq false

    expect(tm.advance_by(:day, 5)).to eq unit.advance(tm, 5)
    expect(tm.decrease_by(:day, 5)).to eq unit.decrease(tm, 5)

    expect(tm.range_to(:day, 5)).to eq unit.range(tm, 5)
    expect(tm.range_from(:day, 5)).to eq unit.range_back(tm, 5)

    expect(tm.sequence_to(:day, to)).to eq unit.sequence(tm...to)
  end
end
