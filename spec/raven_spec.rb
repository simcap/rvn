require File.expand_path('../../raven.rb', __FILE__)
include Raven

describe Rvn do
  
  before :each do
    @console = double("console")
    @raven = Rvn.new
    @raven.instance_variable_set(:@console, @console)
  end
  
  context "dependencies" do
    it "should print out in console the dependencies list" do
      @console.should_receive(:out) do |text|
        text.include? "junit:junit:3.8.1"
        text.include? "commons-lang:commons-lang:2.9"
      end
      @raven.run(%w{ dep })
    end
    
    it "should print out dependency as xml from repo for valid maven dependency" do
      @console.should_receive(:out) do |text|
        text.include? "<groupId>commons-io</groupId>"
        text.include? "<artifactId>commons-io</artifactId>"
        text.include? "<version>2.4</version>"
      end
      @raven.run(%w{search commons-io:commons-io:2.4})
    end
    
    it "should print out version listing for valid maven dependency" do
      @console.should_receive(:out) do |table|
        table.to_s.include? "Available versions for commons-io:commons-io"
        table.to_s.include? "20030203.000550"
        table.to_s.include? "2.2"
      end
      @raven.run(%w{search commons-io:commons-io})
    end

    it "should print out artifact ids for valid maven group id" do
      @console.should_receive(:out) do |table|
        table.to_s.include? "Available artifacts for springframework"
        table.to_s.include? "spring"
        table.to_s.include? "spring-mock"
        table.to_s.include? "spring-support"
      end
      @raven.run(%w{search springframework})
    end
    
    it "should print out error message when version do not exists in repo" do
      @console.should_receive(:out) do |text|
        text.include? "Cannot find"
        text.include? "5.6"
      end
      @raven.run(%w{search commons-io:commons-io:5.6})
    end

    it "should print out error message when artifact do not exists in repo" do
      @console.should_receive(:out) do |text|
        text.include? "Cannot find"
        text.include? "commons-nope"
      end
      @raven.run(%w{search commons-io:commons-nope})
    end

    it "should print out error message when group do not exists in repo" do
      @console.should_receive(:out) do |text|
        text.include? "Cannot find"
        text.include? "commons-nimp"
      end
      @raven.run(%w{search commons-nimp})
    end

    it "should print out error message when no parameters to search" do
      @console.should_receive(:out).with(/No dependency coordinates provided/)
      @raven.run(%w{search})
    end
    
  end
  
  context "delegate to maven" do
    it "should delegate to maven when raven command not found" do
      @console.should_receive(:out).at_least(:once).with(/^\[INFO\]/)
      @raven.run(%w{ clean })
    end
  end
  
end
