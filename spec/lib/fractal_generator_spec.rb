require 'spec_helper'

describe Fractal::Generator do
  it "should truncate map by default" do
    subject = Fractal::Generator.new(10, 10)
    subject.width.should == 10
    subject.height.should == 10
    subject.map.length.should == 10
    subject.map[0].length.should == 10
  end
end
