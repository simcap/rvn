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
      @console.should_receive(:out)
                  .with(/junit:junit:3.8.1/)
                  .with(/commons-lang:commons-lang:2.9/)
      @raven.run(%w{ dep })
    end
    
    it "should print out dependency as xml from repo for valid maven dependency" do
      @console.should_receive(:out)
                .with(/<groupId>commons-io<\/groupId>/)
                .with(/<artifactId>commons-io<\/artifactId>/)
                .with(/<version>2\.4<\/version>/)
      @raven.run(%w{search commons-io:commons-io:2.4})
    end
    
    it "should print out version listing for valid maven dependency" do
      @console.should_receive(:out)
                .with(/20030203\.000550/)
                .with(/2.4/).with(/2.3/).with(/2.2/).with(/2.1/).with(/2.0.1/).with(/2.0/)
      @raven.run(%w{search commons-io:commons-io})
    end

    it "should print out artifact ids for valid maven group id" do
      @console.should_receive(:out)
                .with(/spring/).with(/spring-mock/).with(/spring-core/).with(/spring-context/)
                .with(/spring-beans/).with(/spring-web/).with(/spring-hibernate/).with(/spring-support/)
      @raven.run(%w{search springframework})
    end
    
    
    it "should print out error message when version do not exists in repo" do
      @console.should_receive(:out).with(/Cannot find/).with(/5\.6/)
      @raven.run(%w{search commons-io:commons-io:5.6})
    end

    it "should print out error message when artifact do not exists in repo" do
      @console.should_receive(:out).with(/Cannot find/).with(/commons-nope/)
      @raven.run(%w{search commons-io:commons-nope})
    end

    it "should print out error message when group do not exists in repo" do
      @console.should_receive(:out).with(/Cannot find/).with(/commons-nimp/)
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
