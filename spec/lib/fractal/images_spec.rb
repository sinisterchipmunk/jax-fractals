require 'spec_helper'

describe "Fractal images" do
  def subject(options = {})
    Fractal::Generator.image(options.reverse_merge(:seed => 1)).to_blob { self.format = 'PNG' }
  end
  
  it "should generate default image" do
    subject.should == fractal('1')
  end
  
  it "should generate with alpha" do
    subject(:alpha => true).should == fractal('1?alpha=1')
  end
  
  it "should truncate size" do
    subject(:width => 126, :height => 130).should == fractal('1?width=126&height=130')
  end
  
  it "should generate an island" do
    subject(:island => true).should == fractal('1?island=1')
  end
  
  it "should generate more jagged fractals" do
    subject(:smoothness => 1.2).should == fractal('1?smoothness=1.2')
  end
  
  it "should set high color" do
    subject(:high_color => 'ff0000').should == fractal('1?high_color=ff0000')
  end
  
  it "should set low color" do
    subject(:low_color => '0000ff').should == fractal('1?low_color=0000ff')
  end
  
  it "should set high and low color" do
    subject(:high_color => 'ff0000', :low_color => '0000ff').should == fractal('1?low_color=0000ff&high_color=ff0000')
  end
end
