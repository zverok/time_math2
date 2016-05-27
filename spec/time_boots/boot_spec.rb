# encoding: utf-8
describe TimeBoots::Boot do
  [Time, DateTime].each do |t|
    describe "math with #{t}" do
      describe '#floor' do
        fixture = load_fixture(:floor)

        let(:source){t.parse(fixture[:source])}

        fixture[:targets].each do |step, val|
          it "should round down to #{step}" do
            expect(described_class.get(step).floor(source)).to eq t.parse(val)
          end
        end
      end

      describe '#ceil' do
        fixture = load_fixture(:ceil)

        let(:source){t.parse(fixture[:source])}

        fixture[:targets].each do |step, val|
          it "should round up to #{step}" do
            expect(described_class.get(step).ceil(source)).to eq t.parse(val)
          end
        end
      end

      describe '#round' do
        let(:ceiled){t.parse('2015-03-01 12:32')}
        let(:floored){t.parse('2015-03-01 12:22')}
        let(:edge){t.parse('2015-03-01 12:30')}

        let(:boot){described_class.get(:hour)}

        it 'should smart round to ceil or floor' do
          expect(boot.round(ceiled)).to eq boot.ceil(ceiled)
          expect(boot.round(floored)).to eq boot.floor(floored)
          expect(boot.round(edge)).to eq boot.ceil(edge)
        end
      end

      describe '#advance' do
        context 'one step' do
          fixture = load_fixture(:advance)
          let(:source){t.parse(fixture[:source])}

          fixture[:targets].each do |step, val|
            it "should advance one #{step} exactly" do
              expect(described_class.get(step).advance(source)).to eq t.parse(val)
            end
          end
        end

        context 'several steps' do
          let(:tm){t.parse('2015-03-27 11:40:20')}

          [:sec, :min, :hour, :day, :month, :year].each do |step|
            [3, 100, 1000].each do |amount|
              context "when advanced #{amount} #{step}s" do
                let(:boot){described_class.get(step)}
                subject{boot.advance(tm, amount)}
                let(:correct){amount.times.inject(tm){|tt| boot.advance(tt)}}

                it{should == correct}
              end
            end
          end
        end

        context 'negative advance' do
          let(:tm){t.parse('2015-03-27 11:40:20')}

          [:sec, :min, :hour, :day, :month, :year].each do |step|
            context "when step=#{step}" do
              let(:boot){described_class.get(step)}

              it "should treat negative advance as decrease" do
                expect(boot.advance(tm, -13)).to eq(boot.decrease(tm, 13))
              end
            end
          end
        end

        context 'zero advance' do
          let(:tm){t.parse('2015-03-27 11:40:20')}

          [:sec, :min, :hour, :day, :month, :year].each do |step|
            context "when step=#{step}" do
              let(:boot){described_class.get(step)}

              it "should do nothing on zero advance" do
                expect(boot.advance(tm, 0)).to eq tm
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
              expect(described_class.get(step).decrease(source)).to eq t.parse(val)
            end
          end
        end

        context 'several steps' do
          let(:tm){t.parse('2015-03-27 11:40:20')}

          [:sec, :min, :hour, :day, :month, :year].each do |step|
            [3, 100, 1000].each do |amount|
              context "when decreased #{amount} #{step}s" do
                let(:boot){described_class.get(step)}
                subject{boot.decrease(tm, amount)}
                let(:correct){amount.times.inject(tm){|tt| boot.decrease(tt)}}

                it{should == correct}
              end
            end
          end
        end

        context 'negative decrease' do
          let(:tm){t.parse('2015-03-27 11:40:20')}

          [:sec, :min, :hour, :day, :month, :year].each do |step|
            context "when step=#{step}" do
              let(:boot){described_class.get(step)}

              it "should treat negative decrease as advance" do
                expect(boot.decrease(tm, -13)).to eq(boot.advance(tm, 13))
              end
            end
          end
        end

        context 'zero decrease' do
          let(:tm){t.parse('2015-03-27 11:40:20')}

          [:sec, :min, :hour, :day, :month, :year].each do |step|
            context "when step=#{step}" do
              let(:boot){described_class.get(step)}

              it "should do nothing on zero decrease" do
                expect(boot.decrease(tm, 0)).to eq tm
              end
            end
          end
        end
      end

      # TODO: edge cases:
      # * monthes decr/incr, including leap ears

      describe 'Edge case: DST' do
        # form with guaranteed DST:
        #  local(sec, min, hour, day, month, year, wday, yday, isdst, tz)
        #
        # FIXME: seems in Ruby 2.2.0 it have changed.
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
          expect(TimeBoots.day.advance(spring_before)).to eq spring_after
          expect(TimeBoots.day.decrease(spring_after)).to eq spring_before
        end
      end

      describe '#round?' do
        let(:fixture){load_fixture(:round)}

        it 'should determine, if tm is round to step' do
          fixture.each do |step, vals|
            expect( described_class.get(step).round?(t.parse(vals[:true])) ).to \
              be_truthy

            expect( described_class.get(step).round?(t.parse(vals[:false])) ).to \
              be_falsy
          end
        end
      end

      describe '#range' do
        let(:from){Time.now}

        described_class.steps.each do |step|
          context "with step=#{step}" do
            let(:boot){described_class.get(step)}

            context 'when single step' do
              subject{boot.range(from)}
              it{should == (from...boot.advance(from))}
            end

            context 'when several steps' do
              subject{boot.range(from, 5)}
              it{should == (from...boot.advance(from, 5))}
            end
          end
        end
      end

      describe '#range_back' do
        let(:from){Time.now}

        described_class.steps.each do |step|
          context "with step=#{step}" do
            let(:boot){described_class.get(step)}

            context 'when single step' do
              subject{boot.range_back(from)}
              it{should == (boot.decrease(from)...from)}
            end

            context 'when several steps' do
              subject{boot.range_back(from, 5)}
              it{should == (boot.decrease(from, 5)...from)}
            end
          end
        end
      end

      describe '#measure' do
        fixture = load_fixture(:measure)

        fixture.each do |data|
          context data[:step] do
            let(:boot){TimeBoots::Boot.get(data[:step])}
            let(:from){t.parse(data[:from])}
            let(:to){t.parse(data[:to])}
            subject{boot.measure(from, to)}

            it { is_expected.to eq data[:val] }
          end
        end
      end

      describe '#measure_rem' do
        fixture = load_fixture(:measure)

        fixture.each do |data|
          context data[:step] do
            let(:boot){TimeBoots::Boot.get(data[:step])}
            let(:from){t.parse(data[:from])}
            let(:to){t.parse(data[:to])}

            it 'should measure integer steps between from and to and return reminder' do
              measure, rem = boot.measure_rem(from, to)

              expected_rem = boot.advance(from, measure)

              expect(measure).to eq data[:val]
              expect(rem).to eq expected_rem
            end
          end
        end
      end

      describe '#jump' do
        described_class.steps.each do |step|
          context "with step=#{step}" do
            subject{described_class.get(step).jump(5)}
            it{should == TimeBoots::Jump.new(step, 5)}
          end
        end
      end
    end
  end
end
