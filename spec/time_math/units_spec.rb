# encoding: utf-8
describe TimeMath::Units::Base do
  def u(name)
    TimeMath::Units.get(name)
  end

  [Time, DateTime].each do |t|
    describe "math with #{t}" do
      describe '#floor' do
        fixture = load_fixture(:floor)

        let(:source){t.parse(fixture[:source])}

        fixture[:targets].each do |step, val|
          it "should round down to #{step}" do
            expect(u(step).floor(source)).to eq t.parse(val)
          end
        end
      end

      describe '#ceil' do
        fixture = load_fixture(:ceil)

        let(:source){t.parse(fixture[:source])}

        fixture[:targets].each do |step, val|
          it "should round up to #{step}" do
            expect(u(step).ceil(source)).to eq t.parse(val)
          end
        end
      end

      describe '#round' do
        let(:ceiled){t.parse('2015-03-01 12:32')}
        let(:floored){t.parse('2015-03-01 12:22')}
        let(:edge){t.parse('2015-03-01 12:30')}

        let(:unit){u(:hour)}

        it 'should smart round to ceil or floor' do
          expect(unit.round(ceiled)).to eq unit.ceil(ceiled)
          expect(unit.round(floored)).to eq unit.floor(floored)
          expect(unit.round(edge)).to eq unit.ceil(edge)
        end
      end

      describe '#prev' do
        let(:floored){t.parse('2015-03-01 12:22')}
        let(:decreased){t.parse('2015-03-01')}

        let(:unit){u(:day)}

        it 'smartly calculates previous round' do
          expect(unit.prev(floored)).to eq unit.floor(floored)
          expect(unit.prev(decreased)).to eq unit.decrease(unit.floor(floored))
        end
      end

      describe '#next' do
        let(:ceiled){t.parse('2015-03-01 12:22')}
        let(:advanced){t.parse('2015-03-02')}

        let(:unit){u(:day)}

        it 'smartly calculates next round' do
          expect(unit.next(ceiled)).to eq unit.ceil(ceiled)
          expect(unit.next(advanced)).to eq unit.advance(unit.floor(advanced))
        end
      end

      describe '#advance' do
        context 'one step' do
          fixture = load_fixture(:advance)
          let(:source){t.parse(fixture[:source])}

          fixture[:targets].each do |step, val|
            it "should advance one #{step} exactly" do
              expect(u(step).advance(source)).to eq t.parse(val)
            end
          end
        end

        context 'several steps' do
          let(:tm){t.parse('2015-03-27 11:40:20')}

          [:sec, :min, :hour, :day, :month, :year].each do |step|
            [3, 100, 1000].each do |amount|
              context "when advanced #{amount} #{step}s" do
                let(:unit){u(step)}
                subject{unit.advance(tm, amount)}
                let(:correct){amount.times.inject(tm){|tt| unit.advance(tt)}}

                it{should == correct}
              end
            end
          end
        end

        context 'negative advance' do
          let(:tm){t.parse('2015-03-27 11:40:20')}

          [:sec, :min, :hour, :day, :month, :year].each do |step|
            context "when step=#{step}" do
              let(:unit){u(step)}

              it "should treat negative advance as decrease" do
                expect(unit.advance(tm, -13)).to eq(unit.decrease(tm, 13))
              end
            end
          end
        end

        context 'zero advance' do
          let(:tm){t.parse('2015-03-27 11:40:20')}

          [:sec, :min, :hour, :day, :month, :year].each do |step|
            context "when step=#{step}" do
              let(:unit){u(step)}

              it "should do nothing on zero advance" do
                expect(unit.advance(tm, 0)).to eq tm
              end
            end
          end
        end
      end

      describe '#decrease' do
        context 'one step' do
          fixture = load_fixture(:decrease)
          let(:source){t.parse(fixture[:source])}

          fixture[:targets].each do |step, val|
            it "should decrease one #{step} exactly" do
              expect(u(step).decrease(source)).to eq t.parse(val)
            end
          end
        end

        context 'several steps' do
          let(:tm){t.parse('2015-03-27 11:40:20')}

          [:sec, :min, :hour, :day, :month, :year].each do |step|
            [3, 100, 1000].each do |amount|
              context "when decreased #{amount} #{step}s" do
                let(:unit){u(step)}
                subject{unit.decrease(tm, amount)}
                let(:correct){amount.times.inject(tm){|tt| unit.decrease(tt)}}

                it{should == correct}
              end
            end
          end
        end

        context 'negative decrease' do
          let(:tm){t.parse('2015-03-27 11:40:20')}

          [:sec, :min, :hour, :day, :month, :year].each do |step|
            context "when step=#{step}" do
              let(:unit){u(step)}

              it "should treat negative decrease as advance" do
                expect(unit.decrease(tm, -13)).to eq(unit.advance(tm, 13))
              end
            end
          end
        end

        context 'zero decrease' do
          let(:tm){t.parse('2015-03-27 11:40:20')}

          [:sec, :min, :hour, :day, :month, :year].each do |step|
            context "when step=#{step}" do
              let(:unit){u(step)}

              it "should do nothing on zero decrease" do
                expect(unit.decrease(tm, 0)).to eq tm
              end
            end
          end
        end
      end

      # TODO: edge cases:
      # * monthes decr/incr, including leap ears

      describe 'Edge case: DST' do
        # form with guaranteed DST:
        #  mktime(sec, min, hour, day, month, year, wday, yday, isdst, tz)
        #
        # Nevertheless, it's Kiev time before the midnight when
        # we are changing our time to daylight saving
        let(:spring_before){
          Time.mktime(20, 40, 11, 28, 3, 2015, nil, nil, nil, "EEST")
        }
        let(:spring_after ){
          Time.mktime(20, 40, 11, 29, 3, 2015, nil, nil, nil, "EEST")
        }

        it "should correctly shift step over the DST border" do
          expect(TimeMath.day.advance(spring_before)).to eq spring_after
          expect(TimeMath.day.decrease(spring_after)).to eq spring_before
        end
      end

      describe '#round?' do
        let(:fixture){load_fixture(:round)}

        it 'should determine, if tm is round to step' do
          fixture.each do |step, vals|
            expect( u(step).round?(t.parse(vals[:true])) ).to be_truthy

            expect( u(step).round?(t.parse(vals[:false])) ).to be_falsy
          end
        end
      end

      describe '#range' do
        let(:from){Time.now}

        TimeMath::Units.names.each do |step|
          context "with step=#{step}" do
            let(:unit){u(step)}

            context 'when single step' do
              subject{unit.range(from)}
              it{should == (from...unit.advance(from))}
            end

            context 'when several steps' do
              subject{unit.range(from, 5)}
              it{should == (from...unit.advance(from, 5))}
            end
          end
        end
      end

      describe '#range_back' do
        let(:from){Time.now}

        TimeMath::Units.names.each do |step|
          context "with step=#{step}" do
            let(:unit){u(step)}

            context 'when single step' do
              subject{unit.range_back(from)}
              it{should == (unit.decrease(from)...from)}
            end

            context 'when several steps' do
              subject{unit.range_back(from, 5)}
              it{should == (unit.decrease(from, 5)...from)}
            end
          end
        end
      end

      describe '#measure' do
        fixture = load_fixture(:measure)

        fixture.each do |data|
          context data[:step] do
            let(:unit){u(data[:step])}
            let(:from){t.parse(data[:from])}
            let(:to){t.parse(data[:to])}
            subject{unit.measure(from, to)}

            it { is_expected.to eq data[:val] }
          end
        end
      end

      describe '#measure_rem' do
        fixture = load_fixture(:measure)

        fixture.each do |data|
          context data[:step] do
            let(:unit){u(data[:step])}
            let(:from){t.parse(data[:from])}
            let(:to){t.parse(data[:to])}

            it 'should measure integer steps between from and to and return reminder' do
              measure, rem = unit.measure_rem(from, to)

              expected_rem = unit.advance(from, measure)

              expect(measure).to eq data[:val]
              expect(rem).to eq expected_rem
            end
          end
        end
      end

      describe '#span' do
        TimeMath::Units.names.each do |unit|
          context "with #{unit}" do
            subject{u(unit).span(5)}
            it{should == TimeMath::Span.new(unit, 5)}
          end
        end
      end
    end
  end
end
