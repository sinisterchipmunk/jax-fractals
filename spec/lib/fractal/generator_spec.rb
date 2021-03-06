require 'spec_helper'

describe Fractal::Generator do
  it "should truncate map by default" do
    subject = Fractal::Generator.new(:width => 10, :height => 10)
    subject.width.should == 10
    subject.height.should == 10
    subject.map.length.should == 10
    subject.map.row(0).length.should == 10
  end
end
