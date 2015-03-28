# encoding: utf-8
describe TimeBoots do
  subject{described_class}
  its(:steps){should == [:sec, :min, :hour, :day, :week, :month, :year]}
end
