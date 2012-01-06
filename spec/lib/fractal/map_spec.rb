require 'spec_helper'

describe Fractal::Map do
  subject { Fractal::Map.new(32) }
  
  it "should have size 32x32" do
    subject.width.should == 32
    subject.height.should == 32
  end
  
  it "should have 32x32 elements" do
    subject.flatten.length.should == 32*32
  end
  
  it "should restrict bounds to 32x32" do
    proc { subject[32, 0]     }.should raise_error
    proc { subject[32, 0] = 1 }.should raise_error
    proc { subject[0, 32]     }.should raise_error
    proc { subject[0, 32] = 1 }.should raise_error
  end
  
  it "should not allow assignment to first dimension" do
    proc { subject[0] = [] }.should raise_error
  end
  
  it "should truncate size" do
    subject.truncate 10, 15
    subject.width.should == 10
    subject.height.should == 15
    subject.length.should == 15
    subject.row(0).length.should == 10
  end
end
