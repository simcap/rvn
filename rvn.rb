#! /usr/bin/env ruby
require 'rainbow'
require 'nokogiri'
require 'httparty'

module Raven
  
  module PomResource
    
    def pom_as_doc
      pom = Nokogiri::XML File.open 'pom.xml'
      pom.remove_namespaces!
    end
    
  end
  
  module Dependencies
    include PomResource
    
    def list_dep
      pom_as_doc.css('dependencies > dependency').map { |node|
        "#{node.xpath('groupId').text}:#{node.xpath('artifactId').text}:#{node.xpath('version').text}"
      }.join(":")
    end
    
    def search_dep(group_id, artifact_id = nil, version = nil)
      MavenDependencyResolver.new(group_id, artifact_id, version).resolve
    end
        
  end

  class Rvn
    include Dependencies    
  
    def initialize
      @console = Raven::Console.new
    end
    
    def run(arguments)
      @arguments = arguments
      if @arguments[0] == "dep"
        @console.out(list_dep)
        return
      elsif @arguments[0] == "search"
        if @arguments[1]
          found_info = search_dep(*arguments[1].split(":"))
          @console.out(found_info)
        else
          @console.out("No dependency coordinates provided. Run the help")
        end
      else
        delegate_to_maven
      end
    end
    
    def delegate_to_maven
      command = "mvn #{@arguments.join(' ')}"
      IO.popen(command) { |maven|
        maven.each do |line|
          @console.out line
        end
      }
    end    
    
  end
  
  
  class MavenDependencyResolver
    include HTTParty
    base_uri 'mvnrepository.com/artifact'
    
    def initialize(group_id, artifact_id = nil, version = nil)
      @group = group_id
      @artifact = artifact_id
      @version = version
    end
    
    def resolve
      return dependency if fetch_dependency?
      return artifacts if fetch_artifacts?
      return versions if fetch_versions?
    end
    
    private

    def dependency
      if dependency_valid?
        dependency_as_xml
      else
        "Cannot find #{@group}:#{@artifact}:#{@version} in maven repo" 
      end
    end
    
    def versions
      if group_and_artifact_valid?
        response_body = self.class.get("/#{@group}/#{@artifact}").body
        parse_response(response_body, "//table/tr/td/a[@class='versionbutton release']")
      else
        "Cannot find #{@group}:#{@artifact} in maven repo" 
      end
    end
    
    def artifacts
      if group_valid?
        response_body = self.class.get("/#{@group}").body
        parse_response(response_body, "//div[@id='maincontent']/table/tr/td/a[not(@class)]")
      else
        "Cannot find #{@group} in maven repo" 
      end
    end
    
    def parse_response(body, xpath_expression)
      items_found = []
      html_doc = Nokogiri::HTML(body)
      html_doc.xpath(xpath_expression).each do |node|
        items_found << node.text
      end
      items_found.join("\n")
    end
        
    def dependency_as_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.dependency {
          xml.groupId @group
          xml.artifactId @artifact
          xml.version @version
        }
      end
      builder.to_xml      
    end
    
    def group_valid?
      200 == self.class.get("/#{@group}").code
    end

    def group_and_artifact_valid?
      200 == self.class.get("/#{@group}/#{@artifact}").code
    end

    def dependency_valid?
      200 == self.class.get("/#{@group}/#{@artifact}/#{@version}").code
    end
      
    def fetch_artifacts?
      @group && @artifact.nil? && @version.nil?
    end

    def fetch_versions?
      @group && @artifact && @version.nil?
    end

    def fetch_dependency?
      @group && @artifact && @version
    end
    
  end
      
  class Console
  
    def out(content)
      content.each_line { |line|
        line = line.foreground(:red) if line =~ /^\[ERROR\]/
        line = line.foreground(:green) if line =~ /SUCCESS/
        line = line.foreground(:yellow) if line =~ /^\[WARNING\]/
        print line
      }
    end
  
  end
  
end
