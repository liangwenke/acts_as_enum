# encoding: utf-8

version = File.read(File.expand_path("../VERSION",__FILE__)).strip

Gem::Specification.new do |s|
  s.name = 'acts_as_enum'
  s.version = version
  s.author = "Mike Liang"
  s.email = "liangwenke.com@gmail.com"
  s.homepage = "http://github.com/liangwenke/acts_as_enum"
  s.summary = 'Enum Attribute for Rails ActiveRecord'
  s.description = 'For multiple values activerecord attributes. This gem have some very useful methods and constants for attribute.'
  
  s.files        = Dir["{lib,test}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
