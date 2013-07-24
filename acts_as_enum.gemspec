# encoding: utf-8

version = File.read(File.expand_path("../VERSION",__FILE__)).strip

Gem::Specification.new do |spec|
  spec.name                      = 'acts_as_enum'
  spec.version                   = version
  spec.author                    = "Mike Liang"
  spec.email                     = "liangwenke.com@gmail.com"
  spec.homepage                  = "http://github.com/liangwenke/acts_as_enum"
  spec.summary                   = 'Enum Attribute for Rails ActiveRecord'
  spec.description               = 'For multiple values activerecord attributes. This gem have some very useful methods and constants for attribute.'
  spec.license                   = 'MIT'

  spec.files                     = Dir["{lib,test}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  spec.require_path              = "lib"
  spec.rubyforge_project         = spec.name
  spec.required_rubygems_version = ">= 1.3.4"
end
